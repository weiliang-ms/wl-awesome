## cap_chown权限分析

- `cap_chown`: 允许修改文件所有者

那么让我们基于`k8s`，透过下面几个例子来验证`cap_chown`的功能

> 1.容器以`root`用户运行且使用默认`CAP`时（14个`CAP`）

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: api-server
spec:
  containers:
    - name: api-server
      image: xzxwl/api-server-demo:latest
EOF
```

测试`chown`可用性

```shell
$ kubectl exec -it api-server -- sh
/work # touch 111
/work # ls -l
total 0
-rw-r--r--    1 root     root             0 Nov  3 08:55 111
/work # chown 1000:1000 111
/work # ls -l
total 0
-rw-r--r--    1 1000     1000             0 Nov  3 08:55 111
/work # exit
```

清理测试资源

```shell
$ kubectl delete pod api-server
```

> 2.容器以`root`用户运行且取消所有`Linux CAP`时

```yaml
cat <<EOF | kubectl apply -f -
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
EOF
```

测试`chown`可用性

```shell
$ kubectl exec -it api-server -- sh
/work # touch 111
/work # ls -l
total 0
-rw-r--r--    1 root     root             0 Nov  3 08:55 111
/work # chown 1000:1000 111
chown: 111: Operation not permitted
/work # exit
```

清理测试资源

```shell
$ kubectl delete pod api-server
```

> 3.容器以`root`用户运行且取消所有`Linux CAP`，只添加`CAP_CHOWN`时

```yaml
cat <<EOF | kubectl apply -f -
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
EOF
```

测试`chown`可用性

```shell
$ kubectl exec -it api-server -- sh
/work # touch 111
/work # ls -l
total 0
-rw-r--r--    1 root     root             0 Nov  3 08:55 111
/work # chown 1000:1000 111
/work # ls -l
total 0
-rw-r--r--    1 1000     1000             0 Nov  4 01:48 111
/work # exit
```

清理测试资源

```shell
$ kubectl delete pod api-server
```