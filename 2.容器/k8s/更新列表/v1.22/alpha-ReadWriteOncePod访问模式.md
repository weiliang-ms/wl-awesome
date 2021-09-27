- [卷的ReadWriteOncePod访问模式](#%E5%8D%B7%E7%9A%84readwriteoncepod%E8%AE%BF%E9%97%AE%E6%A8%A1%E5%BC%8F)
  - [ReadWriteOncePod是什么？有何应用场景？](#readwriteoncepod%E6%98%AF%E4%BB%80%E4%B9%88%E6%9C%89%E4%BD%95%E5%BA%94%E7%94%A8%E5%9C%BA%E6%99%AF)
  - [ReadWriteOncePod原理](#readwriteoncepod%E5%8E%9F%E7%90%86)
  - [对比ReadWriteOnce访问模式](#%E5%AF%B9%E6%AF%94readwriteonce%E8%AE%BF%E9%97%AE%E6%A8%A1%E5%BC%8F)
  - [我们如何使用ReadWriteOnce？](#%E6%88%91%E4%BB%AC%E5%A6%82%E4%BD%95%E4%BD%BF%E7%94%A8readwriteonce)
    - [使用样例](#%E4%BD%BF%E7%94%A8%E6%A0%B7%E4%BE%8B)
    - [变更现有卷访问模式为ReadWriteOnce](#%E5%8F%98%E6%9B%B4%E7%8E%B0%E6%9C%89%E5%8D%B7%E8%AE%BF%E9%97%AE%E6%A8%A1%E5%BC%8F%E4%B8%BAreadwriteonce)
    - [哪些卷插件支持ReadWriteOncePod？](#%E5%93%AA%E4%BA%9B%E5%8D%B7%E6%8F%92%E4%BB%B6%E6%94%AF%E6%8C%81readwriteoncepod)
  - [作为CSI提供者，如何支持ReadWriteOncePod？](#%E4%BD%9C%E4%B8%BAcsi%E6%8F%90%E4%BE%9B%E8%80%85%E5%A6%82%E4%BD%95%E6%94%AF%E6%8C%81readwriteoncepod)
  
# 卷的ReadWriteOncePod访问模式

[Introducing Single Pod Access Mode for PersistentVolumes](https://kubernetes.io/blog/2021/09/13/read-write-once-pod-access-mode-alpha/)

`Author: Chris Henzie (Google)`

随着`Kubernetes v1.22`版本的更新，`k8s`为我们带来了一个新的`alpha`特性：存储卷新的访问方式 -> `ReadWriteOncePod`（单`Pod`访问类型的`pv`与`pvc`），换句话来讲，
指定`pvc`访问类型为`ReadWriteOncePod`时，仅有一个`Pod`可以访问使用该`pvc`（持化卷声明）

## ReadWriteOncePod是什么？有何应用场景？

当我们使用存储的时候，有很多不同的消费存储模式：

- 多节点读写：如通过网络共享的文件系统（NFS、Cephfs）
- 单节点读写：高度敏感的存储数据
- 多点只读

在`k8s`世界，可通过对存储卷（pv、pvc）指定`Access Modes`（访问模式），实现对存储的消费方式。

如多节点读写：

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: shared-cache
spec:
  accessModes:
  - ReadWriteMany # Allow many pods to access shared-cache simultaneously.
  resources:
    requests:
      storage: 1Gi
```

`Kubernetes v1.22`版本之前，对存储卷有三种方式：

1. `ReadWriteOnce`：单节点读写
2. `ReadOnlyMany` ：多节点只读
3. `ReadWriteMany`：多节点读写

以上三种对存储卷访问方式的控制，是通过`kube-controller-manager`和`kubelet`组件实现。

## ReadWriteOncePod原理

`Kubernetes v1.22`提供了第四种访问`PV、PVC`的访问模式：`ReadWriteOncePod`（单一Pod访问方式）

当你创建一个带有`pvc`访问模式为`ReadWriteOncePod`的`Pod A`时，`Kubernetes`确保整个集群内只有一个`Pod`可以读写该`PVC`。

此时如果你创建`Pod B`并引用了与`Pod A`相同的`PVC`(ReadWriteOncePod)时，那么`Pod B`会由于该`pvc`被`Pod A`引用而启动失败。

---

`Pod B`事件可能如下：

```yaml
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  1s    default-scheduler  0/1 nodes are available: 1 node has pod using PersistentVolumeClaim with the same name and ReadWriteOncePod access mode.
```

乍一看，是不是觉得与`ReadWriteOnce`访问模式很像？但其实并不一样。

## 对比ReadWriteOnce访问模式

- `ReadWriteOnce`：该访问模式约束仅有一个`node`节点可以访问`pvc`。换句话来说，同一`node`节点的不同`pod`是可以对同一`pvc`进行读写的

这种访问模式对于一些应用是存在隐患的，特别是对数据有写入安全（同一时间仅有一个写操作）要求的应用。

`ReadWriteOncePod`的出现，解决了上述隐患。

## 我们如何使用ReadWriteOnce？

`ReadWriteOncePod`方式模式是`Kubernetes v1.22`版本的`alpha`特性，并且只支持`CSI`类型的卷

1. `k8s`版本需为`v1.22+`
2. 首先需要`k8s`集群需添加该特性门控（`k8s`中`alpha`功能特性默认关闭，`beta`功能特性默认开启）

涉及服务组件:
- `kube-apiserver`
- `kube-scheduler`
- `kubelet`

```shell
--feature-gates="...,ReadWriteOncePod=true"
```

2. 升级`csi`边车，版本要求如下：
- `csi-provisioner:v3.0.0+`
- `csi-attacher:v3.3.0+`
- `csi-resizer:v1.3.0+`

### 使用样例

- `pvc`声明样例

```shell
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: single-writer-only
spec:
  accessModes:
  - ReadWriteOncePod # Allow only a single pod to access single-writer-only.
  resources:
    requests:
      storage: 1Gi
```

如果您的存储插件支持动态配置（`StorageClass`），那么将使用`ReadWriteOncePod`访问模式创建新的`PersistentVolumes`

### 变更现有卷访问模式为ReadWriteOnce

您可以变更现有`PVC`访问模式为`ReadWriteOncePod`访问模式。接下来我们通过一个迁移样例，了解迁移的流程。

样例信息：
- `pv`: `cat-pictures-pv`
- `pvc`: `cat-pictures-pvc`
- `Deployment`: `cat-pictures-writer`
- 命名空间: `default`

三者关系为：名为`cat-pictures-writer`的`Deployment`，声明挂载了一个名为`cat-pictures-pvc`的`pvc`，该`pvc`对应的`pv`
为`cat-pictures-pv`

> step1: 变更pv回收策略

变更`cat-pictures-pv`的回收策略为`Retain`，确保删除`pvc`时，对应的`pv`不会被删除

```shell
kubectl patch pv cat-pictures-pv -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

> step2: 停止`Deployment`下所有工作负载（缩容至0）

```shell
kubectl scale --replicas=0 deployment cat-pictures-writer
```

> step3: 删除`cat-pictures-pvc`

```shell
kubectl delete pvc cat-pictures-pvc
```

> step4: 清理`cat-pictures-pv`的`spec.claimRef.uid`属性，确保重新创建`pvc`时可以绑定新的`pvc`

```shell
kubectl patch pv cat-pictures-pv -p '{"spec":{"claimRef":{"uid":""}}}'
```

> step5: 变更`cat-pictures-pv`的访问模式为`ReadWriteOncePod`

```shell
kubectl patch pv cat-pictures-pv -p '{"spec":{"accessModes":["ReadWriteOncePod"]}}'
```

> **注意**：`ReadWriteOncePod`不能与其他访问模式结合使用，确保`ReadWriteOncePod`是`PV`的唯一访问模式，否则无法成功绑定。

> step6: 变更`cat-pictures-pvc`的访问模式为`ReadWriteOncePod`(且唯一)

- 未配置`StorageClass`情况需手动创建`pvc`

```shell
kubectl apply -f cat-pictures-pvc.yaml
kubectl apply -f cat-pictures-writer-deployment.yaml
```

- 若配置`StorageClass`仅需变更`Deployment`中的`pvc`访问模式

> step7: 变更`PV`回收方式由`Retain`为`Delete`

```shell
kubectl patch pv cat-pictures-pv -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
```

> step8: 恢复`cat-pictures-writer`工作负载实例数

```shell
kubectl scale --replicas=1 deployment cat-pictures-writer
```

### 哪些卷插件支持ReadWriteOncePod？

只有`CSI`类型存储驱动支持，原生卷插件（如`Hostpath`）并不支持`ReadWriteOncePod`模式， 因为原生卷插件作为`CSI`迁移的一部分正在被弃用，
当`ReadWriteOncePod`达到`beta`版本时，原生卷插件可能会被`k8s`原生支持。

绝大多数生产环境，都会使用第三方`CSI`插件（`Ceph CSI`），很少会使用原生卷插件类型。

## 作为CSI提供者，如何支持ReadWriteOncePod？

请移步[原文section](https://kubernetes.io/blog/2021/09/13/read-write-once-pod-access-mode-alpha/#as-a-storage-vendor-how-do-i-add-support-for-this-access-mode-to-my-csi-driver)
