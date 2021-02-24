<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Ceph存储](#ceph%E5%AD%98%E5%82%A8)
- [Ceph架构解析](#ceph%E6%9E%B6%E6%9E%84%E8%A7%A3%E6%9E%90)
  - [Ceph存储集群](#ceph%E5%AD%98%E5%82%A8%E9%9B%86%E7%BE%A4)
    - [`Ceph`数据存储流程](#ceph%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8%E6%B5%81%E7%A8%8B)
    - [`Ceph`的可伸缩性和高可用性](#ceph%E7%9A%84%E5%8F%AF%E4%BC%B8%E7%BC%A9%E6%80%A7%E5%92%8C%E9%AB%98%E5%8F%AF%E7%94%A8%E6%80%A7)
    - [`CRUSH`算法介绍](#crush%E7%AE%97%E6%B3%95%E4%BB%8B%E7%BB%8D)
    - [`mon`高可用](#mon%E9%AB%98%E5%8F%AF%E7%94%A8)
    - [身份认证高可用性](#%E8%BA%AB%E4%BB%BD%E8%AE%A4%E8%AF%81%E9%AB%98%E5%8F%AF%E7%94%A8%E6%80%A7)
    - [Ceph协议](#ceph%E5%8D%8F%E8%AE%AE)
    - [数据分段](#%E6%95%B0%E6%8D%AE%E5%88%86%E6%AE%B5)
    - [Ceph客户端](#ceph%E5%AE%A2%E6%88%B7%E7%AB%AF)
      - [Ceph 块存储](#ceph-%E5%9D%97%E5%AD%98%E5%82%A8)
      - [Ceph 文件系统](#ceph-%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)
      - [Ceph 对象存储](#ceph-%E5%AF%B9%E8%B1%A1%E5%AD%98%E5%82%A8)
  - [硬件需求](#%E7%A1%AC%E4%BB%B6%E9%9C%80%E6%B1%82)
    - [CPU](#cpu)
    - [内存](#%E5%86%85%E5%AD%98)
    - [存储](#%E5%AD%98%E5%82%A8)
    - [网络](#%E7%BD%91%E7%BB%9C)
    - [故障域](#%E6%95%85%E9%9A%9C%E5%9F%9F)
    - [硬件配置建议](#%E7%A1%AC%E4%BB%B6%E9%85%8D%E7%BD%AE%E5%BB%BA%E8%AE%AE)
  - [操作系统建议](#%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E5%BB%BA%E8%AE%AE)
    - [内核](#%E5%86%85%E6%A0%B8)
    - [平台](#%E5%B9%B3%E5%8F%B0)
  - [竞品对比](#%E7%AB%9E%E5%93%81%E5%AF%B9%E6%AF%94)
    - [对比raid](#%E5%AF%B9%E6%AF%94raid)
    - [对比SAN、NAS、DAS](#%E5%AF%B9%E6%AF%94sannasdas)
    - [对比其他分布式存储](#%E5%AF%B9%E6%AF%94%E5%85%B6%E4%BB%96%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8)
  - [集成部署](#%E9%9B%86%E6%88%90%E9%83%A8%E7%BD%B2)
    - [ceph-deploy部署N版](#ceph-deploy%E9%83%A8%E7%BD%B2n%E7%89%88)
  - [运维管理](#%E8%BF%90%E7%BB%B4%E7%AE%A1%E7%90%86)
    - [ceph添加磁盘](#ceph%E6%B7%BB%E5%8A%A0%E7%A3%81%E7%9B%98)
    - [crush pool](#crush-pool)
    - [块设备（rdb）使用](#%E5%9D%97%E8%AE%BE%E5%A4%87rdb%E4%BD%BF%E7%94%A8)
    - [k8s对接cephfs](#k8s%E5%AF%B9%E6%8E%A5cephfs)
    - [卸载](#%E5%8D%B8%E8%BD%BD)
  - [参考文献](#%E5%8F%82%E8%80%83%E6%96%87%E7%8C%AE)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Ceph存储

# Ceph架构解析

`Ceph`是一个提供对象存储、块存储和文件存储的统一存储系统。
`Ceph`是高度可靠、易于管理和免费的。`Ceph`的强大功能可以改变企业`IT`基础设施和管理大量数据的能力。
`Ceph`提供了超强的可伸缩性--数以千计的客户端访问`pb`到`eb`的数据.

![](images/stack.png)

## Ceph存储集群
    
`Ceph`提供了一个基于`RADOS`(一种可扩展的、可靠的pb级存储集群存储服务)的无限可扩展的`Ceph`存储集群.

`Ceph`存储集群由两种类型的守护进程组成:

- `Ceph Monitor`（mon）
-  `Ceph OSD Daemon`（osd）

![](images/osdmonitor.png)

其中`Ceph Monitor`维护集群映射的主副本。多节点`Ceph Monitor`确保了`Ceph Monitor`守护进程失败时的高可用性。
`Ceph`客户端从`Ceph Monitor`获取集群信息

`Ceph OSD`守护进程检查自己的状态和其他`OSD`的状态，并向`Ceph Monitor`上报。

`Ceph`客户端和每个`Ceph OSD`守护进程使用`CRUSH`算法高效地计算数据位置信息，而不必依赖于中央查找表。
`Ceph`的高级特性包括通过`librados`提供到`Ceph`存储集群的本地接口，以及建立在`librados`之上的许多服务接口。

### `Ceph`数据存储流程

`Ceph`存储集群从`Ceph`客户端接收数据——无论是通过一个`Ceph`块设备、`Ceph`对象存储、`Ceph`文件系统还是使用`librados`创建的自定义实现——它将数据作为对象存储。
每个对象都对应于文件系统中的一个文件，文件系统存储在对象存储设备上。`Ceph OSD`守护进程处理存储磁盘的读写操作。

![](images/storagedata.png)

`Ceph OSD`守护进程将所有数据作为对象存储在一个平面命名空间中(没有目录层次结构)。
对象具有标识符、二进制数据和由一组名称/值对组成的元数据。语义完全由`Ceph`客户端决定。
例如，`CephFS`使用元数据存储文件属性，如文件所有者、创建日期、最后修改日期等。其中，对象ID全局唯一。

![](images/dataforfat.png)

### `Ceph`的可伸缩性和高可用性

在传统的架构中，客户端与一个集中的组件(例如，网关、代理、API、facade等)通信，该组件充当一个进入复杂子系统的单一入口点。
这对性能和可伸缩性都施加了限制，同时引入了单点故障(例如，如果集中式组件宕机，整个系统也宕机）

`Ceph`消除了集中式网关，使客户端可以直接与`Ceph OSD`守护进程交互。`Ceph OSD`守护进程在其他`Ceph`节点上创建对象副本，以确保数据的安全性和高可用性。
`Ceph`还使用一组`mon`来确保高可用性。为了消除集中化，`Ceph`使用了一种称为`CRUSH`的算法

### `CRUSH`算法介绍

`Ceph`客户端和`Ceph OSD`守护进程都使用`CRUSH`算法来有效地计算对象的位置信息，而不是依赖于一个中心查找表。
与以前的方法相比，`CRUSH`提供了更好的数据管理机制，可以实现大规模的数据管理。
`CRUSH`使用智能数据复制来确保弹性，这更适合于超大规模存储。

 集群映射

`Ceph`依赖于`Ceph`客户端和`Ceph OSD`守护进程了解集群拓扑，其中包括5个映射，统称为“集群映射”：

- `Monitor`映射: 包含集群`fsid`、每个监视器的位置、名称、地址和端口、映射创建的时间，以及它最后一次修改时间。
要查看监视器映射，执行`ceph mon dump`。

    
    [root@ceph01 ~]# ceph mon dump
    dumped monmap epoch 2
    epoch 2
    fsid b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
    last_changed 2021-02-22 14:36:08.199609
    created 2021-02-22 14:27:26.357269
    min_mon_release 14 (nautilus)
    0: [v2:192.168.1.69:3300/0,v1:192.168.1.69:6789/0] mon.ceph01
    1: [v2:192.168.1.70:3300/0,v1:192.168.1.70:6789/0] mon.ceph02
    2: [v2:192.168.1.71:3300/0,v1:192.168.1.71:6789/0] mon.ceph03

- `OSD映射`:包含集群的`fsid`，映射创建和最后修改的时间，池的列表，副本大小，`PG`号，`OSD`的列表和状态(如up, in)。
执行`ceph OSD dump`命令，查看`OSD`映射

    
    [root@ceph01 ~]# ceph osd dump
    epoch 1
    fsid b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
    created 2021-02-22 14:27:48.482130
    modified 2021-02-22 14:27:48.482130
    flags sortbitwise,recovery_deletes,purged_snapdirs,pglog_hardlimit
    crush_version 1
    full_ratio 0.95
    backfillfull_ratio 0.9
    nearfull_ratio 0.85
    require_min_compat_client jewel
    min_compat_client jewel
    require_osd_release nautilus
    max_osd 0
    
- `PG Map`：包含`PG`版本、它的时间戳、最后一个`OSD Map epoch`、完整比率，以及每个放置组的详细信息，例如`PG ID`、`Up Set`、`Acting Set`、`PG`的状态（例如active+clean），以及每个池的数据使用统计信息
  
- `CRUSH Map`:包含一个存储设备列表，故障域层次结构(例如，设备、主机、机架、行、房间等)，以及存储数据时遍历层次结构的规则。执行`ceph osd getcrushmap -o {filename}`;然后，通过执行`crushtool -d {comp-crushmap-filename} -o {decomp-crushmap-filename}`来反编译它。
使用cat查看反编译后的映射。

- `MDS Map`:包含当前`MDS Map`的`epoch`、`Map`创建的时间和最后一次修改的时间。它还包含存储元数据的池、元数据服务器的列表，以及哪些元数据服务器已经启动和运行.

每个映射维护其操作状态更改的迭代历史。`Ceph`监视器维护集群映射的主副本，包括集群成员、状态、变更和`Ceph`存储集群的总体运行状况


### `mon`高可用

在`Ceph`客户机能够读写数据之前，它们必须访问`Ceph mon`以获取集群映射的最新副本。`Ceph`存储集群可以使用单个`mon`进行操作;然而，这引入了单点故障(即，如果监视器出现故障，Ceph客户机就无法读写数据)。

为了增加可靠性和容错性，`Ceph`支持`mon`集群。在一个监视器集群中，延迟和其他故障可能导致一个或多个监视器落后于集群的当前状态。由于这个原因，`Ceph`必须在关于集群状态的各个监视器实例之间达成一致。`Ceph`总是使用大多数监视器(例如，1、2:3、3:5、4:6等)和`Paxos`算法来在监视器之间建立关于集群当前状态的共识

**即部署多点ceph mon 规避单点故障**

### 身份认证高可用性

为了识别用户并防止中间人攻击，`Ceph`提供了`cephx`身份验证系统来验证用户和守护进程。（`cephx`协议不处理传输中的数据加密(例如，`SSL/TLS`)或静止时的加密。）

`Cephx`使用共享密钥进行身份验证，这意味着客户端和监控集群都拥有客户端密钥的副本。身份验证协议是这样的，双方能够向对方证明他们有一个密钥的副本，而不实际暴露它。这提供了相互的身份验证，这意味着集群确定用户拥有密钥，用户也确定集群拥有密钥的副本

`Ceph`的一个关键的可伸缩性特性是避免对`Ceph`对象存储的集中接口，这意味着`Ceph`客户端必须能够直接与`osd`交互。为了保护数据，`Ceph`提供了其`cephx`身份验证系统，该系统对操作`Ceph`客户端的用户进行身份验证。`cephx`协议的操作方式与`Kerberos`类似

要使用`cephx`，管理员必须首先设置用户。在下面的图表中`client.admin`从命令行调用`ceph auth get-or-create-key`来生成用户名和密钥。
`Ceph`的`auth`子系统生成用户名和密钥，将一个副本存储在监视器中，并将用户的密钥传输回`client.admin`。
这意味着客户端和监视器共享一个密钥来使用`cephx`.

![](images/generateuser.png)

为了使用监视器进行身份验证，客户端将用户名传递给监视器，监视器生成一个会话密钥并使用与用户名相关联的密钥对其进行加密。
然后，监视器将加密的票据传输回客户端。随后，客户机使用共享密钥解密，以检索会话密钥。会话密钥标识当前会话的用户。
然后客户端使用会话密钥签名的用户请求票据。监视器生成一个票据，用用户的密钥对其加密，并将其传回客户机。
客户端解密票据，并使用它对整个集群中的`OSDs`和元数据服务器的请求进行签名

![](images/authenticate.png)

`cephx`协议对客户端机器和`Ceph`服务器之间的通信进行身份验证。
在初始身份验证之后，客户机和服务器之间发送的每个消息都使用票据进行签名，
监视器、osd和元数据服务器可以使用它们的共享秘密来验证该票据

![](images/ticket.png)

这种身份验证提供的保护在`Ceph`客户端和`Ceph`服务器主机之间。身份验证没有扩展到`Ceph`客户端之外。
如果用户从远程主机访问`Ceph`客户端，`Ceph`身份验证不应用于用户的主机和客户端主机之间的连接

### Ceph协议



### 数据分段
    
存储设备有吞吐量限制，这会影响性能和可伸缩性。因此，存储系统通常支持跨多个存储设备分段存储顺序信息，以提高吞吐量和性能。
`RAID`是最常见的数据分条形式。与`Ceph`的条带化最相似的`RAID`类型是`raid0`，或“条带卷”。`Ceph`的分条提供了`RAID 0`分条的吞吐量，`n-way RAID`镜像的可靠性和更快的恢复。

`Ceph`存储集群中`Ceph`存储的对象没有条带化。`Ceph`对象存储、`Ceph`块设备和`Ceph`文件系统在多个`Ceph`存储集群对象上条带化它们的数据。
通过`librados`直接写入`Ceph`存储集群的`Ceph`客户端必须为自己执行条带化（和并行I/O）以获得这些好处。

最简单的`Ceph`条带格式涉及1个对象的条带计数。`Ceph`客户端将条带单元写入`Ceph`存储群集对象，直到该对象达到最大容量，然后为额外的数据条带创建另一个对象。
最简单的条带化形式对于小块设备图像、`S3`或`Swift`对象和`cepfs`文件就足够了。
然而，这种简单的形式并没有最大限度地利用`Ceph`在放置组之间分发数据的能力，因此并没有极大地提高性能。下图描述了条带化的最简单形式：

![](images/striping.png)

如果预期会有较大的镜像、较大的`S3`或`Swift`对象（例如，视频）或较大的`cepfs`目录，那么通过在对象集中的多个对象上对客户端数据进行条带化，会有相当大的读/写性能改进。
当客户端并行地将条带单元写入相应的对象时，会显著提升写入性能。由于对象被映射到不同的放置组并进一步映射到不同的`osd`，因此每次写入都以最大的写入速度并行进行。
对单个磁盘的写入将受到磁头移动（例如，每次寻道6ms）和该设备带宽（例如，100MB/s）的限制。
通过将写操作扩展到多个对象（映射到不同的放置组和osd），`Ceph`可以减少每个驱动器的寻道次数，并结合多个驱动器的吞吐量，以实现更快的写（或读）速度。

在下面的图中，客户端数据在由4个对象组成的对象集(下图中的对象集1)上进行分条，
其中第一个分条单元是对象0中的分条单元0，第四个分条单元是对象3中的分条单元3。
写入第四个分条后，客户端确定对象集是否已满。
如果对象集未满，客户端将开始再次向第一个对象(下图中的对象0)写入条带。
如果对象集已满，客户端将创建一个新的对象集(下图中的对象集2)，
并开始写入新对象集(下图中的对象4)中的第一个对象中的第一个条带(条带单元16)。

![](images/multi-strping.png)

决定`Ceph`条带化数据的方式的三个重要变量:

- 对象大小：`Ceph`存储集群中的对象具有最大可配置大小（例如，2MB、4MB等）。对象大小应该足够大以容纳多个条带单位，并且应该是条带单位的倍数
- 条带宽度：条带具有可配置的单元大小（例如64kb）。`Ceph`客户端将要写入对象的数据划分为大小相等的条带单元，但最后一个条带单元除外。条带宽度应该是对象大小的一小部分，这样一个对象可以包含许多条纹单位。
- 条带计数：`Ceph`客户端在由条带计数确定的一系列对象上写入条带单元序列。这一系列对象被称为对象集。`Ceph`客户端写入对象集中的最后一个对象后，它返回到对象集中的第一个对象

一旦`Ceph`客户端将数据分条到条带单元并将条带单元映射到对象，`Ceph`的`CRUSH`算法将对象映射到放置组，并将放置组映射到`Ceph OSD`守护进程，然后将对象作为文件存储在存储磁盘上

### Ceph客户端

`Ceph`客户端包括许多服务接口:

- 块设备：`Ceph`块设备(又称RBD)服务提供可调整大小、精简配置的块设备，并提供快照和克隆。`Ceph`跨集群划分块设备以获得高性能。`Ceph`既支持内核对象(KO)，也支持直接使用`librbd`的`QEMU`管理程序——避免了虚拟化系统的内核对象开销

- 对象存储：`Ceph`对象存储服务(简称RGW)提供`RESTful api`，兼容`Amazon S3`和`OpenStack Swift`接口
       
- 文件系统：`Ceph`文件系统(cepphfs)服务提供一个兼容`POSIX`的文件系统，可以挂载，也可以作为用户空间中的文件系统(FUSE)使用。

![](images/artitecture.png)

#### Ceph 块存储

`Ceph`块设备在`Ceph`存储集群中的多个对象上划分块设备映像，每个对象映射到一个放置组并分布，放置组分布在整个集群中不同的`Ceph osd`守护进程上。

精简配置的可快照`Ceph`块设备是虚拟化和云计算的一个有吸引力的选择。
在虚拟机场景中，人们通常在`QEMU/KVM`中部署带有`rbd`网络存储驱动程序的`Ceph`块设备，其中服务端使用`librbd`向客户端提供块设备服务。
许多云计算栈使用`libvirt`与管理程序集成。您可以通过`QEMU`和`libvirt`使用瘦配置的`Ceph`块设备来支持`OpenStack`和`CloudStack`以及其他解决方案。

#### Ceph 文件系统

`Ceph`文件系统(cepphfs)提供了`posix`兼容的文件系统作为一种服务，它是在基于对象的`Ceph`存储集群之上分层的。
`cepfs`文件映射到`Ceph`存储集群中存储的对象。`Ceph`客户端将`cepfs`文件系统挂载为内核对象或用户空间中的文件系统(FUSE)

![](images/cephfs-artitecture.png)

`Ceph`文件系统服务包括部署在`Ceph`存储集群中的`Ceph`元数据服务器(MDS)。
`MDS`的目的是将所有文件系统元数据(目录、文件所有权、访问模式等)存储在高可用性`Ceph`元数据服务器中，元数据驻留在内存中。
`MDS`(称为Ceph - MDS的守护进程)存在的原因是，简单的文件系统操作，如列出目录或更改目录(ls、cd)，会给`Ceph OSD`守护进程带来不必要的负担。
因此，将元数据从数据中分离出来意味着`Ceph`文件系统可以提供高性能服务，而不会对`Ceph`存储集群造成负担。


`cepfs`将元数据与数据进行分离，元数据存储在`MDS`中，文件数据存储在`Ceph`存储集群中的一个或多个对象中。
`Ceph`文件系统旨在与`POSIX`兼容。为了实现高可用性或可伸缩性，`ceph-mds`可以作为单个进程运行，也可以将其分发到多个物理机器。

- 高可用：额外的`ceph-mds`实例可以是备用的，随时准备接管任何失效的`active ceph-mds`的职责。这很容易，因为包括日志在内的所有数据都存储在`RADOS`上。该转换由`ceph-mon`自动触发
- 可扩展：多个`ceph mds`实例可以处于活动状态，它们将目录树拆分为子树（以及单个繁忙目录的碎片），从而有效地平衡所有活动服务器之间的负载

#### Ceph 对象存储

`Ceph`对象存储守护进程`radosgw`是一个`FastCGI`服务，它提供了一个`RESTful`的`HTTP API`来存储对象和元数据。
它以自己的数据格式在`Ceph`存储集群之上分层，并维护自己的用户数据库、身份验证和访问控制。
`RADOS`网关采用统一的命名空间，既可以使用`OpenStack swift`接口，也可以使用`Amazon s3`接口。
例如，一个应用使用`s3`兼容的`API`写入数据，另一个应用使用`swift`兼容的`API`读取数据

**S3/Swift对象和存储集群对象对比：**

`Ceph`的`Object Storage`使用`Object`这个术语来描述它存储的数据。
`S3`和`Swift`对象与`Ceph`写入`Ceph`存储集群的对象不同。
`Ceph`对象存储对象映射到`Ceph`存储集群对象。
`S3`和`Swift`对象不一定与存储集群中存储的对象以1:1的方式对应。
`S3`或`Swift`对象有可能映射到多个`Ceph`对象。



## 硬件需求

`Ceph`被设计成在普通硬件上运行，这使得构建和维护`pb`级数据集群在经济上可行,在规划集群硬件时，需要平衡许多考虑因素，包括故障域和潜在的性能问题。
硬件规划应该包括在多个主机上分布`Ceph`守护进程和其他使用`Ceph`的进程。官方建议在为特定类型的守护进程配置的主机上运行特定类型的`Ceph`守护进程。

即`ceph`集群与客户端应为不同宿主机，具体硬件需求参考如下：

### CPU

`Ceph`元数据服务器动态地重新分配它们的负载，这是`CPU`密集型的。因此，元数据服务器应该具有强大的处理能力(例如，四核或更好的cpu)。`Ceph OSDs`运行`RADOS`服务，使用`CRUSH`计算数据位置，复制数据，并维护它们自己的集群映射副本。
因此，`osd`应该具有合理的处理能力(例如，双核处理器)。监视器只是维护集群映射的主副本，因此它们不是`CPU`密集型的。
您还必须考虑主机除了运行`Ceph`守护进程外，是否还将运行`cpu`密集型进程。
例如，如果您的主机将运行计算虚拟机(例如`OpenStack Nova`)，您将需要确保这些其他进程为`Ceph`守护进程留出足够的处理能力。
建议在不同的主机上运行额外的`cpu`密集型进程

**样例集群CPU配置：**

    Architecture:          x86_64
    CPU op-mode(s):        32-bit, 64-bit
    Byte Order:            Little Endian
    CPU(s):                72
    On-line CPU(s) list:   0-71
    Thread(s) per core:    2
    Core(s) per socket:    18
    Socket(s):             2
    NUMA node(s):          2
    Vendor ID:             GenuineIntel
    CPU family:            6
    Model:                 85
    Model name:            Intel(R) Xeon(R) Gold 6240 CPU @ 2.60GHz
    Stepping:              7
    CPU MHz:               999.914
    CPU max MHz:           3900.0000
    CPU min MHz:           1000.0000
    BogoMIPS:              5200.00
    Virtualization:        VT-x
    L1d cache:             32K
    L1i cache:             32K
    L2 cache:              1024K
    L3 cache:              25344K
    NUMA node0 CPU(s):     0-17,36-53
    NUMA node1 CPU(s):     18-35,54-71
    Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch epb cat_l3 cdp_l3 invpcid_single intel_ppin intel_pt ssbd mba ibrs ibpb stibp ibrs_enhanced tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm cqm mpx rdt_a avx512f avx512dq rdseed adx smap clflushopt clwb avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local dtherm ida arat pln pts hwp hwp_act_window hwp_epp hwp_pkg_req pku ospke avx512_vnni md_clear spec_ctrl intel_stibp flush_l1d arch_capabilities

### 内存

内存越多越好

- `CEPH-MON`&`CEPH-MGR`（监控、管理节点）

    监视器和管理器守护进程的内存使用情况通常随集群的大小而变化。对于小型集群，一般1-2`GB`就足够了。对于大型集群，您应该提供更多(5-10`GB`)。您可能还需要考虑调整`mon_osd_cache_size`或`rocksdb_cache_size`等设置
 
- `CEPH-MDS`元数据节点

    元数据守护进程的内存利用率取决于它的缓存被配置为消耗多少内存。对于大多数系统，官方建议至少使用1`GB`。具体大小可调整`mds_cache_memory`
    
- `OSDS`(`CEPH-OSD`)存储节点

    默认情况下，使用`BlueStore`后端的`osd`需要3-5`GB` `RAM`。当使用`BlueStore`时，
    可以通过配置选项`osd_memory_target`来调整`OSD`的内存消耗。当使用遗留的`FileStore`后端时，
    操作系统页面缓存用于缓存数据，所以通常不需要进行调优，并且`OSD`的内存消耗通常与系统中每个守护进程的`PGs`数量有关。

**样例集群内存配置：**

                  total        used        free      shared  buff/cache   available
    Mem:           187G        8.8G        164G        4.0G         13G        173G
    Swap:            0B          0B          0B

### 存储

请仔细规划您的数据存储配置。在规划数据存储时，需要考虑大量的成本和性能折衷。
同时进行`OS`操作，以及多个守护进程对单个驱动器同时进行读和写操作的请求会显著降低性能。

**注意：**

因为`Ceph`在发送`ACK`之前必须把所有的数据都写到日志中(至少对于`XFS`来说是这样)，让日志和`OSD`的性能平衡是非常重要的!

- 硬盘驱动器
  
    `osd`应该有足够的硬盘驱动器空间来存放对象数据。官方建议硬盘驱动器的最小大小为1`TB`。
    考虑较大磁盘的每`GB`成本优势。官方建议将硬盘驱动器的价格除以千兆字节数，得出每千兆字节的成本，因为较大的驱动器可能对每千兆字节的成本有很大的影响。
    例如，价格为$75.00的1`TB`硬盘的成本为每`GB`$0.07(即$75 / 1024 = 0.0732)。
    相比之下，价格为150美元的3`TB`硬盘的成本为每`GB` 0.05美元(即150美元/ 3072 = 0.0488)。
    在前面的示例中，使用1`TB`的磁盘通常会使每`GB`的成本增加40%——从而大大降低集群的成本效率。
    此外，存储驱动器容量越大，每个`Ceph OSD`守护进程需要的内存就越多，尤其是在重新平衡、回填和恢复期间。
    一般的经验法则是1`TB`的存储空间需要`1GB`的`RAM`
    
    存储驱动器受到寻道时间、访问时间、读和写时间以及总吞吐量的限制。
    这些物理限制会影响整个系统的性能——尤其是在恢复过程中。
    官方建议为操作系统和软件使用专用的驱动器，为主机上运行的每个`Ceph OSD`守护进程使用一个驱动器(物理硬盘)。
    大多数`慢OSD`问题是由于在同一个驱动器上运行一个操作系统、多个`OSD`和/或多个日志引起的。
    由于在小型集群上故障排除性能问题的成本可能会超过额外磁盘驱动器的成本，因此可以通过避免过度使用`OSD`存储驱动器来加速集群设计规划
    
    您可以在每个硬盘驱动器上运行多个`Ceph OSD`进程，但这可能会导致资源争用，并降低总体吞吐量。
    您可以将日志和对象数据存储在同一个驱动器上，但这可能会增加向客户端记录写操作和`ACK`所需的时间。
    `Ceph`必须先向日志写入数据，然后才能对写入数据进行验证
    
**总结为：`Ceph`最佳实践规定，您应该在不同的驱动器上运行操作系统、`OSD`数据和`OSD`日志**

- 固态硬盘
  
    提高性能的一个机会是使用固态驱动器(SSD)来减少随机访问时间和读取延迟，同时加速吞吐量。
    与硬盘驱动器相比，`SSD`每`GB`的成本通常超过10倍，但`SSD`的访问时间通常至少比硬盘驱动器快100倍
    
    `SSD`没有可移动的机械部件，因此它们不必受到与硬盘驱动器相同类型的限制。不过`SSD`确实有很大的局限性。
    在评估`SSD`时，考虑顺序读写的性能是很重要的。
    当存储多个`osd`的多个日志时，顺序写吞吐量为400MB/s的`SSD`可能比顺序写吞吐量为120MB/s的`SSD`性能更好
    
    由于`SSD`没有可移动的机械部件，所以在`Ceph`中不需要大量存储空间的区域使用`SSD`是有意义的。
    相对便宜的固态硬盘可能会吸引你的经济意识。谨慎使用。
    当选择与`Ceph`一起使用的`SSD`时，可接受的`IOPS`是不够的。对于日志和`SSD`有几个重要的性能考虑因素:
    - 写密集型语义:日志记录涉及写密集型语义，因此您应该确保选择部署的`SSD`在写入数据时的性能等于或优于硬盘驱动器。
    廉价的`SSD`可能会在加速访问时间的同时引入写延迟，因为有时高性能硬盘驱动器的写速度可以与市场上一些更经济的`SSD`一样快甚至更快!
    - 顺序写:当您在一个`SSD`上存储多个日志时，您还必须考虑`SSD`的顺序写限制，因为它们可能会同时处理多个`OSD`日志的写请求。
    - 分区对齐:`SSD`性能的一个常见问题是，人们喜欢将驱动器分区作为最佳实践，但他们常常忽略了使用`SSD`进行正确的分区对齐，这可能导致`SSD`传输数据的速度慢得多。确保`SSD`分区对齐

    虽然`SSD`存储对象的成本非常高，但是通过将`OSD`的日志存储在`SSD`上，将`OSD`的对象数据存储在单独的硬盘驱动器上，可以显著提高`OSD`的性能。
    `osd`日志配置默认为`/var/lib/ceph/osd/$cluster-$id/journal`。您可以将此路径挂载到`SSD`或`SSD`分区上，使其与对象数据不只是同一个磁盘上的文件

    `Ceph`加速`CephFS`文件系统性能的一种方法是将`CephFS`元数据的存储与`CephFS`文件内容的存储隔离。
    `Ceph`为`cepfs`元数据提供了一个默认的元数据池。您永远不必为`CephFS`元数据创建一个池，但是您可以为仅指向主机的`SSD`存储介质的`CephFS`元数据池创建一个`CRUSH map`层次结构。

**重要提示: 官方建议探索`SSD`的使用以提高性能。但是，在对`SSD`进行重大投资之前，官方强烈建议检查`SSD`的性能指标，并在测试配置中测试`SSD`，以评估性能**

- 控制器

    磁盘控制器对写吞吐量也有很大的影响。仔细考虑磁盘控制器的选择，以确保它们不会造成性能瓶颈。
    
- 注意事项

    你可以在每个主机上运行多个`OSD`，但是你应该确保`OSD`硬盘的总吞吐量不超过客户端读写数据所需的网络带宽。
    您还应该考虑集群在每个主机上存储的总体数据的百分比。如果某个主机上的百分比很大，并且该主机发生故障，那么它可能会导致一些问题，比如超过了完整的比例，这将导致`Ceph`停止操作，作为防止数据丢失的安全预防措施。

    当您在每个主机上运行多个`osd`时，还需要确保内核是最新的。请参阅`OS`推荐，了解`glibc`和`syncfs(2)`方面的注意事项，以确保在每个主机上运行多个`osd`时，您的硬件能够像预期的那样执行    

    拥有大量`osd`的主机(例如> 20)可能会产生大量线程，特别是在恢复和平衡过程中。许多`Linux`内核默认的最大线程数相对较小(例如，32k)。如果在拥有大量`osd`的主机上启动`osd`时遇到问题，请考虑设置`kernel`。将`pid_max`设置为更高的线程数。理论最大值是4,194,303线程。
    例如，您可以将以下内容添加到`/etc/sysctl.conf`文件中: 
    
    
    kernel.pid_max = 4194303
    
**样例集群存储配置：**

    Disk /dev/nvme0n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    
    
    Disk /dev/nvme1n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    
    
    Disk /dev/nvme2n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    
    
    Disk /dev/nvme3n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    
    
    Disk /dev/sdb: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
    WARNING: fdisk GPT support is currently new, and therefore in an experimental phase. Use at your own discretion.
    
    Disk /dev/sda: 480.1 GB, 480103981056 bytes, 937703088 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    Disk label type: gpt
    Disk identifier: EDC26861-DACE-4831-848D-4FA0C5F642D7
    
    
    #         Start          End    Size  Type            Name
     1         2048      2099199      1G  EFI System      EFI System Partition
     2      2099200      4196351      1G  Microsoft basic
     3      4196352    937701375  445.1G  Linux LVM
    
    Disk /dev/sde: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
    
    Disk /dev/sdd: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
    
    Disk /dev/sdg: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
    
    Disk /dev/sdf: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
    WARNING: fdisk GPT support is currently new, and therefore in an experimental phase. Use at your own discretion.
    
    Disk /dev/sdh: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    Disk label type: gpt
    Disk identifier: 5F151167-14E6-4826-BBEB-55280AC27EEC
    
    
    #         Start          End    Size  Type            Name
     1     10487808   1875384974  889.3G  Ceph OSD        ceph data
     2         2048     10487807      5G  Ceph Journal    ceph journal
    
    Disk /dev/sdc: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
    Disk /dev/mapper/centos-root: 478.0 GB, 477953523712 bytes, 933502976 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
### 网络

官方说明如下:

   - 每个主机至少有两个`1Gbps`的网络接口控制器(`nic`)。由于大多数普通硬盘驱动器的吞吐量大约为100MB/秒，您的网卡应该能够处理主机上`OSD`磁盘的流量
   - 建议至少使用两个网卡来考虑公共(前端)网络和集群(后端)网络。集群网络(最好不连接到外部网络)处理数据复制的额外负载
   - 通过`1Gbps`的网络复制`1TB`的数据需要3个小时，`3TB`(典型的驱动器配置)需要9个小时。相比之下，在`10Gbps`的网络中，复制时间将分别为20分钟和1小时。
   - 在`pb`级集群中，`OSD`磁盘故障应该是一种预期，而不是异常。系统管理员希望`PGs`尽可能快地从降级状态恢复到`active + clean`状态，同时考虑到价格/性能权衡。
   此外，一些部署工具(如戴尔的Crowbar)可以部署5个不同的网络，但使用`vlan`使硬件和网络电缆更易于管理。使用`802.1q`协议的`vlan`需要支持`vlan`的网卡和交换机。增加的硬件费用可能会被网络设置和维护的操作成本节省所抵消
   - 当使用`vlan`处理集群与计算栈(如OpenStack、CloudStack等)之间的虚拟机流量时，也值得考虑使用`10G`以太网。
   每个网络的机架顶部路由器也需要能够与具有更快吞吐量的脊柱路由器进行通信。`40Gbps`到`100Gbps`
   - 您的服务器硬件应该有一个底板管理控制器(`BMC`)。管理和部署工具也可能广泛地使用`bmc`，
   因此考虑使用带外网络进行管理的成本/收益权衡。管理程序`SSH`访问、`VM`镜像上传、操作系统镜像安装、管理套接字等都可能给网络带来巨大的负载。
   运行三个网络可能看起来有点小题大做，但每个流量路径都代表一个潜在的容量、吞吐量和/或性能瓶颈，在部署大规模数据集群之前，您应该仔细考虑这些问题
    
**简言之：**
    建议三个网络接口：
- ceph集群网络接口
- 对外网络接口
- 管理接口


**样例集群网口配置：**

    [root@ceph01 ~]#  ethtool ens4f0
    Settings for ens4f0:
            Supported ports: [ FIBRE ]
            Supported link modes:   10000baseT/Full
            Supported pause frame use: Symmetric
            Supports auto-negotiation: No
            Supported FEC modes: Not reported
            Advertised link modes:  10000baseT/Full
            Advertised pause frame use: Symmetric
            Advertised auto-negotiation: No
            Advertised FEC modes: Not reported
            Speed: 10000Mb/s
            Duplex: Full
            Port: FIBRE
            PHYAD: 0
            Transceiver: internal
            Auto-negotiation: off
            Supports Wake-on: d
            Wake-on: d
            Current message level: 0x00000007 (7)
                                   drv probe link
            Link detected: yes

### 故障域

故障域是指阻止访问一个或多个`OSDs`的任何故障。这可能是主机上已停止的守护进程;硬盘故障、操作系统崩溃、网卡故障、电源故障、网络中断、电源中断，等等。
在规划硬件需求时，您必须平衡降低成本的诱惑，即把太多的责任放在太少的故障域中，以及隔离每个潜在故障域所增加的成本

### 硬件配置建议

- 最小配置建议

| Process        | Criteria                               | Minimum Recommended                                |
|----------------|----------------------------------------|----------------------------------------------------|
| ceph-osd       | Processor | 1x 64-bit AMD-64 1x 32-bit ARM dual-core or better |
|                | RAM | ~1GB for 1TB of storage per daemon |
|                | Volume Storage | 1x storage drive per daemon |
|                | Journal        | 1x SSD partition per daemon (optional) |
|                | Network        | 2x 1GB Ethernet NICs                   |
| ceph-mon       | Processor                              | 1x 64-bit AMD-64 1x 32-bit ARM dual-core or better |
|                | RAM            | 1 GB per daemon                        |
|                | Disk Space     | 10 GB per daemon                       |
|                | Network        | 2x 1GB Ethernet NICs                   |
| ceph-mds       | Processor                              | 1x 64-bit AMD-64 quad-core 1x 32-bit ARM quad-core |
|                | RAM            | 1 GB minimum per daemon                |
|                | Disk Space     | 1 MB per daemon                        |
|                | Network        | 2x 1GB Ethernet NICs                   |

- 生产环境建议

| Configuration  | Criteria                          | Minimum Recommended           |
|----------------|-----------------------------------|-------------------------------|
| Dell PE R510   | Processor                         | 2x 64-bit quad-core Xeon CPUs |
|                | RAM            | 16 GB                             |
|                | Volume Storage | 8x 2TB drives. 1 OS, 7 Storage    |
|                | Client Network | 2x 1GB Ethernet NICs              |
|                | OSD Network    | 2x 1GB Ethernet NICs              |
|                | Mgmt. Network  | 2x 1GB Ethernet NICs              |
| Dell PE R515   | Processor                         | 1x hex-core Opteron CPU       |
|                | RAM            | 16 GB                             |
|                | Volume Storage | 12x 3TB drives. Storage           |
|                | OS Storage     | 1x 500GB drive. Operating System. |
|                | Client Network | 2x 1GB Ethernet NICs              |
|                | OSD Network    | 2x 1GB Ethernet NICs              |
|                | Mgmt. Network  | 2x 1GB Ethernet NICs              |

## 操作系统建议

### 内核

- `Ceph`客户内核
    - 4.14.z
    - 4.9.z
    
### 平台

| Distro | Release | Code Name    | Kernel       | Notes | Testing |
|--------|---------|--------------|--------------|-------|---------|
| CentOS | 7       | N/A          | linux-3.10.0 | 3     | B, I, C |
| Debian | 8.0     | Jessie       | linux-3.16.0 | 1, 2  | B, I    |
| Debian | 9.0     | Stretch      | linux-4.9    | 1, 2  | B, I    |
| Fedora | 22      | N/A          | linux-3.14.0 |       | B, I    |
| RHEL   | 7       | Maipo        | linux-3.10.0 |       | B, I    |
| Ubuntu | 14.04   | Trusty Tahr  | linux-3.13.0 |       | B, I, C |
| Ubuntu | 16.04   | Xenial Xerus | linux-4.4.0  | 3     | B, I, C |

## 竞品对比

### 对比raid

`RAID`(Redundant Array of Independent Disks)即独立冗余磁盘阵列，是一种把多块独立的硬盘（物理硬盘）按不同的方式组合起来形成一个硬盘组（逻辑硬盘），让用户认为只有一个单个超大硬盘，从而提供比单个硬盘更高的存储性能和提供数据备份技术

- [RAID]()
    - 漫长的重建过程，而且在重建过程中，不能有第二块盘损坏，否则会引发更大的问题；
    
    - 备用盘增加[TCO](https://baike.baidu.com/item/tco/5979397?fr=aladdin) ，作为备用盘，当没有硬盘故障时，就会一直闲置的

    - 不能保证两块盘同时故障后，数据的可靠性

    - 在重建结束前，客户端无法获取到足够的`IO`资源

    - 无法避免网络、服务器硬件、操作系统、电源等故障

- [Ceph]()
    - 为了保证可靠性，采用了数据复制的方式，这意味着不再需要`RAID`，也就克服了`RAID`存在的诸多问题
    
    - `Ceph` 数据存储原则：一个`Pool` 有若干`PG`，每个`PG` 包含若干对象，一个对象只能存储在一个`PG`中，而`Ceph` 默认一个`PG` 包含三个`OSD`，每个`OSD`都可看做一块硬盘。
    因此，一个对象存储在`Ceph`中时，就被保存了三份。当一个磁盘故障时，还剩下2个`PG`，系统就会从另外两个`PG`中复制数据到其他磁盘上。这个是由`crush`算法决定

    - 磁盘复制属性值可以通过管理员进行调整

    - 磁盘存储上使用了加权机制，所以磁盘大小不一致也不会出现问题

### 对比SAN、NAS、DAS

- DAS

    `Direct Attached Storage`，即直连附加存储，第一代存储系统，通过`SCSI`总线扩展至一个外部的存储，磁带整列，作为服务器扩展的一部分

- NAS

    `Network Attached Storage`，即网络附加存储，通过网络协议如`NFS`远程获取后端文件服务器共享的存储空间，将文件存储单独分离出来
    
- SAN

    `Storage Area Network`，即存储区域网络，分为`IP-SAN`和`FC-SAN`，即通过`TCP/IP`协议和`FC`(Fiber Channel)光纤协议连接到存储服务器
    
- Ceph

    `Ceph`在一个统一的存储系统中同时提供了对象存储、块存储和文件存储，即`Ceph`是一个统一存储，能够将企业企业中的三种存储需求统一汇总到一个存储系统中，并提供分布式、横向扩展，高度可靠性的存储系统
    
**主要区别如下：**

- `DAS`直连存储服务器使用`SCSI`或`FC`协议连接到存储阵列、通过`SCSI`总线和`FC`光纤协议类型进行数据传输；
例如一块有空间大小的裸磁盘：`/dev/sdb`。`DAS`存储虽然组网简单、成本低廉但是可扩展性有限、无法多主机实现共享、目前已经很少使用

- `NAS`网络存储服务器使用`TCP`网络协议连接至文件共享存储、常见的有`NFS`、`CIFS`协议等；通过网络的方式映射存储中的一个目录到目标主机，如`/data`。
`NAS`网络存储使用简单，通过`IP`协议实现互相访问，多台主机可以同时共享同一个存储。但是`NAS`网络存储的性能有限，可靠性不是很高。

- `SAN`存储区域网络服务器使用一个存储区域网络`IP`或`FC`连接到存储阵列、常见的`SAN`协议类型有`IP-SAN`和`FC-SAN`。`SAN`存储区域网络的性能非常好、可扩展性强；但是成本特别高、尤其是`FC`存储网络：因为需要用到`HBA`卡、`FC`交换机和支持`FC`接口的存储



    | 存储结构/性能对比 | DAS | NAS | FC-SAN | IP-SAN | Ceph |
    | :----:| :----: | :----: | :----: | :----: | :----: |
    | 成本 | 低 | 较低 | 高 | 较高 | 高 |
    | 数据传输速度 | 快 | 慢 | 极快 | 较快 | 快 |
    | 扩展性 | 无扩展性 | 较低 | 易于扩展 | 最易扩展 | 易于扩展 |
    | 服务器访问存储方式 | 块 | 文件 | 块 | 块 | 对象、文件、块 |
    | 服务器系统性能开销 | 低 | 较低 | 低 | 较高 | 低 |
    | 安全性 | 高 | 低 | 高 | 低 | 高 |
    | 是否集中管理存储 | 否 | 是 | 是 | 是 | 否 |
    | 备份效率 | 低 | 较低 | 高 | 较高 | 高 |
    | 网络传输协议 | 无 | TCP/IP | FC | TCP/IP | 私有协议(TCP) |
    
### 对比其他分布式存储

## 集成部署
### ceph-deploy部署N版

- 节点信息


    | 节点名称 | 节点IP | 节点属性 |
    | :----:| :----: | :----: |
    | ceph01 | 192.168.1.69 | admin,deploy,mon |
    | ceph02 | 192.168.1.70 | 单元格 |
    | ceph03 | 192.168.1.70 | 单元格 |
    
> 前置要求

- `yum`联网(可通过配置代理实现)
- `ceph`节点配置时钟同步

> 配置阿里云仓储（所有节点）

    cat > /etc/yum.repos.d/ceph.repo <<EOF
    [Ceph]
    name=Ceph \$basearch
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/\$basearch
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    
    [Ceph-noarch]
    name=Ceph noarch
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/noarch
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    
    [Ceph-source]
    name=Ceph SRPMS
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/SRPMS
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    EOF

> 创建ceph目录(deploy节点)

    mkdir -p /etc/ceph
    
> 配置主机互信(deploy节点)

    ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa
    ssh-copy-id ceph01
    ssh-copy-id ceph02
    ssh-copy-id ceph03
    
> 安装`ceph`(所有节点)

    yum install -y ceph
    
> 初始化mon节点(deploy节点)

    ceph-deploy new ceph01 ceph02 ceph03
    
> 初始化`mon`(deploy节点)

     ceph-deploy mon create-initial
     
> 修改集群文件(deploy节点)

    cd /etc/ceph/
    echo "public_network=192.168.1.0/24" >> /etc/ceph/ceph.conf
    ceph-deploy --overwrite-conf config push ceph01 ceph02 ceph03
    
> 查看集群状态

    [root@ceph01 ~]# ceph -s
      cluster:
        id:     b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
        health: HEALTH_WARN
                mon ceph03 is low on available space
    
      services:
        mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 31m)
        mgr: no daemons active
        osd: 0 osds: 0 up, 0 in
    
      data:
        pools:   0 pools, 0 pgs
        objects: 0 objects, 0 B
        usage:   0 B used, 0 B / 0 B avail
        pgs:
    
> 安装命令补全

    yum -y install bash-completion
    
> 安装dashboard

1.安装

    yum install -y ceph-mgr-dashboard
    
2.禁用 SSL

    ceph config set mgr mgr/dashboard/ssl false

3.配置 host 和 port

    ceph config set mgr mgr/dashboard/server_addr $IP
    ceph config set mgr mgr/dashboard/server_port $PORT
    
4.启用 Dashboard

    ceph mgr module enable dashboard
    
5.用户、密码、权限

    # 创建用户
    #ceph dashboard ac-user-create <username> <password> administrator
    ceph dashboard ac-user-create admin Ceph-12345 administrator
    
6.查看 Dashboard 地址
  
    ceph mgr services
    
x.使变更的配置生效
    
    ceph mgr module disable dashboard
    ceph mgr module enable dashboard
    
xx.配置访问前缀
   
    ceph config set mgr mgr/dashboard/url_prefix /ceph-ui

## 运维管理
### ceph添加磁盘

> 列出节点`node3`磁盘信息

    ceph-deploy disk list node3
    
输出如下

    ...
    [ceph_deploy.conf][DEBUG ] found configuration file at: /root/.cephdeploy.conf
    [ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list node3
    [ceph_deploy.cli][INFO  ] ceph-deploy options:
    [ceph_deploy.cli][INFO  ]  username                      : None
    [ceph_deploy.cli][INFO  ]  verbose                       : False
    [ceph_deploy.cli][INFO  ]  debug                         : False
    [ceph_deploy.cli][INFO  ]  overwrite_conf                : False
    [ceph_deploy.cli][INFO  ]  subcommand                    : list
    [ceph_deploy.cli][INFO  ]  quiet                         : False
    [ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f747adb66c8>
    [ceph_deploy.cli][INFO  ]  cluster                       : ceph
    [ceph_deploy.cli][INFO  ]  host                          : ['node3']
    [ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7f747b00a938>
    [ceph_deploy.cli][INFO  ]  ceph_conf                     : None
    [ceph_deploy.cli][INFO  ]  default_release               : False
    [node3][DEBUG ] connected to host: node3
    [node3][DEBUG ] detect platform information from remote host
    [node3][DEBUG ] detect machine type
    [node3][DEBUG ] find the location of an executable
    [node3][INFO  ] Running command: fdisk -l
    [node3][INFO  ] Disk /dev/nvme1n1: 2000.4 GB, 2000398934016 bytes, 3907029168 sectors
    [node3][INFO  ] Disk /dev/nvme0n1: 2000.4 GB, 2000398934016 bytes, 3907029168 sectors
    [node3][INFO  ] Disk /dev/nvme2n1: 2000.4 GB, 2000398934016 bytes, 3907029168 sectors
    [node3][INFO  ] Disk /dev/nvme3n1: 2000.4 GB, 2000398934016 bytes, 3907029168 sectors
    [node3][INFO  ] Disk /dev/mapper/centos00-root: 1998.0 GB, 1998036402176 bytes, 3902414848 sectors
    [node3][INFO  ] Disk /dev/sdf: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdg: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdb: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sde: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdk: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sda: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdd: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdh: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdj: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdc: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdi: 480.1 GB, 480103981056 bytes, 937703088 sectors
    ...
 
> 查看磁盘挂载

    lsblk
    
输出如下

    NAME              MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sdf                 8:80   0 894.3G  0 disk
    nvme0n1           259:1    0   1.8T  0 disk
    ├─nvme0n1p3       259:6    0   1.8T  0 part
    │ └─centos00-root 253:0    0   1.8T  0 lvm  /
    ├─nvme0n1p1       259:4    0   200M  0 part /boot/efi
    └─nvme0n1p2       259:5    0     2G  0 part /boot
    sdd                 8:48   0 894.3G  0 disk
    nvme3n1           259:3    0   1.8T  0 disk
    sdb                 8:16   0 894.3G  0 disk
    sdk                 8:160  0 894.3G  0 disk
    sdi                 8:128  0 447.1G  0 disk
    nvme2n1           259:2    0   1.8T  0 disk
    sr0                11:0    1   4.2G  0 rom
    sdg                 8:96   0 894.3G  0 disk
    sde                 8:64   0 894.3G  0 disk
    sdc                 8:32   0 894.3G  0 disk
    nvme1n1           259:0    0   1.8T  0 disk
    sda                 8:0    0 894.3G  0 disk
    sdj                 8:144  0 894.3G  0 disk
    sdh                 8:112  0 894.3G  0 disk
    
磁盘类型说明

    sda-sdk 为SSD类型，sda先不加入集群
    nvme0n1、nvme1n1、nvme2n1、nvme3n1为nvme类型
    系统盘：nvme0n1
   
    
> 擦净节点SSD类型磁盘

    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy disk zap node3 /dev/sd$i
    done
    
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy disk zap node4 /dev/sd$i
    done
    
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy disk zap node5 /dev/sd$i
    done
    
> 创建SSD类型OSD节点
 
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy osd create --data /dev/sd$i node3
    done
    
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy osd create --data /dev/sd$i node4
    done
        
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy osd create --data /dev/sd$i node5
    done
    
> 擦净节点nvme类型磁盘

    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy disk zap node3 /dev/nvme${i}n1
    done
    
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy disk zap node4 /dev/nvme${i}n1
    done
    
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy disk zap node5 /dev/nvme${i}n1
    done
    
> 创建nvme类型OSD节点
 
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy osd create --data /dev/nvme${i}n1 node3
    done
    
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy osd create --data /dev/nvme${i}n1 node4
    done
        
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy osd create --data /dev/nvme${i}n1 node5
    done
    
> 查看集群osd crush tree

    cd /etc/ceph/cluster
    ceph osd crush tree --show-shadow
    
回显如下

    ID CLASS WEIGHT   TYPE NAME
    -2   SSD 41.26323 root default~SSD
    -4   SSD 13.75441     host node3~SSD
     0   SSD  0.87329         osd.0
     1   SSD  0.87329         osd.1
     2   SSD  0.87329         osd.2
     3   SSD  0.87329         osd.3
     4   SSD  0.87329         osd.4
     5   SSD  0.87329         osd.5
     6   SSD  0.87329         osd.6
     7   SSD  0.43660         osd.7
     8   SSD  0.87329         osd.8
     9   SSD  0.87329         osd.9
    30   SSD  1.81940         osd.30
    31   SSD  1.81940         osd.31
    32   SSD  1.81940         osd.32
    -6   SSD 13.75441     host node4~SSD
    10   SSD  0.43660         osd.10
    11   SSD  0.87329         osd.11
    12   SSD  0.87329         osd.12
    13   SSD  0.87329         osd.13
    14   SSD  0.87329         osd.14
    15   SSD  0.87329         osd.15
    16   SSD  0.87329         osd.16
    17   SSD  0.87329         osd.17
    18   SSD  0.87329         osd.18
    19   SSD  0.87329         osd.19
    33   SSD  1.81940         osd.33
    34   SSD  1.81940         osd.34
    35   SSD  1.81940         osd.35
    -8   SSD 13.75441     host node5~SSD
    20   SSD  0.43660         osd.20
    21   SSD  0.87329         osd.21
    22   SSD  0.87329         osd.22
    23   SSD  0.87329         osd.23
    24   SSD  0.87329         osd.24
    25   SSD  0.87329         osd.25
    26   SSD  0.87329         osd.26
    27   SSD  0.87329         osd.27
    28   SSD  0.87329         osd.28
    29   SSD  0.87329         osd.29
    36   SSD  1.81940         osd.36
    37   SSD  1.81940         osd.37
    38   SSD  1.81940         osd.38
    -1       41.26323 root default
    -3       13.75441     host node3
     0   SSD  0.87329         osd.0
     1   SSD  0.87329         osd.1
     2   SSD  0.87329         osd.2
     3   SSD  0.87329         osd.3
     4   SSD  0.87329         osd.4
     5   SSD  0.87329         osd.5
     6   SSD  0.87329         osd.6
     7   SSD  0.43660         osd.7
     8   SSD  0.87329         osd.8
     9   SSD  0.87329         osd.9
    30   SSD  1.81940         osd.30
    31   SSD  1.81940         osd.31
    32   SSD  1.81940         osd.32
    -5       13.75441     host node4
    10   SSD  0.43660         osd.10
    11   SSD  0.87329         osd.11
    12   SSD  0.87329         osd.12
    13   SSD  0.87329         osd.13
    14   SSD  0.87329         osd.14
    15   SSD  0.87329         osd.15
    16   SSD  0.87329         osd.16
    17   SSD  0.87329         osd.17
    18   SSD  0.87329         osd.18
    19   SSD  0.87329         osd.19
    33   SSD  1.81940         osd.33
    34   SSD  1.81940         osd.34
    35   SSD  1.81940         osd.35
    -7       13.75441     host node5
    20   SSD  0.43660         osd.20
    21   SSD  0.87329         osd.21
    22   SSD  0.87329         osd.22
    23   SSD  0.87329         osd.23
    24   SSD  0.87329         osd.24
    25   SSD  0.87329         osd.25
    26   SSD  0.87329         osd.26
    27   SSD  0.87329         osd.27
    28   SSD  0.87329         osd.28
    29   SSD  0.87329         osd.29
    36   SSD  1.81940         osd.36
    37   SSD  1.81940         osd.37
    38   SSD  1.81940         osd.38

> 修改nvme类型class

    ceph osd crush rm-device-class 30
    ceph osd crush set-device-class nvme osd.30
    ceph osd crush rm-device-class 31
    ceph osd crush set-device-class nvme osd.31
    ceph osd crush rm-device-class 32
    ceph osd crush set-device-class nvme osd.32
    
    ceph osd crush rm-device-class 33
    ceph osd crush set-device-class nvme osd.33
    ceph osd crush rm-device-class 34
    ceph osd crush set-device-class nvme osd.34
    ceph osd crush rm-device-class 35
    ceph osd crush set-device-class nvme osd.35
    
    ceph osd crush rm-device-class 36
    ceph osd crush set-device-class nvme osd.36
    ceph osd crush rm-device-class 37
    ceph osd crush set-device-class nvme osd.37
    ceph osd crush rm-device-class 38
    ceph osd crush set-device-class nvme osd.38
    
查看集群osd crush tree

    cd /etc/ceph/cluster
    ceph osd crush tree --show-shadow

回显

    ID  CLASS WEIGHT   TYPE NAME
    -12  nvme 16.37457 root default~nvme
     -9  nvme  5.45819     host node3~nvme
     30  nvme  1.81940         osd.30
     31  nvme  1.81940         osd.31
     32  nvme  1.81940         osd.32
    -10  nvme  5.45819     host node4~nvme
     33  nvme  1.81940         osd.33
     34  nvme  1.81940         osd.34
     35  nvme  1.81940         osd.35
    -11  nvme  5.45819     host node5~nvme
     36  nvme  1.81940         osd.36
     37  nvme  1.81940         osd.37
     38  nvme  1.81940         osd.38
     -2   SSD 24.88866 root default~SSD
     -4   SSD  8.29622     host node3~SSD
      0   SSD  0.87329         osd.0
      1   SSD  0.87329         osd.1
      2   SSD  0.87329         osd.2
      3   SSD  0.87329         osd.3
      4   SSD  0.87329         osd.4
      5   SSD  0.87329         osd.5
      6   SSD  0.87329         osd.6
      7   SSD  0.43660         osd.7
      8   SSD  0.87329         osd.8
      9   SSD  0.87329         osd.9
     -6   SSD  8.29622     host node4~SSD
     10   SSD  0.43660         osd.10
     11   SSD  0.87329         osd.11
     12   SSD  0.87329         osd.12
     13   SSD  0.87329         osd.13
     14   SSD  0.87329         osd.14
     15   SSD  0.87329         osd.15
     16   SSD  0.87329         osd.16
     17   SSD  0.87329         osd.17
     18   SSD  0.87329         osd.18
     19   SSD  0.87329         osd.19
     -8   SSD  8.29622     host node5~SSD
     20   SSD  0.43660         osd.20
     21   SSD  0.87329         osd.21
     22   SSD  0.87329         osd.22
     23   SSD  0.87329         osd.23
     24   SSD  0.87329         osd.24
     25   SSD  0.87329         osd.25
     26   SSD  0.87329         osd.26
     27   SSD  0.87329         osd.27
     28   SSD  0.87329         osd.28
     29   SSD  0.87329         osd.29
     -1       41.26323 root default
     -3       13.75441     host node3
     30  nvme  1.81940         osd.30
     31  nvme  1.81940         osd.31
     32  nvme  1.81940         osd.32
      0   SSD  0.87329         osd.0
      1   SSD  0.87329         osd.1
      2   SSD  0.87329         osd.2
      3   SSD  0.87329         osd.3
      4   SSD  0.87329         osd.4
      5   SSD  0.87329         osd.5
      6   SSD  0.87329         osd.6
      7   SSD  0.43660         osd.7
      8   SSD  0.87329         osd.8
      9   SSD  0.87329         osd.9
     -5       13.75441     host node4
     33  nvme  1.81940         osd.33
     34  nvme  1.81940         osd.34
     35  nvme  1.81940         osd.35
     10   SSD  0.43660         osd.10
     11   SSD  0.87329         osd.11
     12   SSD  0.87329         osd.12
     13   SSD  0.87329         osd.13
     14   SSD  0.87329         osd.14
     15   SSD  0.87329         osd.15
     16   SSD  0.87329         osd.16
     17   SSD  0.87329         osd.17
     18   SSD  0.87329         osd.18
     19   SSD  0.87329         osd.19
     -7       13.75441     host node5
     36  nvme  1.81940         osd.36
     37  nvme  1.81940         osd.37
     38  nvme  1.81940         osd.38
     20   SSD  0.43660         osd.20
     21   SSD  0.87329         osd.21
     22   SSD  0.87329         osd.22
     23   SSD  0.87329         osd.23
     24   SSD  0.87329         osd.24
     25   SSD  0.87329         osd.25
     26   SSD  0.87329         osd.26
     27   SSD  0.87329         osd.27
     28   SSD  0.87329         osd.28
     29   SSD  0.87329         osd.29


> 添加节点`/dev/sda`磁盘
 
    cd /etc/ceph/cluster
    ceph-deploy osd create --data /dev/sda node3
    
    cd /etc/ceph/cluster
    ceph-deploy osd create --data /dev/sda node4
        
    cd /etc/ceph/cluster
    ceph-deploy osd create --data /dev/sda node5
    
擦净节点`/dev/sda`磁盘

    cd /etc/ceph/cluster
    ceph-deploy disk zap node3 /dev/sda
    
    cd /etc/ceph/cluster
    ceph-deploy disk zap node4 /dev/sda
    
    cd /etc/ceph/cluster
    ceph-deploy disk zap node5 /dev/sda
    
查看集群osd crush tree

    cd /etc/ceph/cluster
    ceph osd crush tree --show-shadow
    
    
回显

     -9  nvme  5.45819     host node3~nvme
     30  nvme  1.81940         osd.30
     31  nvme  1.81940         osd.31
     32  nvme  1.81940         osd.32
    -10  nvme  5.45819     host node4~nvme
     33  nvme  1.81940         osd.33
     34  nvme  1.81940         osd.34
     35  nvme  1.81940         osd.35
    -11  nvme  5.45819     host node5~nvme
     36  nvme  1.81940         osd.36
     37  nvme  1.81940         osd.37
     38  nvme  1.81940         osd.38
     -2   SSD 27.50853 root default~SSD
     -4   SSD  9.16951     host node3~SSD
      0   SSD  0.87329         osd.0
      1   SSD  0.87329         osd.1
      2   SSD  0.87329         osd.2
      3   SSD  0.87329         osd.3
      4   SSD  0.87329         osd.4
      5   SSD  0.87329         osd.5
      6   SSD  0.87329         osd.6
      7   SSD  0.43660         osd.7
      8   SSD  0.87329         osd.8
      9   SSD  0.87329         osd.9
     39   SSD  0.87329         osd.39
     -6   SSD  9.16951     host node4~SSD
     10   SSD  0.43660         osd.10
     11   SSD  0.87329         osd.11
     12   SSD  0.87329         osd.12
     13   SSD  0.87329         osd.13
     14   SSD  0.87329         osd.14
     15   SSD  0.87329         osd.15
     16   SSD  0.87329         osd.16
     17   SSD  0.87329         osd.17
     18   SSD  0.87329         osd.18
     19   SSD  0.87329         osd.19
     40   SSD  0.87329         osd.40
     -8   SSD  9.16951     host node5~SSD
     20   SSD  0.43660         osd.20
     21   SSD  0.87329         osd.21
     22   SSD  0.87329         osd.22
     23   SSD  0.87329         osd.23
     24   SSD  0.87329         osd.24
     25   SSD  0.87329         osd.25
     26   SSD  0.87329         osd.26
     27   SSD  0.87329         osd.27
     28   SSD  0.87329         osd.28
     29   SSD  0.87329         osd.29
     41   SSD  0.87329         osd.41
     -1       43.88310 root default
     -3       14.62770     host node3
     30  nvme  1.81940         osd.30
     31  nvme  1.81940         osd.31
     32  nvme  1.81940         osd.32
      0   SSD  0.87329         osd.0
      1   SSD  0.87329         osd.1
      2   SSD  0.87329         osd.2
      3   SSD  0.87329         osd.3
      4   SSD  0.87329         osd.4
      5   SSD  0.87329         osd.5
      6   SSD  0.87329         osd.6
      7   SSD  0.43660         osd.7
      8   SSD  0.87329         osd.8
      9   SSD  0.87329         osd.9
     39   SSD  0.87329         osd.39
     -5       14.62770     host node4
     33  nvme  1.81940         osd.33
     34  nvme  1.81940         osd.34
     35  nvme  1.81940         osd.35
     10   SSD  0.43660         osd.10
     11   SSD  0.87329         osd.11
     12   SSD  0.87329         osd.12
     13   SSD  0.87329         osd.13
     14   SSD  0.87329         osd.14
     15   SSD  0.87329         osd.15
     16   SSD  0.87329         osd.16
     17   SSD  0.87329         osd.17
     18   SSD  0.87329         osd.18
     19   SSD  0.87329         osd.19
     40   SSD  0.87329         osd.40
     -7       14.62770     host node5
     36  nvme  1.81940         osd.36
     37  nvme  1.81940         osd.37
     38  nvme  1.81940         osd.38
     20   SSD  0.43660         osd.20
     21   SSD  0.87329         osd.21
     22   SSD  0.87329         osd.22
     23   SSD  0.87329         osd.23
     24   SSD  0.87329         osd.24
     25   SSD  0.87329         osd.25
     26   SSD  0.87329         osd.26
     27   SSD  0.87329         osd.27
     28   SSD  0.87329         osd.28
     29   SSD  0.87329         osd.29
     41   SSD  0.87329         osd.41
     
### crush pool

> 创建crush rule

    #ceph osd crush rule create-replicated <rule-name> <root> <failure-domain> <class>

创建`class` 为`SSD`的rule

    ceph osd crush rule create-replicated SSD_rule default host SSD
    
创建`class` 为`nvme`的rule

    ceph osd crush rule create-replicated nvme_rule default host nvme
    
> 创建资源池

    #ceph osd pool create {pool_name} {pg_num} [{pgp_num}]
    ceph osd pool create container-pool 250 250
    
> 查看`container-pool`crush rule

    ceph osd pool get container-pool crush_rule
    
回显

    crush_rule: replicated_rule

> 设置`container-pool`crush rule为`SSD_rule`

    #ceph osd pool set <pool-name> crush_rule <rule-name>
    ceph osd pool set container-pool crush_rule SSD_rule

查看`container-pool`crush rule

    ceph osd pool get container-pool crush_rule
    
回显
 
    crush_rule: SSD_rule
    
> 设置`container-pool`配额

    #osd pool set-quota <poolname> max_objects|max_bytes <val>

设置最大对象数10

    ceph osd pool set-quota container-pool max_objects 10
    
设置存储大小为2G

    ceph osd pool set-quota container-pool max_bytes 2G
    
> 扩容`container-pool`配额

    #osd pool set-quota <poolname> max_objects|max_bytes <val>
    
设置最大对象数10W

    ceph osd pool set-quota container-pool max_objects 100000
    
设置存储大小为2T

    ceph osd pool set-quota container-pool max_bytes 2T
    
> 修改`container-pool`为`harbor-pool`

     ceph osd pool rename container-pool harbor-pool
     
### 块设备（rdb）使用
    
**ceph客户端**

> 配置yum

    cat > /etc/yum.repos.d/ceph.repo <<EOF
    [Ceph]
    name=Ceph \$basearch
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/\$basearch
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    
    [Ceph-noarch]
    name=Ceph noarch
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/noarch
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    
    [Ceph-source]
    name=Ceph SRPMS
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/SRPMS
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    EOF

> 安装客户端

    yum install -y epel-release
    yum install -y ceph-common
    
> 拷贝配置文件

客户端创建配置目录

    mkdir -p /etc/ceph
    
客户端创建挂载目录

    mkdir -p /ceph
    chmod 777 /ceph
    
从服务端`scp`以下文件至客户端/etc/ceph下

- /etc/ceph/ceph.client.admin.keyring
- /etc/ceph/ceph.conf


    scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} ip:/etc/ceph/
    
> 创建块设备(客户端执行)

    rbd create --pool harbor-pool --image harbor-img --image-format 2 --image-feature layering --size 2048G

> 映射块设备

    rbd map harbor-pool/harbor-img
    echo "harbor-pool/harbor-img id=admin,keyring=/etc/ceph/ceph.client.admin.keyring" >> /etc/ceph/rbdmap
    
> 格式化块设备

     mkfs.ext4 -q /dev/rbd0
     
> 挂载使用

    mount /dev/rbd0 /ceph

> 查看挂载

    lsblk
 
> 修改fstab，设置开机挂载

    echo "/dev/rbd0 /ceph ext4 defaults,noatime,_netdev 0 0" >> /etc/fstab
    
> 配置开机自启动

    vim /etc/init.d/rbdmap
    
    #!/bin/bash
    #chkconfig: 2345 80 60
    #description: start/stop rbdmap
    ### BEGIN INIT INFO
    # Provides:          rbdmap
    # Required-Start:    $network
    # Required-Stop:     $network
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: Ceph RBD Mapping
    # Description:       Ceph RBD Mapping
    ### END INIT INFO
    
    DESC="RBD Mapping"
    RBDMAPFILE="/etc/ceph/rbdmap"
    
    . /lib/lsb/init-functions
    #. /etc/redhat-lsb/lsb_log_message，加入此行后不正长
    do_map() {
        if [ ! -f "$RBDMAPFILE" ]; then
            echo "$DESC : No $RBDMAPFILE found."
            exit 0
        fi
    
        echo "Starting $DESC"
        # Read /etc/rbdtab to create non-existant mapping
        newrbd=
        RET=0
        while read DEV PARAMS; do
            case "$DEV" in
              ""|\#*)
                continue
                ;;
              */*)
                ;;
              *)
                DEV=rbd/$DEV
                ;;
            esac
            OIFS=$IFS
            IFS=','
            for PARAM in ${PARAMS[@]}; do
                CMDPARAMS="$CMDPARAMS --$(echo $PARAM | tr '=' ' ')"
            done
            IFS=$OIFS
            if [ ! -b /dev/rbd/$DEV ]; then
                echo $DEV
                rbd map $DEV $CMDPARAMS
                [ $? -ne "0" ] && RET=1
                newrbd="yes"
            fi
        done < $RBDMAPFILE
        echo $RET
    
        # Mount new rbd
        if [ "$newrbd" ]; then
                    echo "Mounting all filesystems"
            mount -a
            echo $?
        fi
    }
    
    do_unmap() {
        echo "Stopping $DESC"
        RET=0
        # Unmap all rbd device
        for DEV in /dev/rbd[0-9]*; do
            echo $DEV
            # Umount before unmap
            MNTDEP=$(findmnt --mtab --source $DEV --output TARGET | sed 1,1d | sort -r)
            for MNT in $MNTDEP; do
                umount $MNT || sleep 1 && umount -l $DEV
            done
            rbd unmap $DEV
            [ $? -ne "0" ] && RET=1
        done
        echo $RET
    }
    
    
    case "$1" in
      start)
        do_map
        ;;
    
      stop)
        do_unmap
        ;;
    
      reload)
        do_map
        ;;
    
      status)
        rbd showmapped
        ;;
    
      *)
        echo "Usage: rbdmap {start|stop|reload|status}"
        exit 1
        ;;
    esac
    
    exit 0


赋权
    
    yum install redhat-lsb -y
    chmod +x /etc/init.d/rbdmap
    service rbdmap start 
    chkconfig rbdmap on
    
### k8s对接cephfs

> 下载所需镜像

    quay.io/external_storage/cephfs-provisioner:latest
    
> 安装

    git clone https://github.com/kubernetes-retired/external-storage.git
    external-storage/ceph/cephfs/deploy/
    NAMESPACE=kube-system
    sed -r -i "s/namespace: [^ ]+/namespace: $NAMESPACE/g" ./rbac/*.yaml
    sed -i "/PROVISIONER_SECRET_NAMESPACE/{n;s/value:.*/value: $NAMESPACE/;}" rbac/deployment.yaml
    kubectl -n $NAMESPACE apply -f ./rbac
    
### 卸载

    ceph-deploy purge ceph01 ceph02 ceph03
    
    ceph-deploy purgedata ceph01 ceph02 ceph03
    
    ceph-deploy forgetkeys
    
    rm -rf /var/lib/ceph
    
    
## 参考文献

- [SAN和NAS之间的基本区别](https://www.cnblogs.com/cainiao-chuanqi/p/12204944.html)
    
