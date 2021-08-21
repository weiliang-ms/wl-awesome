## csi简介

`Kubernetes`从`1.9`版本开始引入容器存储接口`Container Storage Interface`（CSI）机制，用于在`Kubernetes`和外部存储系统之间建立一套标准的存储管理接口，通过该接口为容器提供存储服务。

> csi设计背景

`Kubernetes`通过`PV`、`PVC`、`Storageclass`已经提供了一种强大的基于插件的存储管理机制，
但是各种存储插件提供的存储服务都是基于一种被称为`in-true`（树内）的方式提供的，
这要求存储插件的代码必须被放进`Kubernetes`的主干代码库中才能被`Kubernetes`调用，
属于紧耦合的开发模式。这种`in-tree`方式会带来一些问题：

- 存储插件的代码需要与`Kubernetes`的代码放在同一代码库中，并与`Kubernetes`的二进制文件共同发布
- 存储插件代码的开发者必须遵循`Kubernetes`的代码开发规范
- 存储插件代码的开发者必须遵循`Kubernetes`的发布流程，包括添加对`Kubernetes`存储系统的支持和错误修复
- `Kubernetes`社区需要对存储插件的代码进行维护，包括审核、测试等工作
- 存储插件代码中的问题可能会影响`Kubernetes`组件的运行，并且很难排查问题
- 存储插件代码与`Kubernetes`的核心组件（kubelet和kubecontroller-manager）享有相同的系统特权权限，可能存在可靠性和安全性问题。
- 部署第三方驱动的可执行文件仍然需要宿主机的`root`权限，存在安全隐患
- 存储插件在执行`mount`、`attach`这些操作时，通常需要在宿主机上安装一些第三方工具包和依赖库，
  使得部署过程更加复杂，例如部署`Ceph`时需要安装`rbd`库，部署`GlusterFS`时需要安装`mount.glusterfs`库，等等

基于以上这些问题和考虑，`Kubernetes`逐步推出与容器对接的存储接口标准，存储提供方只需要基于标准接口进行存储插件的实现，就能使用`Kubernetes`的原生存储机制为容器提供存储服务。这套标准被称为`CSI`（容器存储接口）。

在`CSI`成为`Kubernetes`的存储供应标准之后，存储提供方的代码就能和`Kubernetes`代码彻底解耦，部署也与`Kubernetes`核心组件分离，显然，存储插件的开发由提供方自行维护，就能为`Kubernetes`用户提供更多的存储功能，也更加安全可靠。

基于`CSI`的存储插件机制也被称为`out-of-tree`（树外）的服务提供方式，是未来`Kubernetes`第三方存储插件的标准方案。

> `csi`架构

`KubernetesCSI`存储插件的关键组件和推荐的容器化部署架构：

![](images/csi-artitechture.png)


### CSI Controller

`CSI Controller`的主要功能是提供存储服务视角对存储资源和存储卷进行管理和操作。
在`Kubernetes`中建议将其部署为单实例`Pod`，可以使用`StatefulSet`或`Deployment`控制器进行部署，设置副本数量为1，保证为一种存储插件只运行一个控制器实例。
在这个`Pod`内部署两个容器：
- 与`Master`（kube-controller-manager）通信的辅助`sidecar`容器。在`sidecar`容器内又可以包含`external-attacher`和`external-provisioner`两个容器，它们的功能分别如下:
    - `external-attacher`：监控`VolumeAttachment`资源对象的变更，触发针对`CSI`端点的`ControllerPublish`和`ControllerUnpublish`操作。
    - `external-provisioner`：监控`PersistentVolumeClaim`资源对象的变更，触发针对`CSI`端点的`CreateVolume`和`DeleteVolume`操作。
- `CSI Driver`存储驱动容器，由第三方存储提供商提供，需要实现上述接口。

这两个容器通过本地`Socket`（Unix DomainSocket，UDS），并使用`gPRC`协议进行通信。
`sidecar`容器通过`Socket`调用`CSI Driver`容器的`CSI`接口，`CSI Driver`容器负责具体的存储卷操作。

### CSI Node

`CSI Node`的主要功能是对主机（Node）上的`Volume`进行管理和操作。在`Kubernetes`中建议将其部署为`DaemonSet`，在每个`Node`上都运行一个`Pod`。
在这个`Pod`中部署以下两个容器：

- 与`kubelet`通信的辅助`sidecar`容器`node-driver-registrar`，主要功能是将存储驱动注册到`kubelet`中
- `CSI Driver`存储驱动容器，由第三方存储提供商提供，主要功能是接收`kubelet`的调用，需要实现一系列与`Node`相关的`CSI`接口，例如`NodePublishVolume`接口（用于将Volume挂载到容器内的目标路径）、`NodeUnpublishVolume`接口（用于从容器中卸载Volume），等等。

`node-driver-registrar`容器与`kubelet`通过`Node`主机的一个`hostPath`目录下的`unixsocket`进行通信。`CSI Driver`容器与`kubelet`通过`Node`主机的另一个`hostPath`目录下的`unixsocket`进行通信，同时需要将`kubelet`的工作目录（默认为/var/lib/kubelet）挂载给`CSIDriver`容器，用于为`Pod`进行`Volume`的管理操作（包括mount、umount等）。
