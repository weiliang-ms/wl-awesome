![](images/index-hero.svg)
## Rook架构设计
`Rook`使`Ceph`存储系统能够使用`Kubernetes`原生资源对象在`Kubernetes`上运行。
下图说明了`Ceph Rook`如何与`Kubernetes`集成：

![](images/rook-architecture.png)

通过在`Kubernetes`集群中运行`Ceph`，`Kubernetes`应用可以挂载`Rook`管理的块设备和文件系统，
或者可以使用`S3/swiftapi`进行对象存储。
`Rook operator`自动配置存储组件并监视集群，以确保存储保持可用和正常。

`Rook operator`是一个简单的容器，它拥有引导和监视存储集群所需的所有东西。
`operator`将启动和监控`Ceph monitor pods`, `Ceph OSD`守护进程提供`RADOS`存储，以及启动和管理其他`Ceph`守护进程。
`operator`通过初始化运行服务所需的`pods`和其他组件来管理池、对象存储(S3/Swift)和文件系统的`crd`。

`operator`将监视存储守护程序，以确保群集正常运行。`Ceph-mons`将在必要时启动或故障转移，
并随着集群的增长或收缩进行其他调整。`operator`还将监视`api`服务请求的所需状态更改，并应用更改。

`Rook operator`还初始化消耗存储所需的代理。`Rook`会自动配置`Ceph CSI`驱动程序，将存储装载到`pod`中。

![](images/Rook.png)

`rook/ceph`镜像包括管理集群所需的所有工具。许多`Ceph`概念，如放置组和`crush map`是隐藏的。
`Rook`在物理资源、池、卷、文件系统和存储桶方面为管理员创建了一个非常简化的用户体验。同时，当需要`Ceph`工具时，可以应用高级配置

`Rook`基于`golang`实现。`Ceph`是基于`C++`中实现的，其中数据路径是高度优化的。二者是最好的组合。              

## 使用Rook管理ceph块存储

### 演示环境说明

> `k8s`集群信息

    [root@node1 ~]# kubectl get nodes
    NAME    STATUS     ROLES           AGE    VERSION
    node1   Ready      master,worker   2d4h   v1.18.6
    node2   Ready      master,worker   2d4h   v1.18.6
    node3   Ready      master,worker   2d4h   v1.18.6

> 内核版本

    5.4.108-1.el7.elrepo.x86_64
    
> 磁盘设备

`node1-node3`各挂载一块`100G`磁盘，设备路径为`/dev/sdb`

### 依赖说明

> 要配置`Ceph`存储群集，至少需要以下一个本地存储选项：

- 原始设备（没有分区或格式化文件系统）
- 原始分区（无格式化文件系统）
- `k8s`存储类提供的块模式`PV`

> 安装`LVM`包

在以下场景中，`Ceph OSD`依赖于`LVM`：

- `OSD`是在原始设备或分区上创建的
- 如果启用了加密（encryptedDevice: true）
- 指定了元数据设备

在以下情况下，`OSD`不需要`LVM`：
- 使用`storageClassDeviceSets`在`PVC`上创建`OSD`

如果您的场景需要`LVM`，那么`LVM`需要在运行`OSD`的主机上可用。有些`Linux`发行版不附带`lvm2`包。
要运行`Ceph OSDs`，`k8s`群集中的所有存储节点上都需要此包。如果没有这个包，
即使`Rook`能够成功地创建`Ceph OSD`，当一个节点重新启动时，在重新启动的节点上运行的`OSD pods`将无法启动。
请使用`Linux`发行版的包管理器安装`LVM`。例如：

    yum install -y lvm2
    
> 操作系统内核

- `RBD`类型

`Ceph`需要一个用`RBD`模块构建的`Linux`内核。
许多`Linux`发行版都有这个模块，但不是所有发行版都有。例如，`GKE`容器优化`OS`（`COS`）没有`RBD`。

您可以通过运行`modprobe rbd`来测试`Kubernetes`节点

- `cephfs`类型

如果要从`Ceph`共享文件系统（`CephFS`）创建卷，建议的最低内核版本为`4.17`。

如果内核版本低于`4.17`，则不会强制执行所请求的`PVC`大小。存储配额将仅在较新的内核上强制执行。

### 开启准入控制器
   
准入控制器在对象持久化之前拦截到`Kubernetes API`服务器的请求，但在对请求进行身份验证和授权之后。

建议启用`Rook`准入控制器，以提供额外级别的验证，以确保`Rook`是使用自定义资源(`CR`)设置正确配置的。

> 下载`ceph`配置声明文件上传至`k8s`节点`/root`下,解压

- [rook-1.6.6.tar.gz](https://github.com/rook/rook/archive/refs/tags/v1.6.6.tar.gz)


    tar zxvf v1.6.6.tar.gz
    mv rook-1.6.6 rook

> 可利用助手脚本自动配置部署`Rook`准入控制器,这个脚本将帮助我们完成以下任务:

- 创建自签名证书
- 为证书创建证书签名请求（`CSR`），并从`Kubernetes`集群获得批准
- 将这些证书存储为`Kubernetes Secret`
- 创建`Service Account`、`ClusterRole`和`ClusterRoleBindings`，以便以最低权限运行`webhook`服务
- 创建`ValidatingWebhookConfig`并使用来自集群的适当值填充`CA bundle`


    cd rook/
    kubectl create -f cluster/examples/kubernetes/ceph/crds.yaml -f cluster/examples/kubernetes/ceph/common.yaml
    
离线环境下，手动下载[cert-manager.yaml](https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.yaml) 
上传至`/root/rook/`下，替换文件路径

    sed -i "s#https://github.com/jetstack/cert-manager/releases/download/\$CERT_VERSION/#rook/#g" \
    tests/scripts/deploy_admission_controller.sh

调整`/root/rook/cert-manager.yaml`文件内引用镜像`tag`(替换为可访问的镜像`tag`)

    [root@node1 rook]# cat cert-manager.yaml |grep 'image:'
            image: harbor.chs.neusoft.com/ceph-csi/jetstack/cert-manager-cainjector:v1.2.0
            image: harbor.chs.neusoft.com/ceph-csi/jetstack/cert-manager-controller:v1.2.0
            image: harbor.chs.neusoft.com/ceph-csi/jetstack/cert-manager-webhook:v1.2.0
   
发布
   
    tests/scripts/deploy_admission_controller.sh
    
### 创建rook operator

> 调整`/root/rook/cluster/examples/kubernetes/ceph/operator.yaml`文件内引用镜像`tag`(替换为可访问的镜像`tag`)

    [root@node1 rook]# grep "image:" cluster/examples/kubernetes/ceph/operator.yaml
              image: rook/ceph:v1.6.6
              
调整以下内容，并放开注释


    # ROOK_CSI_CEPH_IMAGE: "quay.io/cephcsi/cephcsi:v3.3.1"
    
    # ROOK_CSI_REGISTRAR_IMAGE: "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.2.0"
    # ROOK_CSI_RESIZER_IMAGE: "k8s.gcr.io/sig-storage/csi-resizer:v1.2.0"
    # ROOK_CSI_PROVISIONER_IMAGE: "k8s.gcr.io/sig-storage/csi-provisioner:v2.2.2"
    # ROOK_CSI_SNAPSHOTTER_IMAGE: "k8s.gcr.io/sig-storage/csi-snapshotter:v4.1.1"
    # ROOK_CSI_ATTACHER_IMAGE: "k8s.gcr.io/sig-storage/csi-attacher:v3.2.1"
              
> 发布

    kubectl apply -f cluster/examples/kubernetes/ceph/operator.yaml
    
查看状态

    [root@node1 rook]# kubectl get pod -n rook-ceph
    NAME                                             READY   STATUS    RESTARTS   AGE
    rook-ceph-admission-controller-549f58dd9-rs8qs   1/1     Running   0          86s
    rook-ceph-admission-controller-549f58dd9-tmfnr   1/1     Running   0          86s
    rook-ceph-operator-869777bc74-dtv2h              1/1     Running   0          2m9s
    
    
此时，`operator`将自动启动准入控制器部署，而`Webhook`将开始拦截对`Rook`资源的请求。

### 创建ceph集群

`/root/rook/cluster/examples/kubernetes/ceph/cluster.yaml`

> 调整镜像`tag`

    ceph/ceph:v15.2.13
    
> 发布

    kubectl apply -f /root/rook/cluster/examples/kubernetes/ceph/cluster.yaml
    
> 查看状态

查看`pod`

    [root@node1 ceph]# kubectl get pod -n rook-ceph
    NAME                                             READY   STATUS    RESTARTS   AGE
    csi-cephfsplugin-jsw67                           3/3     Running   0          55s
    csi-cephfsplugin-provisioner-6667846fc9-g4jj2    6/6     Running   0          52s
    csi-cephfsplugin-provisioner-6667846fc9-wmzc7    6/6     Running   0          53s
    csi-cephfsplugin-tb4mh                           3/3     Running   0          55s
    csi-cephfsplugin-xvk4s                           3/3     Running   0          55s
    csi-rbdplugin-gl4tx                              3/3     Running   0          57s
    csi-rbdplugin-provisioner-7bf5687dcd-4rsst       6/6     Running   0          57s
    csi-rbdplugin-provisioner-7bf5687dcd-7hf94       6/6     Running   0          57s
    csi-rbdplugin-x57s2                              3/3     Running   0          57s
    csi-rbdplugin-zs64m                              3/3     Running   0          57s
    rook-ceph-admission-controller-549f58dd9-rs8qs   1/1     Running   0          18h
    rook-ceph-admission-controller-549f58dd9-tmfnr   1/1     Running   0          18h
    rook-ceph-mon-a-canary-6d7bf84b9c-pjmd4          1/1     Running   0          50s
    rook-ceph-mon-b-canary-5b647bf496-pdvhj          1/1     Running   0          50s
    rook-ceph-mon-c-canary-54d67bb847-8pb7x          1/1     Running   0          49s
    rook-ceph-operator-869777bc74-dtv2h              1/1     Running   0          18h
  
查看集群状态

    kubectl -n rook-ceph get CephCluster -o yaml
    
### 创建块存储池



        
         

