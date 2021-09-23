# 如何写一个operator

文章源地址
- [writing-a-controller-for-pod-labels](https://kubernetes.io/blog/2021/06/21/writing-a-controller-for-pod-labels/)

## k8s中的operator是什么？

`operator`旨在简化基于`k8s`部署有状态服务（例如：`ceph`集群）

可以利用[Operator SDK](https://sdk.operatorframework.io/) 构建一个`operator`，
`operator`使扩展`k8s`及实现自定义调度变得更加简单。

尽管[Operator SDK](https://sdk.operatorframework.io/) 适合构建功能齐全的`operator`，
但也可以使用它来编写单个控制器。

这篇文章将指导您在`Go`中编写一个`Kubernetes`控制器，该控制器将向具有特定注释的`pod`添加`pod-name`标签

## 为什么我们需要一个控制器呢？

最近我们项目中有这么个需求：通过一个`service`将流量路由至同一`ReplicaSet`中指定`pod`内（`service`对应一个或多个`pod`）

而原生`k8s`并不能实现该功能，因为原生`service`只能通过`label`与`Pod`匹配，并且同一`ReplicaSet`内，`Pod`具有相同标签。

上述需求有两种解决方案:
1. 创建`service`时不指定标签选择器，而是利用`Endpoints`或`EndpointSlices`关联`pod`
此时我们需要写一个自定义控制器，用于插入指定`pod`的端点地址至`Endpoints`或`EndpointSlices`对象
2. 为每个`Pod`添加具有唯一`value`的标签，接下来我们就可以利用标签选择器进行`service`与`Pod`的关联。

---

由于`k8s`中的控制器实质是个控制循环程序，控制器可以对`k8s`的资源（Resource，比如namespace、service等）进行监听追踪。

此时如果我们创建一个控制器，仅监听`Pod`资源，针对指定`Pod`进行`label`处理，就可实现上述需求。

当然`k8s`原生资源`StatefulSets`也是可以实现这一功能的，但假设我们不想/不能使用`StatefulSets`类型去实现呢？

一般情况下，我们很少直接创建`Pod`类型，而是通过`Deployment, ReplicaSet`间接创建`Pod`。

我们可以指定标签添加到`PodSpec`中的每个`Pod`，但不能使用动态值，因此无法复制`StatefulSet`的`pod-name`标签。

我们尝试使用[mutating admission webhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook)
实现。
当任何人创建`Pod`时，`webhook`会自动注入一个包含`Pod`名称的标签对`Pod`进行修改。

遗憾的是这种方式并不能实现我们的需求： 并不是所有的`Pod`在创建前都有名字。
举个例子：当`ReplicaSet`控制器创建一个`Pod`时，他向`kube-apiserver`发送一个请求，获取一个`namePrefix`而非`name`

`kubeapi-server`在将新的`Pod`持久化到`etcd`之前生成一个唯一的名称，
这个过程发生于在调用我们的许可`webhook`之后。所以在大多数情况下，我们无法知道一个带有`mutating webhook`的`Pod`的名字

一旦`Pod`持久化至`K8s`集群中时，它几乎不会发生变更，但我们仍然可以通过以下方式，添加`label`

```shell
kubectl label my-pod my-label-key=my-label-value
```

我们需要观察`Kubernetes API`中任何`Pod`的变化，并添加我们想要的标签。
我们将编写一个控制器来为我们做这件事，而不是手动做这件事

## 利用Operator SDK构建一个控制器

控制器是一个协调循环，它从`Kubernetes API`中读取期望的资源状态，并采取行动使集群的实际状态达到期望状态

> 安装`Operator SDK`

- 下载二进制

```shell
sudo curl -LO https://github.com/operator-framework/operator-sdk/releases/download/v1.12.0/operator-sdk_linux_amd64
sudo mv operator-sdk_linux_amd64 /usr/local/bin/operator-sdk
```

> 构建工程

```shell
mkdir label-operator && cd label-operator
```

> 初始化工程

```shell
export GOPROXY=https://goproxy.cn
operator-sdk init --domain=weiliang.io --repo=github.com/weiliang-ms/label-operator
```

> 创建控制器

接下来我们创建一个控制器，这个控制器将会处理`Pod`资源，而非自定义资源，所以不需要生成资源代码。

```shell
operator-sdk create api --group=core --version=v1 --kind=Pod --controller=true --resource=false
```

We now have a new file: controllers/pod_controller.go. 
This file contains a PodReconciler type with two methods that we need to implement. 
The first is Reconcile, and it looks like this for now:

现在我们拥有了一个新文件: `controllers/pod_controller.go`。
该文件包含了`PodReconciler`类型，该类型包含两个方法：

- `Reconcile`方法：

```go
func (r *PodReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = log.FromContext(ctx)

	// your logic here

	return ctrl.Result{}, nil
}
```

The Reconcile method is called whenever a Pod is created, updated, or deleted. 

当创建、更新、或删除`Pod`时会调用`Reconcile`方法，`Pod`

The name and namespace of the Pod are in the ctrl.Request the method receives as a parameter.

- 