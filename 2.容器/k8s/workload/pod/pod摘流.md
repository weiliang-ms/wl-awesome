# pod摘流

## 需求背景

针对Deployment的某一故障pod，进行流量摘除并保留该pod用于后续异常排查

## 摘除流程

### 注册中心下线

适用于：服务间通过注册中心调用

调用注册中心接口，完成应用下线。如不下线注册中心，其他服务仍有调用到该故障节点的可能

### endpoint列表剔除

适用于：服务间通过k8s service调用(dns寻址)

为方便说明我们新建三副本deployment

```yaml
$ cat << EOF | kubectl apply -f -
kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    app: nginx-sample
  name: nginx-sample
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-sample
  template:
    metadata:
      labels:
        app: nginx-sample
    spec:
      containers:
        - name: nginx
          image: nginx:latest
---
kind: Service
apiVersion: v1
metadata:
  name: nginx-sample-svc
  labels:
    app: nginx-sample
spec:
  ports:
    - name: nginx
      protocol: TCP
      port: 80
      targetPort: 80
  selector:
    app: nginx-sample
  type: ClusterIP
EOF
```

此时副本详情信息为

```shell
$ kubectl get pod -o wide -l app=nginx-sample -w
NAME                            READY   STATUS    RESTARTS   AGE     IP              NODE      NOMINATED NODE   READINESS GATES
nginx-sample-866788fc6d-cdflv   1/1     Running   0          3m56s   10.233.94.226   node108   <none>           <none>
nginx-sample-866788fc6d-v6hr5   1/1     Running   0          9m35s   10.233.120.37   node110   <none>           <none>
nginx-sample-866788fc6d-w2dqr   1/1     Running   0          9m35s   10.233.254.69   node109   <none>           <none>
```

服务端点列表

```shell
$ kubectl describe svc nginx-sample-svc
Name:              nginx-sample-svc
Namespace:         default
Labels:            app=nginx-sample
Annotations:       <none>
Selector:          app=nginx-sample
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.233.43.127
IPs:               10.233.43.127
Port:              nginx  80/TCP
TargetPort:        80/TCP
Endpoints:         10.233.120.37:80,10.233.254.69:80,10.233.94.226:80
Session Affinity:  None
Events:            <none>
```

此时我们假设`nginx-sample-866788fc6d-cdflv`副本节点异常（即`10.233.94.226`），需要摘除流量

1. 修改异常pod标签

```shell
$ kubectl label pod nginx-sample-866788fc6d-cdflv app=nginx-sample-debug --overwrite
```

修改标签由`app=nginx-sample`变为`app=nginx-sample-debug`

2. 再次查看pod列表

```shell
$ kubectl get pod -o wide -l app=nginx-sample -w
NAME                            READY   STATUS    RESTARTS   AGE   IP              NODE      NOMINATED NODE   READINESS GATES
nginx-sample-866788fc6d-v6hr5   1/1     Running   0          16m   10.233.120.37   node110   <none>           <none>
nginx-sample-866788fc6d-w2dqr   1/1     Running   0          16m   10.233.254.69   node109   <none>           <none>
nginx-sample-866788fc6d-w7p7t   1/1     Running   0          49s   10.233.94.36    node108   <none>           <none>
```

查看服务列表

```shell
$ kubectl describe svc nginx-sample-svc
Name:              nginx-sample-svc
Namespace:         default
Labels:            app=nginx-sample
Annotations:       <none>
Selector:          app=nginx-sample
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.233.43.127
IPs:               10.233.43.127
Port:              nginx  80/TCP
TargetPort:        80/TCP
Endpoints:         10.233.120.37:80,10.233.254.69:80,10.233.94.36:80
Session Affinity:  None
Events:            <none>
```

此时我们发现异常副本节点被剔除，并生成一个新的副本节点

3. debug异常pod节点

由于异常`pod`变更了标签，此时它变为了一个孤儿pod，即没有父控制器进行生命周期管理，我们可以通过标签过滤出来

```shell
$ kubectl get pod -l app=nginx-sample-debug
```

debug完毕后，通过以下指令进行删除操作

```shell
$ kubectl delete pod -l app=nginx-sample-debug
```


