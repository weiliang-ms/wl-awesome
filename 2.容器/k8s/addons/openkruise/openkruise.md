## 安装（离线）

1. 下载[最新chart](https://github.com/openkruise/charts/releases)
2. 下载镜像上传至私有镜像库

```shell
$ docker pull openkruise/kruise-manager:v1.2.0
$ docker tag openkruise/kruise-manager:v1.2.0 harbor.wl.io/openkruise/kruise-manager:v1.2.0
$ docker push harbor.wl.io/openkruise/kruise-manager:v1.2.0
```

3. 离线安装

```shell
$ helm install openkruise kruise-1.2.0.tgz \
--set manager.image.repository=harbor.wl.io/openkruise/kruise-manager:v1.2.0
```

4. 观察部署状态

```shell
$ kubectl get pod -n kruise-system -w
NAME                                        READY   STATUS              RESTARTS   AGE
kruise-controller-manager-6d5fdbbb4-7m9wx   0/1     Running             0          11s
kruise-controller-manager-6d5fdbbb4-8cjjh   0/1     Running             0          11s
kruise-daemon-4q7qv                         1/1     Running             0          11s
kruise-daemon-5m252                         0/1     ContainerCreating   0          11s
kruise-daemon-zmjbx                         0/1     ContainerCreating   0          11s
kruise-daemon-zmjbx                         1/1     Running             0          12s
```

