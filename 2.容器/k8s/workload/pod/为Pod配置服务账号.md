[Configure Service Accounts for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

服务帐户为在`Pod`中运行的进程提供标识。

当访问`k8s`集群(例如，使用`kubectl`)时，`kube-apiserver`将对用户帐户(目前通常是`admin`帐户)进行认证鉴权。

而当`Pod`内容器中的进程访问`kube-apiserver`时，是通过特定的服务帐户(例如，`default`)进行身份验证。


## 使用默认的服务账号访问apiserver

在创建`pod`时，如果没有指定服务帐户，会在`pod`所在名称空间中自动为它分配默认的服务帐户。

可以通过以下命令查询`pod`的服务账号：

```bash
$ kubectl get pod redis-0 -n ddd -o yaml|grep serviceAccountName
        f:serviceAccountName: {}
  serviceAccountName: default
```

您可以使用自动挂载的服务帐户凭据从`pod`内部访问`API`，如访问集群中所述。
服务帐户的`API`权限取决于使用的授权插件和授权策略。

