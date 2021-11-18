## 背景介绍

最近翻看`kubelet`源码，看到配置项的时候，发现了静态`pod`这一概念。

而本人也是使用`kubesphere`对`k8s`进行管理的，其中`kubesphere`启动`k8s`控制节点服务（控制器、调度器、`apiserver`）也是通过静态`pod`进行管理的。

由此，想学习学习静态`pod`的概念。

## 静态pod

> 什么是静态`pod`？

由`kubelet`直接管理的`pod`被称为静态`pod`

我们通常通过以下方式创建`pod`:

1. 调用`api-server`创建一个`pod`类型资源

```shell
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    role: myrole
spec:
  containers:
    - name: web
      image: nginx
      ports:
        - name: web
          containerPort: 80
          protocol: TCP
EOF
```

2. 调用`api-server`创建一个管理`pod`的控制器类型资源（如: `Deployment`、`StatefulSet`）

```shell
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
  labels:
    app: demo-app
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: demo-app
  template:
    metadata:
      labels:
        app: demo-app
    spec:
      containers:
        - name: demo-app
          image: harbor.wl.com/library/demo:da28fcb
          imagePullPolicy: Always
          args:
            - java
            - '-Xms2048m'
            - '-Xmx2048m'
            - '-jar'
            - /opt/app.jar
            - '--server.port=8080'
            - '--spring.profiles.active=dev'
          livenessProbe:
            failureThreshold: 10
            httpGet:
              path: /actuator/health
              port: 7002
              scheme: HTTP
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 10
          readinessProbe:
            failureThreshold: 10
            httpGet:
              path: /actuator/health
              port: 7002
              scheme: HTTP
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 10
          ports:
            - containerPort: 8080
              name: http-8080
              protocol: TCP
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      serviceAccount: default
      serviceAccountName: default
      terminationGracePeriodSeconds: 30
EOF
```

实际调用流程大致为：`kubectl` -> `apiserver` -> `pod`配置清单写入`etcd`后，调用`scheduler`获取调度节点，将调度信息写入`etcd` -> 通知`Kubelet`进行创建 -> 调用容器运行时创建容器

而静态`pod`的创建流程非常简单: `kubelet` -> 调用容器运行时创建容器

> 那么请思考一个问题: `kubelet`直接管理的`Pod`为什么还能通过`apiserver`获取到？

这里我们举个例子：

`kube-apiserver`、`kube-controller-manager`、`kube-scheduler`通过以静态`pod`的方式创建。

```shell
$ kubectl get pod -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-7b4d558c97-qnbw4   1/1     Running   4          91d
calico-node-dwh57                          1/1     Running   4          91d
coredns-7bc876b67f-l99ls                   1/1     Running   4          91d
coredns-7bc876b67f-pdfpn                   1/1     Running   4          91d
kube-apiserver-node1                       1/1     Running   12         91d
kube-controller-manager-node1              1/1     Running   13         91d
kube-proxy-rwcw9                           1/1     Running   8          91d
kube-scheduler-node1                       1/1     Running   14         91d
metrics-server-784d57f6c7-l2svw            1/1     Running   10         91d
nodelocaldns-648pv                         1/1     Running   6          91d
snapshot-controller-0                      1/1     Running   4          91d
```

我们看下`apiserver`的`pod`描述，`Controlled By`说明了该`pod`由`Node/node1`管理

```shell
$ kubectl describe pod kube-apiserver-node1 -n kube-system
Name:                 kube-apiserver-node1
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 node1/192.168.1.1
Start Time:           Sat, 23 Oct 2021 21:52:41 +0800
Labels:               component=kube-apiserver
                      tier=control-plane
Controlled By:  Node/node1
...
```

我们看下`coredns pod`的描述，作下对比。（很明显`coredns pod`由`ReplicaSet`控制器管理）

```shell
$ kubectl describe pod coredns-7bc876b67f-l99ls -n kube-system
Name:                 coredns-7bc876b67f-l99ls
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 node1/x.x.x.x
Start Time:           Tue, 17 Aug 2021 13:32:32 +0800
Labels:               k8s-app=kube-dns
                      pod-template-hash=7bc876b67f
Annotations:          cni.projectcalico.org/podIP: 10.233.90.198/32
                      cni.projectcalico.org/podIPs: 10.233.90.198/32
Status:               Running
IP:                   10.233.90.198
IPs:
  IP:           10.233.90.198
Controlled By:  ReplicaSet/coredns-7bc876b67f
...
```

回到上述问题：`kubelet`直接管理的`Pod`为什么还能通过`apiserver`获取到？

因为`kubelet`会为每个它管理的静态`pod`，调用`api-server`创建一个对应的`pod`镜像。
由此以来，静态`pod`也能通过`kubectl`等方式进行访问，与其他控制器创建出来的`pod`看起来没有什么区别。

> 如何使用静态`pod`？

通过`kubelet`进行配置: 

- `/var/lib/kubelet/config.yaml`为`kubelet`配置文件（启动时通过`--config=/var/lib/kubelet/config.yaml`指定）
- `staticPodPath`字段为静态`pod`路径

```shell
$ cat /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
clusterDNS:
- 169.254.25.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionHard:
  memory.available: 5%
evictionMaxPodGracePeriod: 120
evictionPressureTransitionPeriod: 30s
evictionSoft:
  memory.available: 10%
evictionSoftGracePeriod:
  memory.available: 2m
featureGates:
  CSINodeInfo: true
  ExpandCSIVolumes: true
  RotateKubeletClientCertificate: true
  VolumeSnapshotDataSource: true
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
kubeReserved:
  cpu: 200m
  memory: 250Mi
maxPods: 300
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
systemReserved:
  cpu: 200m
  memory: 250Mi
volumeStatsAggPeriod: 0s
```

> 我们看下`/etc/kubernetes/manifests`路径下静态`Pod`配置

实际上就是我们前文例子中的：`kube-apiserver`、`kube-controller-manager`、`kube-scheduler`服务

```shell
$ ls /etc/kubernetes/manifests
kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```

`kube-controller-manager.yaml`文件内容:

```shell
$ cat /etc/kubernetes/manifests/kube-controller-manager.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-controller-manager
    tier: control-plane
  name: kube-controller-manager
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-controller-manager
    - --allocate-node-cidrs=true
    - --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --bind-address=0.0.0.0
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --cluster-cidr=10.233.64.0/18
    - --cluster-name=cluster.local
    - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
    - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
    - --controllers=*,bootstrapsigner,tokencleaner
    - --experimental-cluster-signing-duration=87600h
    - --feature-gates=CSINodeInfo=true,VolumeSnapshotDataSource=true,ExpandCSIVolumes=true,RotateKubeletClientCertificate=true
    - --kubeconfig=/etc/kubernetes/controller-manager.conf
    - --leader-elect=true
    - --node-cidr-mask-size=24
    - --port=10252
    - --profiling=False
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --root-ca-file=/etc/kubernetes/pki/ca.crt
    - --service-account-private-key-file=/etc/kubernetes/pki/sa.key
    - --service-cluster-ip-range=10.233.0.0/18
    - --use-service-account-credentials=true
    image: kubesphere/kube-controller-manager:v1.18.6
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        path: /healthz
        port: 10257
        scheme: HTTPS
      initialDelaySeconds: 15
      timeoutSeconds: 15
    name: kube-controller-manager
    resources:
      requests:
        cpu: 200m
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/pki
      name: etc-pki
      readOnly: true
    - mountPath: /usr/libexec/kubernetes/kubelet-plugins/volume/exec
      name: flexvolume-dir
    - mountPath: /etc/localtime
      name: host-time
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
    - mountPath: /etc/kubernetes/controller-manager.conf
      name: kubeconfig
      readOnly: true
  hostNetwork: true
  priorityClassName: system-cluster-critical
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/pki
      type: DirectoryOrCreate
    name: etc-pki
  - hostPath:
      path: /usr/libexec/kubernetes/kubelet-plugins/volume/exec
      type: DirectoryOrCreate
    name: flexvolume-dir
  - hostPath:
      path: /etc/localtime
      type: ""
    name: host-time
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /etc/kubernetes/controller-manager.conf
      type: FileOrCreate
    name: kubeconfig
status: {}
```

## 参考文章

[Create static Pods](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)


