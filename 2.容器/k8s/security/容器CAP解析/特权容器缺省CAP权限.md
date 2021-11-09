# 特权容器CAP权能解析

在配置`k8s`容器的`securityContext.capabilities`字段时，不知道该排除/添加哪些`CAP`属性。

我们先了解特权容器的`14`个`CAP`字段：

> 容器特权进程默认`CAP`缺省值解析（共计14个）

```
0x00000000a80425fb=cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
```

1. `cap_chown`: 允许修改文件所有者权限
2. `cap_dac_override`: 忽略对文件的`DAC`访问权限控制
3. `cap_fowner`: 忽略文件属主`ID`必须与进程用户`ID`一致的权限
4. `cap_fsetid`: 确保在文件被修改后不修改`setuid/setgid`位
5. `cap_kill`: 允许对不属于自己的进程发送信号的权限
6. `cap_setgid`: 允许普通用户使用`setgid`函数
7. `cap_setuid`: 允许普通用户使用`setuid`函数
8. `cap_setpcap`: 允许对子进程进行`CAP`授权
9. `cap_net_bind_service`: 允许绑定小于`1024`端口的权限
10. `cap_net_raw`: 允许使用原始套接字的权限
11. `cap_sys_chroot`: 允许使用`chroot()`系统调用的权限
12. `cap_mknod`: 允许使用`mknod()`系统调用的权限
13. `cap_audit_write`: 允许将记录写入内核审计日志的权限
14. `cap_setfcap`: 允许为可执行文件设置`CAP`的权限

> `k8s`下建议关闭所有`CAP`，按需添加

基于容器的`securityContext`字段进行配置

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-server
spec:
  containers:
    - name: api-server
      image: xzxwl/api-server-demo:latest
      securityContext:
        capabilities:
          drop:
            - ALL
          add:
            - CHOWN
```

## 对CAP的操作

首先我先了解下如果对进程/可执行文件，设置/撤销`CAP`

> 可执行文件添加`CAP`属性

```shell
$ setcap cap_fowner=eip /usr/bin/vim
```

`cap_fowner=eip`是将`fowner`的能力以`cap_effective(e)`,`cap_inheritable(i)`,`cap_permitted(p)`三种位图的方式授权给`vim`.

> 查看可执行文件的`CAP`属性

```shell
$ getcap /usr/bin/vim
/usr/bin/vim = cap_fowner+eip
```

> 清空可执行文件`CAP`属性

```shell
$ setcap -r /usr/bin/vim
```

关于容器特权用户下默认的`14`条`CAP`解析如下：

- [cap_chown解析](./01cap_chown解析.md)
- [cap_dac_override解析](./02cap_dac_override解析.md)
- [cap_fowner解析](./03cap_fowner解析.md)
- [cap_fsetid解析](./04cap_fsetid解析.md)
- [cap_kill解析](./05cap_kill解析.md)
- [cap_setgid解析](./06cap_setgid解析.md)
- [cap_setuid解析](./07cap_setuid解析.md)
- [cap_net_bind_service解析](./09cap_net_bind_service解析.md)
- [cap_sys_chroot解析](./11cap_sys_chroot解析.md)
- [cap_mknod解析](./12cap_mknod解析.md)
- [cap_audit_write解析](./13cap_audit_write解析.md)


## 参考文章

- [Linux的capability深入分析](https://www.cnblogs.com/iamfy/archive/2012/09/20/2694977.html)