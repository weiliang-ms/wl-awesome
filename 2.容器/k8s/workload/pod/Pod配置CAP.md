# Linux CAP介绍与k8s下配置使用

> 关于capability

发音

```
美[keɪpəˈbɪləti] 英[keɪpə'bɪləti]
```

译为`能力`或`功能`，一般缩写`CAP`，以下我们简称`Capabilities`为`CAP`

## CAP历史回溯

从内核`2.2`开始，`Linux`将传统上与超级用户`root`关联的特权划分为不同的单元，称为`CAP`。

`CAP`作为线程(`Linux`并不真正区分进程和线程)的属性存在，每个单元可以独立启用和禁用。
如此一来，权限检查的过程就变成了：
在执行特权操作时，如果进程的有效身份不是`root`，就去检查是否具有该特权操作所对应的`CAP`，并以此决定是否可以进行该特权操作。

比如要向进程发送信号(`kill()`)，就得具有`CAP_KILL`；如果设置系统时间，就得具有`CAP_SYS_TIME`。

在`CAP`出现之前，系统进程分为两种：
- 特权进程
- 非特权进程

特权进程可以做所有的事情: 进行管理级别的内核调用；而非特权进程被限制为标准用户的子集调用

某些可执行文件需要由标准用户运行，但也需要进行有特权的内核调用，它们需要设置`suid`位，从而有效地授予它们特权访问权限。(典型的例子是`ping`，它被授予进行`ICMP`调用的完全特权访问权。)

这些可执行文件是黑客关注的主要目标——如果他们可以利用其中的漏洞，他们就可以在系统上升级他们的特权级别。
由此内核开发人员提出了一个更微妙的解决方案:`CAP`。

意图很简单: 将所有可能的特权内核调用划分为相关功能组，赋予进程所需要的功能子集。
因此，内核调用被划分为几十个不同的类别，在很大程度上是成功的。

回到`ping`的例子，`CAP`的出现使得它仅被赋予一个`CAP_NET_RAW`功能，就能实现所需功能，这大大降低了安全风险。

**注意：** 比较老的操作系统上，会通过为`ping`添加`SUID`权限的方式，实现普通用户可使用。
这存在很大的安全隐患，笔者所用操作系统（`CentOS7`）上`ping`指令已通过`CAP`方式实现

```bash
$ ls -l /usr/bin/ping
-rwxr-xr-x. 1 root root 66176 8月   4 2017 /usr/bin/ping
$ getcap /usr/bin/ping
/usr/bin/ping = cap_net_admin,cap_net_raw+p
```

## 设置容器的CAP

[Set capabilities for a Container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container)

基于[Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) ，您可以授予某个进程某些特权，而不授予`root`用户的所有特权。

要为容器添加或删除`Linux`功能，请在容器清单的`securityContext`部分中包含`capability`字段。

> 首先，看看未设置`capability`字段时会发生什么。下面是不添加或删除任何`CAP`的配置文件:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-3
spec:
  containers:
  - name: sec-ctx-3
    image: centos:7
    command: ["tail","-f", "/dev/null"]
```

1. 创建`Pod`

```bash
$ kubectl apply -f https://k8s.io/examples/pods/security/security-context-3.yaml
```

2. 查看`Pod`运行状态

```bash
$ kubectl get pod security-context-demo-3
```

3. 在运行的容器中获取一个`shell`:

```bash
kubectl exec -it security-context-demo-3 -- sh
```

4. 在`shell`中，列出正在运行的进程:

```bash
$ ps aux
```

输出显示了容器的进程`id` (`pid`):

```bash
USER  PID %CPU %MEM    VSZ   RSS TTY   STAT START   TIME COMMAND
root    1  0.0  0.0   4336   796 ?     Ss   18:17   0:00 /bin/sh -c node server.js
root    5  0.1  0.5 772124 22700 ?     Sl   18:17   0:00 node server.js
```

5. 在`shell`中，查看进程`1`的状态:

```bash
$ cd /proc/1
$ cat status
```

输出显示了进程的能力位图:

```
...
CapPrm:	00000000a80425fb
CapEff:	00000000a80425fb
...
```

解码

```bash
$ capsh --decode=00000000a80425fb
0x00000000a80425fb=cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
```

6. 记下能力位图，然后退出`shell`:

```bash
$ exit
```

接下来，运行一个与前一个容器相同的容器，只是它有额外的功能集。

7. 运行一个配置增加了`CAP_NET_ADMIN`和`CAP_SYS_TIME`功能的`Pod`:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-4
spec:
  containers:
  - name: sec-ctx-4
    image: centos:7
    command: ["tail","-f", "/dev/null"]
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_TIME"]
EOF
```


8. 在运行的容器中获取一个`shell`:

```bash
kubectl exec -it security-context-demo-4 -- sh
```

9. 在`shell`中，查看进程`1`的状态:

```bash
$ cd /proc/1
$ cat status
```

进程的能力位图:

```
...
CapPrm:	00000000aa0435fb
CapEff:	00000000aa0435fb
...
```

进程的能力位图值解码

```bash
$ capsh --decode=00000000aa0435fb
0x00000000aa0435fb=cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_admin,cap_net_raw,cap_sys_chroot,cap_sys_time,cap_mknod,cap_audit_write,cap_setfcap
```

10. 对比两个进程的能力位图（解码后）

```
# 未配置CAP
0x00000000a80425fb=cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
# 配置CAP_NET_ADMIN和CAP_SYS_TIME
0x00000000aa0435fb=cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_admin,cap_net_raw,cap_sys_chroot,cap_sys_time,cap_mknod,cap_audit_write,cap_setfcap
```

有关常`capability`数的定义，请参阅[capability.h](https://github.com/torvalds/linux/blob/master/include/uapi/linux/capability.h) 。

**注意:** `Linux capability`常量的形式是`CAP_XXX`。
但是，当您在容器清单中列出功能时，必须忽略常量的`CAP_`部分。
例如，要添加`CAP_SYS_TIME`，请在功能列表中包含`SYS_TIME`。

### 关于进程状态值

这里我们介绍进程状态中与`Capabilities`相关的几个值:

- `CapInh`: 当前进程子进程可继承的能力
- `CapPrm`: 当前进程可使用的能力（可以包含`CapEff`中没有的能力，`CapEff`是`CapPrm`的一个子集，进程放弃没有必要的能力有利于提高安全性）
- `CapEff`: 当前进程已使用/开启的能力

> 1.非容器特权进程`CAP`缺省值解析（共计35个）

```bash
$ capsh --decode=000001ffffffffff
0x000001ffffffffff=cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,35,36,37,38,39,40
```

1. `cap_chown`: 允许修改文件所有者权限
2. `cap_dac_override`: 忽略文件的`DAC`访问权限
3. `cap_dac_read_search`: 忽略文件读及目录检索的`DAC`访问权限
4. `cap_fowner`: 忽略文件属主`ID`必须与进程用户`ID`一致的权限
5. `cap_fsetid`: 确保在文件被修改后不修改`setuid/setgid`位
6. `cap_kill`: 允许对不属于自己的进程发送信号的权限
7. `cap_setgid`: 允许修改进程的`GID`权限
8. `cap_setuid`: 允许修改进程的`UID`权限
9. `cap_setpcap`: 允许对子进程进行`CAP`授权
10. `cap_linux_immutable`: 允许修改文件的`IMMUTABLE`与`APPEND`属性权限
11. `cap_net_bind_service`: 允许绑定小于`1024`端口的权限
12. `cap_net_broadcast`: 允许网络广播及多播访问的权限
13. `cap_net_admin`: 允许执行网络管理任务的权限
14. `cap_net_raw`: 允许使用原始套接字的权限
15. `cap_ipc_lock`: 允许锁定共享内存片段的权限
16. `cap_ipc_owner`: 忽略`IPC`所有权检查的权限
17. `cap_sys_module`: 允许插入和删除内核模块的权限
18. `cap_sys_rawio`: 允许直接访问`/devport`,`/dev/mem`,`/dev/kmem`及原始块设备的权限
19. `cap_sys_chroot`: 允许使用`chroot()`系统调用的权限
20. `cap_sys_ptrace`: 允许追踪任何进程的权限
21. `cap_sys_pacct`: 允许执行进程的`BSD`式审计的权限
22. `cap_sys_admin`: 允许执行系统管理任务(如加载或卸载文件系统、设置磁盘配额等)的权限
23. `cap_sys_boot`: 允许重启系统的权限
24. `cap_sys_nice`: 允许提升优先级及设置其他进程优先级的权限
25. `cap_sys_resource`: 忽略资源限制的权限
26. `cap_sys_time`: 允许改变系统时钟的权限
27. `cap_sys_tty_config`: 允许配置`TTY`设备的权限
28. `cap_mknod`: 允许使用`mknod()`系统调用的权限
29. `cap_lease`: 允许修改文件锁的`FL_LEASE`标志的权限
30. `cap_audit_write`: 允许将记录写入内核审计日志的权限
31. `cap_audit_control`: 启用和禁用内核审计、改变审计过滤规则、检索审计状态和过滤规则的权限
32. `cap_setfcap`: 允许为可执行文件设置`CAP`的权限
33. `cap_mac_override`: 可覆盖`Mandatory Access Control`(`MAC`)的权限
34. `cap_mac_admin`: 允许`MAC`配置或状态改变的权限
35. `cap_syslog`: 允许使用`syslog()`系统调用的权限

> 2.容器特权进程默认`CAP`缺省值解析（共计14个）

借用上述例子中未配置`CAP`的进程能力位图

```
0x00000000a80425fb=cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
```

1. `cap_chown`: 允许修改文件所有者权限
2. `cap_dac_override`: 忽略文件的`DAC`访问权限
3. `cap_fowner`: 忽略文件属主`ID`必须与进程用户`ID`一致的权限
4. `cap_fsetid`: 允许设置文件`setuid`位的权限
5. `cap_kill`: 允许对不属于自己的进程发送信号的权限
6. `cap_setgid`: 允许修改进程的`GID`权限
7. `cap_setuid`: 允许修改进程的`UID`权限
8. `cap_setpcap`: 允许对子进程进行`CAP`授权
9. `cap_net_bind_service`: 允许绑定小于`1024`端口的权限
10. `cap_net_raw`: 允许使用原始套接字的权限
11. `cap_sys_chroot`: 允许使用`chroot()`系统调用的权限
12. `cap_mknod`: 允许使用`mknod()`系统调用的权限
13. `cap_audit_write`: 允许将记录写入内核审计日志的权限
14. `cap_setfcap`: 允许为可执行文件设置`CAP`的权限

对比发现，容器运行时内的`root`用户并非拥有全部权限，仅仅是默认拥有`14`条权限，其他权限如果使用需要额外开启。

> 3.查看容器非特权进程默认`CAP`缺省值（0个）

```bash
$ id
uid=1000 gid=0(root) groups=0(root)
$ cat /proc/1/status|grep CapEff
CapEff: 0000000000000000
```

> 思考一个问题: 当运行时为非特权用户，`CAP`配置是否生效？

1. `Deployment`配置如下（镜像以非特权`USER`运行）

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: eureka-app
  namespace: champ
  labels:
    app: eureka-app
    app.kubernetes.io/instance: eureka-app
  annotations:
    configmap.reloader.stakater.com/reload: eureka-app-cm
    deployment.kubernetes.io/revision: '25'
spec:
  replicas: 1
  selector:
    matchLabels:
      app: eureka-app
  template:
    metadata:
      labels:
        app: eureka-app
      annotations:
        kubesphere.io/containerSecrets: ''
    spec:
      containers:
        - name: eureka-app
          image: 'xxx.xxx.xxx/xxx/xxx:xxx'
          ports:
            - name: http-8080
              containerPort: 8080
              protocol: TCP
            - name: http-5005
              containerPort: 5005
              protocol: TCP
          securityContext:
            capabilities:
              add:
                - SYS_TIME
...
```

2. 查看进程状态

```bash
$ cat /proc/1/status
CapPrm: 0000000000000000
CapEff: 0000000000000000
```

显然当镜像指定`USER`为非特权用户运行时，`CAP`配置并不生效

### 结论

1. 当镜像指定`USER`为非特权用户运行时，`CAP`配置并不生效
2. 容器内特权进程默认拥有`14`条`CAP`权限配置，相对非容器特权进程要少的多
3. `Linux CAP`旨在将特权细粒度划分

## 参考文献

[Linux Capabilities 简介](https://www.cnblogs.com/sparkdev/p/11417781.html)
[Linux Capabilities: Why They Exist and How They Work](https://blog.container-solutions.com/linux-capabilities-why-they-exist-and-how-they-work)
