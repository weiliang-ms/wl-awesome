## 为Pod配置安全上下文

[set-the-security-context-for-a-pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod)

通过在`Pod`声明中添加`securityContext`字段，为`Pod`指定安全设置。

`securityContext`字段是一个`PodSecurityContext`对象。

为`Pod`指定的安全设置适用于`Pod`中的所有容器。下面是一个`Pod`的配置文件，它包含一个`securityContext`和一个`emptyDir`卷:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /data/demo
    securityContext:
      allowPrivilegeEscalation: false
```

创建`Pod`

```yaml
kubectl apply -f https://k8s.io/examples/pods/security/security-context.yaml
```

针对上述配置，说明如下：
- `runAsUser: 1000`: 指定`Pod`中的所有容器内进程`UID`为`1000`
- `runAsGroup: 3000`: 指定`Pod`中的所有容器内进程`GID`为`3000`，如果省略该字段`GID`将为`root(0)`

验证进程所属用户:

```bash
$ kubectl exec -it security-context-demo -- sh
/ $ ps -ef|grep sleep
    1 1000      0:00 sleep 1h
   23 1000      0:00 grep sleep
/ $
```

当指定`runAsGroup`时，新建文件权限为：`1000:3000`。

由于指定了`fsGroup`字段，因此容器中的`volume /data/demo`和在该卷中创建的任何文件的所有者将是`GID 2000`。

```bash
/ $ ls -l /data/
total 0
drwxrwsrwx    2 root     2000             6 Oct 27 02:35 demo
```

新建文件，并查看文件权限

```bash
/data $ cd demo
/data/demo $ echo hello > testfile
/data/demo $ ls -l
total 4
-rw-r--r--    1 1000     2000             6 Oct 27 06:34 testfile
```

查看当前会话用户

```bash
/ $ id
uid=1000 gid=3000 groups=2000
```

返回值中`gid`是`3000`，与`runAsGroup`字段相同。

如果省略了`runAsGroup`，则`gid`将保持为`0`(根)，并且进程将能够与根(`0`)组拥有的文件交互，这些文件具有根(0)组所需的组权限。

**注意：** `fsGroup`针对`emptyDir`类型卷生效。