# 使用Finalizers控制k8s资源删除

> 文章引用

- [using-finalizers-to-control-deletion](https://kubernetes.io/blog/2021/05/14/using-finalizers-to-control-deletion/)

你有没有在使用`k8s`过程中遇到过这种情况: 通过`kubectl delete`指令删除一些资源时，一直处于`Terminating`状态。
这是为什么呢？

本文将介绍当你执行`kubectl delete`语句时，`K8s`内部都执行了哪些操作。
以及为何有些资源'删除不掉'(具体表现为一直`Terminating`，删除`namespace`时很容易遇到这种情况)

接下来，我们聚焦讨论以下四个方面:
1. 资源的哪些属性会对删除操作产生影响？
2. `finalizers`与`owner references`属性是如何影响删除操作的？
3. 如何利用`Propagation Policy`（分发策略）更改删除顺序？
4. 删除操作的工作原理？

方便起见，以下所有示例都将使用`ConfigMaps`和基本`shell`命令来演示该过程

## 词汇表

- 资源: `k8s`的资源对象（如`configmap`, `secret`, `pod`...）
- `finalizers`: 终结器，存放键的列表。列表内的键为空时资源才可被删除
- `owner references`: 所有者引用（归谁管理/父资源对象是谁）
- `kubectl`: `K8s`客户端工具

## 基本删除操作

`Kubernetes`提供了几个不同的命令，您可以使用它们来创建、读取、更新和删除对象。
出于本文的目的，我们将重点讨论四个`kubectl`命令:`create`、`get`、`patch`和`delete`.

> 下面是`kubectl delete`命令的基本示例

- 创建名为`mymap`的`configmap`对象

```shell
$ kubectl create configmap mymap
configmap/mymap created
```

- 查看名为`mymap`的`configmap`对象

```shell
$ kubectl get configmap/mymap
NAME    DATA   AGE
mymap   0      12s
```

- 删除名为`mymap`的`configmap`对象

```shell
$ kubectl delete configmap/mymap
configmap "mymap" deleted
```

- 查看名为`mymap`的`configmap`对象

```shell
$ kubectl get configmap/mymap
Error from server (NotFound): configmaps "mymap" not found
```

基本`delete`命令的删除操作状态图非常简单:

![](images/state-diagram-delete.png)

删除操作看似简单，但是有很多因素可能会干扰删除，包括`finalizers`与`owner references`属性

## Finalizers是什么？

上面我们提到了两个属性：`finalizers`与`owner references`可能会干扰删除操作，导致删除阻塞或失败。
那`Finalizers`是什么？会对删除有何影响呢？

当要理解`Kubernetes`中的资源删除原理时，了解`finalizers`（以下我们称`finalizers`为终结器）的工作原理是很有帮助的，
可以帮助您理解为什么有些对象无法被删除。

终结器是资源发出预删除操作信号的属性，
控制着资源的垃圾收集，并用于提示控制器在删除资源之前执行哪些清理操作。

`finalizers`本质是包含键的列表，不具有实际意义。与`annotations`（注释）类似，`finalizers`是可以被操作的（增删改）。

以下终结器您可能遇到过：
- `kubernetes.io/pv-protection`
- `kubernetes.io/pvc-protection`

这两个终结器作用于卷，以防止卷被意外删除。

> 类似地，一些终结器可用于防止资源被删除，但不由任何控制器管理。
下面是一个自定义的`configmap`，它没有具体值，但包含一个终结器:

```shell
$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mymap
  finalizers:
  - kubernetes
EOF
```

终结器通常用于名称空间(`namespace`)，而管理`configmap`资源的控制器不知道该如何处理`finalizers`字段。
下面我们尝试删除这个`configmap`对象:

```shell
$ kubectl delete configmap/mymap &
configmap "mymap" deleted
$ jobs
[1]+  Running kubectl delete configmap/mymap
```

`Kubernetes`返回该对象已被删除，然而它并没有真正意义上被删除，而是在删除的过程中。
当我们试图再次获取该对象时，我们发现该对象多了个`deletionTimestamp`(删除时间戳)字段。

```shell
$ kubectl get cm mymap -o yaml
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: "2021-09-29T11:04:40Z"
  deletionGracePeriodSeconds: 0
  deletionTimestamp: "2021-09-29T11:04:55Z"
  finalizers:
  - kubernetes
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:finalizers:
          .: {}
          v:"kubernetes": {}
    manager: kubectl
    operation: Update
    time: "2021-09-29T11:04:40Z"
  name: mymap
  namespace: default
  resourceVersion: "1378430"
  selfLink: /api/v1/namespaces/default/configmaps/mymap
  uid: 8d6ca0b1-4840-4597-8164-a63b526dbf5f
```

> 简而言之，当我们删除带有`finalizers`字段的对象时，该对象仅仅是被更新了，而不是被删除了。
这是因为`Kubernetes`获取到该对象包含终结器，通过添加`deletionTimestamp`（删除时间戳）字段将其置于只读状态（删除终结器键更新除外）。
换句话说，在删除该对象终结器之前，删除都不会完成。

接下来我们尝试通过`patch`命令删除终结器，并观察`configmap/mymap`是否会被'真正'删除。

```shell
$ kubectl patch configmap/mymap \
    --type json \
    --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'
configmap/mymap patched
```

再次检索该对象

```shell
$ kubectl get cm mymap
Error from server (NotFound): configmaps "mymap" not found
```

发现该对象已被`真正删除`，下图描述了带有`finalizers`字段的对象删除流程：

![](images/state-diagram-finalize.png)

> 总结：当您试图删除一个带有终结器的对象，它将一直处于预删除只读状态，
直到控制器删除了终结器键或使用`Kubectl`删除了终结器。一旦终结器列表为空，`Kubernetes`就可以回收该对象，并将其放入要从注册表中删除的队列中

带有`finalizers`字段的对象无法删除的原因大致如下：

- 对象存在`finalizers`，关联的控制器故障未能执行或执行`finalizer`函数`hang`住: 比如`namespace`控制器无法删除完空间内所有的对象，
特别是在使用`aggregated apiserver`时，第三方`apiserver`服务故障导致无法删除其对象。 
此时，需要会恢复第三方`apiserver `服务或移除该`apiserver`的聚合，具体选择哪种方案需根据实际情况而定。
- 集群内安装的控制器给一些对象增加了自定义`finalizers`，未删除完`fianlizers`就下线了该控制器，导致这些`fianlizers`没有控制器来移除他们。
此时，需要恢复该控制器会手动移除`finalizers`(多出现于自定义`operator`)，具体选择哪种方案根据实际情况而定。

## Owner References又是什么？

上面我们提到了两个属性：`finalizers`与`owner references`可能会干扰删除操作，导致删除阻塞或失败。
并介绍了`Finalizers`，接下来我们聊聊`Owner References`.

`Owner References`（所有者引用或所有者归属）描述了对象组之间的关系。
指定了资源彼此关联的属性，因此可以级联删除整个资源树。

> 当存在所有者引用时，将处理终结器规则。所有者引用由名称和`UID`组成

所有者引用相同名称空间内的链接资源，它还需要`UID`以使该引用生效(确保唯一)。
`Pods`通常具有对所属副本集的所有者引用。 因此，当`Deloyment`或有`StatefulSet`被删除时，子`ReplicaSet`和`Pod`将在流程中被删除。

我们通过下面的例子，来理解`Owner References`（所有者引用）的工作原理：

1. 创建`cm/mymap-parent`对象
```shell
$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mymap-parent
EOF
```
2. 获取`cm/mymap-parent`的`UID`
```shell
CM_UID=$(kubectl get configmap mymap-parent -o jsonpath="{.metadata.uid}")
```
3. 创建`cm/mymap-child`对象，并设置`ownerReferences`字段声明所有者引用（通过`kind`、`name`、`uid`字段确保选择器可以匹配到）
```shell
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mymap-child
  ownerReferences:
  - apiVersion: v1
    kind: ConfigMap
    name: mymap-parent
    uid: $CM_UID
EOF
```

即`cm/mymap-parent`为`cm/mymap-child`的父对象，此时我们删除`cm/mymap-parent`对象并观察`cm/mymap-child`对象状态

```shell
$ kubectl get cm
NAME           DATA   AGE
mymap-child    0      2m44s
mymap-parent   0      3m

$ kubectl delete cm mymap-parent
configmap "mymap-parent" deleted

$ kubectl get cm
No resources found in default namespace.
```

即我们通过删除父对象，间接删除了父对象下的所有子对象。 这种删除`k8s`中被称为`级联删除`。我们可不可以只删除父对象，而不删除子对象呢？

> 答案是: 可以的，删除时通过添加`--cascade=false`参数实现，我们通过下面的例子来验证：

```shell
$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mymap-parent
EOF

$ CM_UID=$(kubectl get configmap mymap-parent -o jsonpath="{.metadata.uid}")

$ cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mymap-child
  ownerReferences:
  - apiVersion: v1
    kind: ConfigMap
    name: mymap-parent
    uid: $CM_UID
EOF

$ kubectl delete --cascade=false configmap/mymap-parent
configmap "mymap-parent" deleted

$ kubectl get cm
NAME          DATA   AGE
mymap-child   0      107s
```

> `--cascade=false`参数实际改变了父-子资源的删除顺序，`k8s`中关于`父-子`资源删除策略有以下三种：

- `Foreground`: 子资源在父资源之前被删除(post-order)
- `Background`: 父资源在子资源之前被删除 (pre-order)
- `Orphan`: 忽略所有者引用进行删除

下面这段内容比较晦涩，没太理解：

`Keep in mind that when you delete an object and owner references have been specified,
finalizers will be honored in the process. 
This can result in trees of objects persisting, and you end up with a partial deletion. 
At that point, you have to look at any existing owner references on your objects,
as well as any finalizers, to understand what’s happening`

## 强制删除命名空间

有一种情况可能需要强制删除命名空间：

如果您已经删除了一个命名空间，并删除了它下面的所有对象，但名称空间仍然存在，一般为`Terminating`状态。
则可以通过更新名称空间的`finalize`属性来强制删除该名称空间。

- 会话1

```shell
$ kubectl proxy
```

- 会话2

```shell
$ NAMESPACE_NAME=test
cat <<EOF | curl -X PUT \
  127.0.0.1:8001/api/v1/namespaces/$NAMESPACE_NAME/finalize \
  -H "Content-Type: application/json" \
  --data-binary @-
{
  "kind": "Namespace",
  "apiVersion": "v1",
  "metadata": {
    "name": "$NAMESPACE_NAME"
  },
  "spec": {
    "finalizers": null
  }
}
EOF
```

我们应该谨慎思考是否强制删除命名空间，因为这样做可能只删除名称空间，命名空间下的其他资源删不完全，最终导致留下孤儿对象。
比如资源对象`A`存在于`ddd`命名空间，此时若强制删除`ddd`命名空间, 且对象`A`又未被删除，那么对象`A`便成了孤儿对象。

当出现孤儿对象时，可以手动重新创建名称空间，随后可以手动清理和恢复该对象。
