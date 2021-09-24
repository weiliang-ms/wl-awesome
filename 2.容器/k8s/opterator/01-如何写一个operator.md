# 如何写一个operator

文章源地址请移步[writing-a-controller-for-pod-labels](https://kubernetes.io/blog/2021/06/21/writing-a-controller-for-pod-labels/)

[样例代码](https://github.com/weiliang-ms/label-operator)

## k8s中的operator是什么？

`operator`旨在简化基于`k8s`部署有状态服务（例如：`ceph`集群、`skywalking`集群）

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

控制器是一个控制循环，它从`Kubernetes API`中读取期望的资源状态，并采取行动使集群的实际状态达到期望状态

### 安装配置

> 1.安装`Operator SDK`

- 下载二进制

```shell
sudo curl -LO https://github.com/operator-framework/operator-sdk/releases/download/v1.12.0/operator-sdk_linux_amd64
sudo mv operator-sdk_linux_amd64 /usr/local/bin/operator-sdk
```

> 2.构建工程

```shell
mkdir label-operator && cd label-operator
```

> 3.初始化工程

```shell
export GOPROXY=https://goproxy.cn
operator-sdk init --domain=weiliang.io --repo=github.com/weiliang-ms/label-operator
```

> 4.创建控制器

接下来我们创建一个控制器，这个控制器将会处理`Pod`资源，而非自定义资源，所以不需要生成资源代码。

```shell
operator-sdk create api --group=core --version=v1 --kind=Pod --controller=true --resource=false
```


### 初始化编码

> `controllers/pod_controller.go`解析

现在我们拥有了一个新文件: `controllers/pod_controller.go`。
该文件包含了`PodReconciler`类型，该类型包含两个方法：

- `Reconcile`函数：

```go
func (r *PodReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = log.FromContext(ctx)

	// your logic here

	return ctrl.Result{}, nil
}
```

当创建、更新、或删除`Pod`时会调用`Reconcile`方法，`Pod`名称与命名空间作为函数入参，存于`ctrl.Request`对象之中

- `SetupWithManager`函数：

```go
func (r *PodReconciler) SetupWithManager(mgr ctrl.Manager) error {
    return ctrl.NewControllerManagedBy(mgr).
            For(&corev1.Pod{}).
            Complete(r)
}
```

`operator`会在启动时执行`SetupWithManager`函数，`SetupWithManager`函数用于生命监听资源类型

因为我们只想要监听`Pod`资源变化，所以监听资源这部分代码不动

> `RBAC`设置

接下来为我们的控制器配置`RBAC`权限，代码生成器生成的默认权限如下：

```
//+kubebuilder:rbac:groups=core,resources=pods,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=core,resources=pods/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=core,resources=pods/finalizers,verbs=update
```

显然我们并不需要以上全部权限，我们控制器从不会`CRUD` `Pod`的`status`与`finalizers`字段。

控制器需要的仅仅是对`Pod`的读权限与更新权限，本着最小原则，我们调整权限如下

```
// +kubebuilder:rbac:groups=core,resources=pods,verbs=get;list;watch;update;patch
```

此时我们已经编写好了控制器的基本调用逻辑。

### 实现Reconcile函数

我们希望`Reconcile`实现以下功能：

1. 通过入参`ctrl.Request`中的`Pod`名称与命名空间字段，请求`k8s api`获取`Pod`对象
2. 如果`Pod`拥有`add-pod-name-label`注解，给这个`Pod`添加一个`pod-name`标签
3. 将上一步`Pod`的变更回写`k8s`中

接下来我们为注解与标签定义一些常量

```go
const (
	addPodNameLabelAnnotation = "padok.fr/add-pod-name-label"
	podNameLabel              = "padok.fr/pod-name"
)
```

> 根据入参获取`Pod`

首先我们根据入参信息，去`k8s api`获取`Pod`实例

```go
func (r *PodReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	l := log.FromContext(ctx)
	
	var pod corev1.Pod
	if err := r.Get(ctx, req.NamespacedName, &pod); err != nil {
		l.Error(err, "unable to fetch Pod")
		return ctrl.Result{}, err
	}

	return ctrl.Result{}, nil
}
```

> 异常处理

当创建、更新或删除一个`Pod`时，会触发我们控制器的`Reconcile`方法

但当事件为'删除事件'时，`r.Get()`会返回一个指定错误对象，接下来我们通过引用下面的包来处理这个异常。

```go
package controllers

import (
    // other imports...
    apierrors "k8s.io/apimachinery/pkg/api/errors"
    // other imports...
)
// other functions...
func (r *PodReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	l := log.FromContext(ctx)

	var pod corev1.Pod
	if err := r.Get(ctx, req.NamespacedName, &pod); err != nil {
		if apierrors.IsNotFound(err) {
			// we'll ignore not-found errors, since we can get them on deleted requests.
			return ctrl.Result{}, nil
		}
		l.Error(err, "unable to fetch Pod")
		return ctrl.Result{}, err
	}

	return ctrl.Result{}, nil
}
// other functions...
```

> 编辑`Pod`，判断注解、标签是否存在

此时我们已经获取到了这个`Pod`对象（创建、更新事件），接下来我们获取`Pod`的注解元数据，判断是否需要添加标签

```go
...
    /*
       Step 1: 添加或移除标签.
    */
    
    // 判断Pod是否存在注解 -> padok.fr/add-pod-name-label: true
    labelShouldBePresent := pod.Annotations[addPodNameLabelAnnotation] == "true"
    // 判断Pod是否存在标签 -> padok.fr/pod-name: Pod名称
    labelIsPresent := pod.Labels[podNameLabel] == pod.Name
    
    // 如果期望状态与实际状态一致（含有上述标签、注解），返回
    if labelShouldBePresent == labelIsPresent {
        log.Info("no update required")
        return ctrl.Result{}, nil
    }
    
    // 存在注解 -> padok.fr/add-pod-name-label: true
    if labelShouldBePresent {
    	// 判断标签map是否为空
        if pod.Labels == nil {
        	// 为空创建
            pod.Labels = make(map[string]string)
        }
        // 添加标签 -> padok.fr/pod-name: Pod名称
        pod.Labels[podNameLabel] = pod.Name
        log.Info("adding label")
    } else {
        // 不存在注解 -> padok.fr/add-pod-name-label: true
    	// 移除标签
        delete(pod.Labels, podNameLabel)
        log.Info("removing label")
    }
...
```

> 回写`Pod`至`k8s`

```go
    /*
        Step 2: Update the Pod in the Kubernetes API.
    */

    if err := r.Update(ctx, &pod); err != nil {
        l.Error(err, "unable to update Pod")
        return ctrl.Result{}, err
    }
```

当我们回写`Pod`变更至`k8s`时存在以下风险：集群内的`Pod`与我们获取到的`Pod`已经不一致（可能通过其他渠道变更了该`Pod`）

在编写一个`k8s`控制器时，我们应该明白一个问题：**我们编写的控制器并不是唯一能操作`k8s`资源对象的实例**(其他控制器、`kubectl`等亦能操作`k8s`资源对象)

当发生这种情况时，最好的做法是通过重新排队事件，从头开始处理。

```go
 if err := r.Update(ctx, &pod); err != nil {
    if apierrors.IsConflict(err) {
        // The Pod has been updated since we read it.
        // Requeue the Pod to try to reconciliate again.
        return ctrl.Result{Requeue: true}, nil
    }
    if apierrors.IsNotFound(err) {
        // The Pod has been deleted since we read it.
        // Requeue the Pod to try to reconciliate again.
        return ctrl.Result{Requeue: true}, nil
    }
    log.Error(err, "unable to update Pod")
    return ctrl.Result{}, err
}
```

### 在k8s集群内运行该控制器

本人本地开发环境为`windows10` + `Ubuntu 20`

> 本地`ubuntu`安装`Kubectl`并配置`kube-config`

集群信息

```shell
weiliang@DESKTOP-O8QG6I5:/mnt/d/github/label-operator$ kubectl get node
NAME    STATUS   ROLES           AGE   VERSION
node1   Ready    master,worker   62d   v1.18.6
node2   Ready    master,worker   62d   v1.18.6
node3   Ready    master,worker   62d   v1.18.6
node4   Ready    worker          62d   v1.18.6
```

> `label-operator`下执行

`shell`目录

```
weiliang@DESKTOP-O8QG6I5:/mnt/d/github/label-operator$ pwd
/mnt/d/github/label-operator
```

运行`operator`

```shell
export GOPROXY=https://goproxy.cn
make run
```

> 运行一个`nginx`服务`Pod`

新建一个`ubuntu shell`窗口执行

```shell
kubectl run --image=nginx:1.20.0 my-nginx
```

查看`Pod`信息

```shell
weiliang@DESKTOP-O8QG6I5:/mnt/d/github/label-operator$ kubectl get pod
NAME                                 READY   STATUS              RESTARTS   AGE
my-nginx                             1/1     Running             0          78s
```

此时运行`operator`的窗口会输出如下信息，说明监听成功

```
2021-09-24T11:52:10.588+0800    INFO    controller-runtime.manager.controller.pod       no update required      {"reconciler group": "", "reconciler kind": "Pod", "name": "m
y-nginx", "namespace": "default"}
2021-09-24T11:52:10.597+0800    INFO    controller-runtime.manager.controller.pod       no update required      {"reconciler group": "", "reconciler kind": "Pod", "name": "m
y-nginx", "namespace": "default"}
2021-09-24T11:52:10.630+0800    INFO    controller-runtime.manager.controller.pod       no update required      {"reconciler group": "", "reconciler kind": "Pod", "name": "m
y-nginx", "namespace": "default"}
```

> 查看`Pod`标签

```shell
weiliang@DESKTOP-O8QG6I5:/mnt/d/github/label-operator$ kubectl get pod my-nginx --show-labels
NAME       READY   STATUS    RESTARTS   AGE     LABELS
my-nginx   1/1     Running   0          4m38s   run=my-nginx
```

> 此时我们给该`Pod`打上以下注解，并查看是否已自动添加新的标签

```shell
weiliang@DESKTOP-O8QG6I5:/mnt/d/github/label-operator$ kubectl annotate pod my-nginx padok.fr/add-pod-name-label=true
pod/my-nginx annotated
```

查看标签

```shell
weiliang@DESKTOP-O8QG6I5:/mnt/d/github/label-operator$ kubectl get pod my-nginx --show-labels
NAME       READY   STATUS    RESTARTS   AGE     LABELS
my-nginx   1/1     Running   0          6m39s   padok.fr/pod-name=my-nginx,run=my-nginx
```

**成功了！** 我们成功的实现上面的需求