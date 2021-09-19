## 部署argocd

> 1.下载声明文件

- [install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)

> 2.发布

- 修改文件内镜像引用`tag`

```shell
[root@node1 ~]# grep "image:" install.sh
        image: ghcr.io/dexidp/dex:v2.27.0
        image: quay.io/argoproj/argocd:v2.0.4
        image: redis:6.2.4-alpine
        image: quay.io/argoproj/argocd:v2.0.4
        image: quay.io/argoproj/argocd:v2.0.4
        image: quay.io/argoproj/argocd:v2.0.4
```

- 发布创建

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f install.yaml
```

- 查看部署状态

```shell
[root@node1 ~]# kubectl get pod -n argocd -w
NAME                                  READY   STATUS    RESTARTS   AGE
argocd-application-controller-0       1/1     Running   0          113s
argocd-dex-server-764699868-28tmj     1/1     Running   0          113s
argocd-redis-675b9bbd9d-dtbzh         1/1     Running   0          113s
argocd-repo-server-59ffd86d98-2w7k4   1/1     Running   0          113s
argocd-server-6d66686c5c-nqfpf        1/1     Running   0          113s
```

> 3.调整服务类型为`NodePort`

```shell
kubectl -n argocd expose deployments/argocd-server --type="NodePort" --port=8080 --name=argocd-server-nodeport
```

- 获取`NodePort`

```shell
[root@node1 ~]# kubectl get service/argocd-server-nodeport -n argocd
NAME                     TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
argocd-server-nodeport   NodePort   10.233.34.101   <none>        8080:31398/TCP   87s
```

> 4.查看登录口令

```shell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d|xargs -n1 echo
```

> 5.登录

- 登录地址： http://NodeIP:31418