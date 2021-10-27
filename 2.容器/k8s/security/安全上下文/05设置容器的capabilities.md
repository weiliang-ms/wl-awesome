## 设置容器的capabilities

[Set capabilities for a Container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container)

基于[Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) ，您可以授予某个进程某些特权，而不授予`root`用户的所有特权。

要为容器添加或删除`Linux`功能，请在容器清单的`securityContext`部分中包含`capability`字段。

> 首先，看看未设置`capability`字段时会发生什么。下面是不添加或删除任何`Container capability`的配置文件:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-3
spec:
  containers:
  - name: sec-ctx-3
    image: gcr.io/google-samples/node-hello:1.0
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

6. 记下能力位图，然后退出`shell`:

```bash
$ exit
```

接下来，运行一个与前一个容器相同的容器，只是它有额外的功能集。

7. 运行一个配置增加了`CAP_NET_ADMIN`和`CAP_SYS_TIME`功能的`Pod`:

```bash
cat <<EOF kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-4
spec:
  containers:
  - name: sec-ctx-4
    image: gcr.io/google-samples/node-hello:1.0
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

10. 比较两个`Pod`容器的能力位图

```
# 未配置任何能力
CapPrm:	00000000a80425fb
CapEff:	00000000a80425fb

# 配置了`CAP_NET_ADMIN`和`CAP_SYS_TIME`
CapPrm:	00000000aa0435fb
CapEff:	00000000aa0435fb
```

在第一个容器的能力位图中，第`12`位和第`25`位未被设置。

在第二个容器中，位`12`和位`25`被设置。第`12`位是`CAP_NET_ADMIN`，第`25`位是`CAP_SYS_TIME`。

有关常`capability`数的定义，请参阅[capability.h](https://github.com/torvalds/linux/blob/master/include/uapi/linux/capability.h) 。

**注意:** `Linux capability`常量的形式是`CAP_XXX`。
但是，当您在容器清单中列出功能时，必须忽略常量的`CAP_`部分。
例如，要添加`CAP_SYS_TIME`，请在功能列表中包含`SYS_TIME`。