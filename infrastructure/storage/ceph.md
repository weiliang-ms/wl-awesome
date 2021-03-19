<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [导读](#%E5%AF%BC%E8%AF%BB)
  - [说明](#%E8%AF%B4%E6%98%8E)
  - [索引](#%E7%B4%A2%E5%BC%95)
- [Ceph解析](#ceph%E8%A7%A3%E6%9E%90)
  - [Ceph术语](#ceph%E6%9C%AF%E8%AF%AD)
  - [Ceph存储集群](#ceph%E5%AD%98%E5%82%A8%E9%9B%86%E7%BE%A4)
    - [`Ceph`数据存储流程](#ceph%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8%E6%B5%81%E7%A8%8B)
    - [`Ceph`的可伸缩性和高可用性](#ceph%E7%9A%84%E5%8F%AF%E4%BC%B8%E7%BC%A9%E6%80%A7%E5%92%8C%E9%AB%98%E5%8F%AF%E7%94%A8%E6%80%A7)
  - [`CRUSH`算法介绍](#crush%E7%AE%97%E6%B3%95%E4%BB%8B%E7%BB%8D)
    - [`mon`高可用](#mon%E9%AB%98%E5%8F%AF%E7%94%A8)
  - [身份认证高可用性](#%E8%BA%AB%E4%BB%BD%E8%AE%A4%E8%AF%81%E9%AB%98%E5%8F%AF%E7%94%A8%E6%80%A7)
  - [动态集群管理](#%E5%8A%A8%E6%80%81%E9%9B%86%E7%BE%A4%E7%AE%A1%E7%90%86)
  - [分级缓存](#%E5%88%86%E7%BA%A7%E7%BC%93%E5%AD%98)
  - [Ceph协议](#ceph%E5%8D%8F%E8%AE%AE)
    - [`Ceph`协议与`librados`](#ceph%E5%8D%8F%E8%AE%AE%E4%B8%8Elibrados)
    - [对象观测通知](#%E5%AF%B9%E8%B1%A1%E8%A7%82%E6%B5%8B%E9%80%9A%E7%9F%A5)
  - [数据分段](#%E6%95%B0%E6%8D%AE%E5%88%86%E6%AE%B5)
- [Ceph存储类型](#ceph%E5%AD%98%E5%82%A8%E7%B1%BB%E5%9E%8B)
  - [Ceph块存储](#ceph%E5%9D%97%E5%AD%98%E5%82%A8)
  - [Ceph文件系统](#ceph%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)
    - [部署元数据服务器](#%E9%83%A8%E7%BD%B2%E5%85%83%E6%95%B0%E6%8D%AE%E6%9C%8D%E5%8A%A1%E5%99%A8)
      - [MDS宿主机配置需求](#mds%E5%AE%BF%E4%B8%BB%E6%9C%BA%E9%85%8D%E7%BD%AE%E9%9C%80%E6%B1%82)
  - [Ceph 对象存储](#ceph-%E5%AF%B9%E8%B1%A1%E5%AD%98%E5%82%A8)
  - [竞品对比](#%E7%AB%9E%E5%93%81%E5%AF%B9%E6%AF%94)
    - [对比raid](#%E5%AF%B9%E6%AF%94raid)
    - [对比SAN、NAS、DAS](#%E5%AF%B9%E6%AF%94sannasdas)
    - [对比其他分布式存储](#%E5%AF%B9%E6%AF%94%E5%85%B6%E4%BB%96%E5%88%86%E5%B8%83%E5%BC%8F%E5%AD%98%E5%82%A8)
- [集成部署](#%E9%9B%86%E6%88%90%E9%83%A8%E7%BD%B2)
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
  - [环境说明](#%E7%8E%AF%E5%A2%83%E8%AF%B4%E6%98%8E)
  - [环境初始化](#%E7%8E%AF%E5%A2%83%E5%88%9D%E5%A7%8B%E5%8C%96)
    - [配置yum](#%E9%85%8D%E7%BD%AEyum)
    - [yum依赖导出](#yum%E4%BE%9D%E8%B5%96%E5%AF%BC%E5%87%BA)
    - [配置时钟同步](#%E9%85%8D%E7%BD%AE%E6%97%B6%E9%92%9F%E5%90%8C%E6%AD%A5)
    - [升级内核](#%E5%8D%87%E7%BA%A7%E5%86%85%E6%A0%B8)
    - [raid卡](#raid%E5%8D%A1)
  - [安装ceph](#%E5%AE%89%E8%A3%85ceph)
  - [配置ceph](#%E9%85%8D%E7%BD%AEceph)
    - [添加OSD](#%E6%B7%BB%E5%8A%A0osd)
      - [常见问题解决](#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E8%A7%A3%E5%86%B3)
    - [crush class](#crush-class)
    - [crush pool](#crush-pool)
      - [ssd crush rule](#ssd-crush-rule)
      - [nvme crush rule](#nvme-crush-rule)
      - [测试crush rule](#%E6%B5%8B%E8%AF%95crush-rule)
    - [安装dashboard](#%E5%AE%89%E8%A3%85dashboard)
- [ceph存储实践](#ceph%E5%AD%98%E5%82%A8%E5%AE%9E%E8%B7%B5)
  - [块设备使用](#%E5%9D%97%E8%AE%BE%E5%A4%87%E4%BD%BF%E7%94%A8)
    - [ceph管理节点](#ceph%E7%AE%A1%E7%90%86%E8%8A%82%E7%82%B9)
    - [客户端](#%E5%AE%A2%E6%88%B7%E7%AB%AF)
    - [适用场景](#%E9%80%82%E7%94%A8%E5%9C%BA%E6%99%AF)
  - [ceph文件系统使用](#ceph%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E4%BD%BF%E7%94%A8)
    - [服务端](#%E6%9C%8D%E5%8A%A1%E7%AB%AF)
    - [客户端](#%E5%AE%A2%E6%88%B7%E7%AB%AF-1)
    - [适用场景](#%E9%80%82%E7%94%A8%E5%9C%BA%E6%99%AF-1)
- [k8s对接ceph](#k8s%E5%AF%B9%E6%8E%A5ceph)
  - [k8s-csi](#k8s-csi)
    - [csi简介](#csi%E7%AE%80%E4%BB%8B)
    - [csi设计背景](#csi%E8%AE%BE%E8%AE%A1%E8%83%8C%E6%99%AF)
    - [csi架构](#csi%E6%9E%B6%E6%9E%84)
      - [CSI Controller](#csi-controller)
      - [CSI Node](#csi-node)
  - [k8s接入ceph块存储](#k8s%E6%8E%A5%E5%85%A5ceph%E5%9D%97%E5%AD%98%E5%82%A8)
    - [ceph服务端](#ceph%E6%9C%8D%E5%8A%A1%E7%AB%AF)
    - [k8s节点](#k8s%E8%8A%82%E7%82%B9)
  - [k8s接入ceph文件系统](#k8s%E6%8E%A5%E5%85%A5ceph%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)
    - [ceph服务端](#ceph%E6%9C%8D%E5%8A%A1%E7%AB%AF-1)
    - [k8s节点](#k8s%E8%8A%82%E7%82%B9-1)
- [ceph运维管理](#ceph%E8%BF%90%E7%BB%B4%E7%AE%A1%E7%90%86)
  - [服务启停](#%E6%9C%8D%E5%8A%A1%E5%90%AF%E5%81%9C)
    - [按节点启动所有ceph服务](#%E6%8C%89%E8%8A%82%E7%82%B9%E5%90%AF%E5%8A%A8%E6%89%80%E6%9C%89ceph%E6%9C%8D%E5%8A%A1)
    - [按节点停止所有ceph服务](#%E6%8C%89%E8%8A%82%E7%82%B9%E5%81%9C%E6%AD%A2%E6%89%80%E6%9C%89ceph%E6%9C%8D%E5%8A%A1)
    - [控制节点管理集群所有服务](#%E6%8E%A7%E5%88%B6%E8%8A%82%E7%82%B9%E7%AE%A1%E7%90%86%E9%9B%86%E7%BE%A4%E6%89%80%E6%9C%89%E6%9C%8D%E5%8A%A1)
  - [pool管理](#pool%E7%AE%A1%E7%90%86)
    - [查看`pool`](#%E6%9F%A5%E7%9C%8Bpool)
    - [创建一个pool](#%E5%88%9B%E5%BB%BA%E4%B8%80%E4%B8%AApool)
    - [设置池的放置组数](#%E8%AE%BE%E7%BD%AE%E6%B1%A0%E7%9A%84%E6%94%BE%E7%BD%AE%E7%BB%84%E6%95%B0)
    - [获取池的放置组数](#%E8%8E%B7%E5%8F%96%E6%B1%A0%E7%9A%84%E6%94%BE%E7%BD%AE%E7%BB%84%E6%95%B0)
    - [获取集群的PG统计信息](#%E8%8E%B7%E5%8F%96%E9%9B%86%E7%BE%A4%E7%9A%84pg%E7%BB%9F%E8%AE%A1%E4%BF%A1%E6%81%AF)
    - [将池与应用程序关联](#%E5%B0%86%E6%B1%A0%E4%B8%8E%E5%BA%94%E7%94%A8%E7%A8%8B%E5%BA%8F%E5%85%B3%E8%81%94)
    - [池配额](#%E6%B1%A0%E9%85%8D%E9%A2%9D)
    - [删除池](#%E5%88%A0%E9%99%A4%E6%B1%A0)
    - [池重命名](#%E6%B1%A0%E9%87%8D%E5%91%BD%E5%90%8D)
    - [显示池统计信息](#%E6%98%BE%E7%A4%BA%E6%B1%A0%E7%BB%9F%E8%AE%A1%E4%BF%A1%E6%81%AF)
    - [创建池快照](#%E5%88%9B%E5%BB%BA%E6%B1%A0%E5%BF%AB%E7%85%A7)
    - [删除池快照](#%E5%88%A0%E9%99%A4%E6%B1%A0%E5%BF%AB%E7%85%A7)
    - [池其他配置](#%E6%B1%A0%E5%85%B6%E4%BB%96%E9%85%8D%E7%BD%AE)
    - [设置对象副本数](#%E8%AE%BE%E7%BD%AE%E5%AF%B9%E8%B1%A1%E5%89%AF%E6%9C%AC%E6%95%B0)
    - [pg_autoscale_mode](#pg_autoscale_mode)
    - [指定池的期望大小](#%E6%8C%87%E5%AE%9A%E6%B1%A0%E7%9A%84%E6%9C%9F%E6%9C%9B%E5%A4%A7%E5%B0%8F)
    - [放置组数配置](#%E6%94%BE%E7%BD%AE%E7%BB%84%E6%95%B0%E9%85%8D%E7%BD%AE)
    - [放置组解析](#%E6%94%BE%E7%BD%AE%E7%BB%84%E8%A7%A3%E6%9E%90)
    - [放置组权衡](#%E6%94%BE%E7%BD%AE%E7%BB%84%E6%9D%83%E8%A1%A1)
  - [rbd管理](#rbd%E7%AE%A1%E7%90%86)
    - [创建](#%E5%88%9B%E5%BB%BA)
    - [查看块设备映像](#%E6%9F%A5%E7%9C%8B%E5%9D%97%E8%AE%BE%E5%A4%87%E6%98%A0%E5%83%8F)
    - [调整块设备映像的大小](#%E8%B0%83%E6%95%B4%E5%9D%97%E8%AE%BE%E5%A4%87%E6%98%A0%E5%83%8F%E7%9A%84%E5%A4%A7%E5%B0%8F)
      - [缩容](#%E7%BC%A9%E5%AE%B9)
      - [扩容](#%E6%89%A9%E5%AE%B9)
    - [删除块设备映像](#%E5%88%A0%E9%99%A4%E5%9D%97%E8%AE%BE%E5%A4%87%E6%98%A0%E5%83%8F)
    - [挂载块设备](#%E6%8C%82%E8%BD%BD%E5%9D%97%E8%AE%BE%E5%A4%87)
  - [卸载](#%E5%8D%B8%E8%BD%BD)
    - [删除文件系统](#%E5%88%A0%E9%99%A4%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)
    - [删除池](#%E5%88%A0%E9%99%A4%E6%B1%A0-1)
    - [删除OSD](#%E5%88%A0%E9%99%A4osd)
    - [卸载组件并清空目录](#%E5%8D%B8%E8%BD%BD%E7%BB%84%E4%BB%B6%E5%B9%B6%E6%B8%85%E7%A9%BA%E7%9B%AE%E5%BD%95)
  - [参考文献](#%E5%8F%82%E8%80%83%E6%96%87%E7%8C%AE)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 导读
## 说明

- `ceph`相关于`nfs`性能较高，且能提供块存储、文件系统、对象存储网关三种类型存储。

- `ceph`集成部署较为简单、且成本较低(相对于`nas`、`SAN`)

- `ceph`可利用现有服务器资源（裸金属服务器），而不用额外购买存储设备。构建高性能、高可用的统一存储系统，供公司内部适用

- 主流云计算系统（Openstack等）一般选取`ceph`作为后端存储，说明其优异性

- `ceph`开源，相比商用软件有天然优势

## 索引

本文章篇幅较长，具体可分以下部分：

- [ceph架构](#Ceph架构解析)：解析`ceph`架构，介绍`ceph`各组件功能，及集群管理等内容

- [ceph存储类型](#Ceph存储类型)：解析`ceph`块存储、文件系统、对象存储网关

- [集成部署](#集成部署)：基于`CentOS7`搭建`ceph HA`集群

- [ceph最佳实践](#ceph最佳实践])：`ceph`应用场景，包括与`k8s`集成

# Ceph解析

`Ceph`是一个提供对象存储、块存储和文件存储的统一存储系统。
`Ceph`是高度可靠、易于管理和免费的。`Ceph`的强大功能可以改变企业`IT`基础设施和管理大量数据的能力。
`Ceph`提供了超强的可伸缩性--数以千计的客户端访问`pb`到`eb`的数据.

![](images/stack.png)

## Ceph术语

本术语表中的术语旨在解释说明`Ceph`现有的技术术语。

- `cephx`：`Ceph`认证协议，操作类似`Kerberos`，但不存在单点故障情况
- `Ceph`平台：所有`Ceph`软件
- `Ceph`堆栈：`Ceph`的两种或多种组件的集合
- 集群映射：包括`MON`映射、`OSD`映射、`PG`映射、`MDS`映射和`CRUSH`映射
- `Ceph对象存储`：由`Ceph`存储集群和`Ceph`对象网关组成
- `RGW`：`Ceph`的`S3/Swift`网关组件
- `RBD`：`Ceph`块存储组件
- `Ceph块存储`：用于与`librbd`、管理程序（如`QEMU`或`Xen`）和管理程序抽象层（如`libvirt`）结合使用
- `Ceph文件系统`：`Ceph`的`POSIX`文件系统组件
- `OSD`：物理或逻辑存储单元(如LUN)。有时，`Ceph`用户使用术语`OSD`来指代`Ceph OSD`守护进程，尽管正确的术语是`Ceph OSD`
- `Ceph OSD`：`Ceph OSD`守护进程，与逻辑盘(`OSD`)交互。
- `OSD id`：定义`OSD`的整数。它由监视器生成，作为创建新`OSD`的一部分         
- `OSD fsid`：这是一个唯一标识符，用于进一步提高`OSD`的唯一性，它可以在`OSD`路径中的`osd_fsid`文件中找到。这个`fsid`术语可以与`uuid`互换使用
- `OSD uuid`：与`OSD fsid`一样，这是`OSD`唯一标识符，可以与`OSD fsid`互换使用
- `bluestore`：`OSD BlueStore`是`OSD`守护程序（kraken和更新版本）的新后端。与`filestore`不同，它直接将对象存储在`Ceph`块设备上，而不需要任何文件系统接口
- `filestore`：`OSD`守护进程的后端，需要日志记录、将文件写入文件系统
- `MON`：`Ceph`监控软件
- `MGR`：`Ceph`管理器软件，收集集群所有状态   
- `MDS`：`Ceph`元数据服务
- `Ceph Client`：可以访问`Ceph`存储集群的`Ceph`组件的集合。组件包括`Ceph`对象网关、`Ceph`块设备、`Ceph`文件系统以及它们相应的库、内核模块、用户空间文件系统
- `Ceph Kernel Modules`：内核模块的集合，可以用来与`Ceph`系统交互(例如，`Ceph.ko`, `rbd.ko`)。
- `Ceph Client Libraries`：可用于与`Ceph`系统组件交互的库集合
- `Ceph Release`：任何明显编号的`Ceph`版本
- `Ceph Point Release`：任何只包含错误或安全修正的特别发行版
- `Ceph Interim Release`：`Ceph`的版本尚未通过质量保证测试，但可能包含新特性
- `Ceph Release Candidate`：`Ceph`的一个主要版本，已经经历了最初的质量保证测试，并且已经为`beta`测试做好了准备
- `Ceph Stable Release`：`Ceph`的主要版本，其中所有来自前一个临时版本的特性都成功地通过了质量保证测试
- `Teuthology`：在`Ceph`上执行脚本测试的软件集合
- `CRUSH`：可伸缩散列下的受控复制(Controlled Replication Under Scalable Hashing)。这是`Ceph`用来计算对象存储位置的算法
- `CRUSH rule`：适用于特定池的压缩数据放置规则
- `Pools`：池是用于存储对象的逻辑分区
- `systemd oneshot`：一种`systemd`类型，其中一个命令定义在`ExecStart`中，它将在完成时退出(它不打算后台化)
- `LVM tags`：用于`LVM`卷和组的可扩展元数据。它用于存储关于设备及其与`osd`的关系的特定于`ceph`的信息


## Ceph存储集群
    
`Ceph`提供了一个基于`RADOS`(一种可扩展的、可靠的pb级存储集群存储服务)的无限可扩展的`Ceph`存储集群.

`Ceph`存储集群由两种类型的守护进程组成:

- `Ceph Monitor`（mon）
- `Ceph OSD Daemon`（OSD）

![](images/OSDmonitor.png)

其中`Ceph Monitor`维护集群映射的主副本。多节点`Ceph Monitor`确保了`Ceph Monitor`守护进程失败时的高可用性。
`Ceph`客户端从`Ceph Monitor`获取集群信息

`ceph osd`守护进程检查自己的状态和其他`OSD`的状态，并向`Ceph Monitor`上报。

`Ceph`客户端和每个`ceph osd`守护进程使用`CRUSH`算法高效地计算数据位置信息，而不必依赖于中央查找表。
`Ceph`的高级特性包括通过`librados`提供到`Ceph`存储集群的本地接口，以及建立在`librados`之上的许多服务接口。

### `Ceph`数据存储流程

`Ceph`存储集群从`Ceph`客户端接收数据——无论是通过一个`Ceph`块设备、`Ceph`对象存储、`Ceph`文件系统还是使用`librados`创建的自定义实现——它将数据作为对象存储。
每个对象都对应于文件系统中的一个文件，文件系统存储在对象存储设备上。`ceph osd`守护进程处理存储磁盘的读写操作。

![](images/storagedata.png)

`ceph osd`守护进程将所有数据作为对象存储在一个平面命名空间中(没有目录层次结构)。
对象具有标识符、二进制数据和由一组名称/值对组成的元数据。语义完全由`Ceph`客户端决定。
例如，`CephFS`使用元数据存储文件属性，如文件所有者、创建日期、最后修改日期等。其中，对象ID全局唯一。

![](images/dataforfat.png)

### `Ceph`的可伸缩性和高可用性

在传统的架构中，客户端与一个集中的组件(例如，网关、代理、API、facade等)通信，该组件充当一个进入复杂子系统的单一入口点。
这对性能和可伸缩性都施加了限制，同时引入了单点故障(例如，如果集中式组件宕机，整个系统也宕机）

`Ceph`消除了集中式网关，使客户端可以直接与`ceph osd`守护进程交互。`ceph osd`守护进程在其他`Ceph`节点上创建对象副本，以确保数据的安全性和高可用性。
`Ceph`还使用一组`mon`来确保高可用性。为了消除集中化，`Ceph`使用了一种称为`CRUSH`的算法

## `CRUSH`算法介绍

`Ceph`客户端和`ceph osd`守护进程都使用`CRUSH`算法来有效地计算对象的位置信息，而不是依赖于一个中心查找表。
与以前的方法相比，`CRUSH`提供了更好的数据管理机制，可以实现大规模的数据管理。
`CRUSH`使用智能数据复制来确保弹性，这更适合于超大规模存储。

 集群映射

`Ceph`依赖于`Ceph`客户端和`ceph osd`守护进程了解集群拓扑，其中包括5个映射，统称为“集群映射”：

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
执行`ceph osd dump`命令，查看`OSD`映射

    
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
    require_OSD_release nautilus
    max_OSD 0
    
- `PG Map`：包含`PG`版本、它的时间戳、最后一个`OSD Map epoch`、完整比率，以及每个放置组的详细信息，例如`PG ID`、`Up Set`、`Acting Set`、`PG`的状态（例如active+clean），以及每个池的数据使用统计信息
  
- `CRUSH Map`:包含一个存储设备列表，故障域层次结构(例如，设备、主机、机架、行、房间等)，以及存储数据时遍历层次结构的规则。执行`ceph osd getcrushmap -o {filename}`;然后，通过执行`crushtool -d {comp-crushmap-filename} -o {decomp-crushmap-filename}`来反编译它。
使用cat查看反编译后的映射。

- `MDS Map`:包含当前`MDS Map`的`epoch`、`Map`创建的时间和最后一次修改的时间。它还包含存储元数据的池、元数据服务器的列表，以及哪些元数据服务器已经启动和运行.

每个映射维护其操作状态更改的迭代历史。`Ceph`监视器维护集群映射的主副本，包括集群成员、状态、变更和`Ceph`存储集群的总体运行状况


### `mon`高可用

在`Ceph`客户机能够读写数据之前，它们必须访问`Ceph mon`以获取集群映射的最新副本。`Ceph`存储集群可以使用单个`mon`进行操作;然而，这引入了单点故障(即，如果监视器出现故障，Ceph客户机就无法读写数据)。

为了增加可靠性和容错性，`Ceph`支持`mon`集群。在一个监视器集群中，延迟和其他故障可能导致一个或多个监视器落后于集群的当前状态。由于这个原因，`Ceph`必须在关于集群状态的各个监视器实例之间达成一致。`Ceph`总是使用大多数监视器(例如，1、2:3、3:5、4:6等)和`Paxos`算法来在监视器之间建立关于集群当前状态的共识

**即部署多点ceph mon 规避单点故障**

## 身份认证高可用性

为了识别用户并防止中间人攻击，`Ceph`提供了`cephx`身份验证系统来验证用户和守护进程。（`cephx`协议不处理传输中的数据加密(例如，`SSL/TLS`)或静止时的加密。）

`Cephx`使用共享密钥进行身份验证，这意味着客户端和监控集群都拥有客户端密钥的副本。身份验证协议是这样的，双方能够向对方证明他们有一个密钥的副本，而不实际暴露它。这提供了相互的身份验证，这意味着集群确定用户拥有密钥，用户也确定集群拥有密钥的副本

`Ceph`的一个关键的可伸缩性特性是避免对`Ceph`对象存储的集中接口，这意味着`Ceph`客户端必须能够直接与`OSD`交互。为了保护数据，`Ceph`提供了其`cephx`身份验证系统，该系统对操作`Ceph`客户端的用户进行身份验证。`cephx`协议的操作方式与`Kerberos`类似

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
监视器、OSD和元数据服务器可以使用它们的共享秘密来验证该票据

![](images/ticket.png)

这种身份验证提供的保护在`Ceph`客户端和`Ceph`服务器主机之间。身份验证没有扩展到`Ceph`客户端之外。
如果用户从远程主机访问`Ceph`客户端，`Ceph`身份验证不应用于用户的主机和客户端主机之间的连接

## 动态集群管理

每个池（pool）都有许多放置组（PG），`CRUSH`动态地将`PGs`映射到`OSDs`。当`Ceph`客户端存储对象时，`CRUSH`将每个对象映射到放置组

将对象映射到放置组将在`ceph osd`守护进程和`Ceph`客户端之间创建一个间接层。
`Ceph`存储集群必须能够增长(或收缩)，并重新平衡动态存储对象的位置。
如果`Ceph`客户端“知道”哪个`ceph osd`守护进程有哪个对象，那么`Ceph`客户端和`ceph osd`守护进程之间就会产生一个紧密耦合。
相反，`CRUSH`算法将每个对象映射到一个放置组，然后将每个放置组映射到一个或多个`ceph osd`守护进程。
这一间接层允许`Ceph`在新的`ceph osd`守护进程和底层`OSD`设备上线时动态重新平衡。下图描述了`CRUSH`如何将对象映射到放置组，以及将放置组映射到OSD。

![](images/obj-pg-OSD-.png)

有了集群映射的副本和`CRUSH`算法，客户端就可以准确地计算出在读写特定对象时应该使用哪个`OSD`。

> 计算放置组ID

当`Ceph`客户端绑定到`Ceph mon`时，它将检索集群映射的最新副本。通过集群映射，客户获取集群中的所有`mon`、`OSD`和`mds`信息。但是，它对对象位置一无所知。

**计算过程**

。这很简单:`Ceph`将数据存储在命名池中(例如，“liverpool”)。
当客户端想要存储一个命名对象(例如，“john”、“paul”、“george”、“ringo”等)时，它使用对象名、哈希码、池中的`PGs`数量和池名计算放置组。`Ceph`客户端使用以下步骤计算`PG id`。
   
- 1、客户端输入对象`ID`和`pool`

- 2、`Ceph`获取对象`ID`并对其进行哈希运算

- 3、`Ceph`计算`pg`数的哈希模,（例如，58）获取`PG ID`

- 4、`Ceph`获取给定池名的池`ID`（例如，“liverpool”=4）

- 5、`Ceph`将池`ID`前置到`PG ID`(例如，4.58)。

> 重新平衡

当你将`ceph osd`守护进程添加到`Ceph`存储集群时，集群映射会随着新的`OSD`更新。再次计算`PG id`，这将更改集群映射。
下面的图描述了重新平衡的过程(虽然很粗略，因为在大型集群中影响更小)，
其中一些(但不是所有)`pg`从现有`OSD` (OSD 1和OSD 2)迁移到新的OSD (OSD 3)。即使在重新平衡时，崩溃也是稳定的。
许多放置组保持原来的配置，每个`OSD`增加了一些容量，因此在重新平衡完成后，新`OSD`上不会出现负载峰值。

![](images/rebalancing.png)

> 数据一致性

作为维护数据一致性和清洁度的一部分，`ceph osd`还可以清理放置组中的对象。
也就是说，`ceph osd`可以将一个放置组中的对象元数据与其存储在其他`OSD`中的放置组中的副本进行比较。
清理（通常每天执行）捕获`OSD`错误或文件系统错误。
`OSD`还可以通过逐位比较对象中的数据来执行更深入的清理。深度清理（通常每周执行一次）会在磁盘上发现在轻度清理时不明显的坏扇区。

## 分级缓存

缓存层为`Ceph`客户端提供了更好的`I/O`性能，用于存储在备份存储层中的数据子集。
分级缓存包括创建一个作为缓存层的相对快速/昂贵的存储设备(例如，固态驱动器)池，以及一个配置为纠错码或相对较慢/便宜的设备作为经济存储层的后备池。
`Ceph objecter`处理放置对象的位置，而分层代理确定何时将对象从缓存刷新到后备存储层。因此，缓存层和后备存储层对`Ceph`客户端是完全透明的

![](images/cache-tiering.png)

## Ceph协议

`Ceph`客户端使用原生协议与`Ceph`存储集群进行交互，`Ceph`将这个功能打包到`librados`库中。
下图描述了基本架构：

![](images/ceph-protocol.png)

### `Ceph`协议与`librados`

现代应用程序需要一个具有异步通信功能的简单对象存储接口。
`Ceph`存储集群提供了一个具有异步通信能力的简单对象存储接口。
该接口提供了对整个集群中的对象的直接、并行访问。如：

- 池操作
- 快照和写时复制克隆
- 读/写对象-创建或删除-整个对象或字节范围-追加或截断
- 创建/设置/获取/删除`XATTRs`
- 创建/设置/获取/删除键值对
- 复合运算与双ack语义
- 对象类

### 对象观测通知

客户端可以持久性观测一个对象，并保持与主`OSD`的会话处于打开状态。
客户端可以向所有观察者发送通知消息和有效负载，并在观察者收到通知时接收通知。
这使客户端能够将任何对象用作同步/通信通道

![](images/object-watch.png)

## 数据分段
    
存储设备有吞吐量限制，这会影响性能和可伸缩性。因此，存储系统通常支持跨多个存储设备分段存储顺序信息，以提高吞吐量和性能。
`RAID`是最常见的数据分条形式。与`Ceph`的条带化最相似的`RAID`类型是`raid0`，或“条带卷”。`Ceph`的分条提供了`RAID 0`分条的吞吐量，`n-way RAID`镜像的可靠性和更快的恢复。

`Ceph`存储集群中`Ceph`存储的对象没有条带化。`Ceph`对象存储、`Ceph`块设备和`Ceph`文件系统在多个`Ceph`存储集群对象上条带化它们的数据。
通过`librados`直接写入`Ceph`存储集群的`Ceph`客户端必须为自己执行条带化（和并行I/O）以获得这些好处。

最简单的`Ceph`条带格式涉及1个对象的条带计数。`Ceph`客户端将条带单元写入`Ceph`存储群集对象，直到该对象达到最大容量，然后为额外的数据条带创建另一个对象。
最简单的条带化形式对于小块设备图像、`S3`或`Swift`对象和`cepfs`文件就足够了。
然而，这种简单的形式并没有最大限度地利用`Ceph`在放置组之间分发数据的能力，因此并没有极大地提高性能。下图描述了条带化的最简单形式：

![](images/striping.png)

如果预期会有较大的镜像、较大的`S3`或`Swift`对象（例如，视频）或较大的`cepfs`目录，那么通过在对象集中的多个对象上对客户端数据进行条带化，会有相当大的读/写性能改进。
当客户端并行地将条带单元写入相应的对象时，会显著提升写入性能。由于对象被映射到不同的放置组并进一步映射到不同的`OSD`，因此每次写入都以最大的写入速度并行进行。
对单个磁盘的写入将受到磁头移动（例如，每次寻道6ms）和该设备带宽（例如，100MB/s）的限制。
通过将写操作扩展到多个对象（映射到不同的放置组和OSD），`Ceph`可以减少每个驱动器的寻道次数，并结合多个驱动器的吞吐量，以实现更快的写（或读）速度。

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

一旦`Ceph`客户端将数据分条到条带单元并将条带单元映射到对象，`Ceph`的`CRUSH`算法将对象映射到放置组，并将放置组映射到`ceph osd`守护进程，然后将对象作为文件存储在存储磁盘上



# Ceph存储类型

`Ceph`客户端包括许多服务接口:

- 块设备：`Ceph`块设备(又称RBD)服务提供可调整大小、精简配置的块设备，并提供快照和克隆。`Ceph`跨集群划分块设备以获得高性能。`Ceph`既支持内核对象(KO)，也支持直接使用`librbd`的`QEMU`管理程序——避免了虚拟化系统的内核对象开销

- 对象存储：`Ceph`对象存储服务(简称RGW)提供`RESTful api`，兼容`Amazon S3`和`OpenStack Swift`接口
       
- 文件系统：`Ceph`文件系统(cepphfs)服务提供一个兼容`POSIX`的文件系统，可以挂载，也可以作为用户空间中的文件系统(FUSE)使用。

![](images/artitecture.png)

## Ceph块存储

块是字节序列（例如，512字节的数据块）。基于块的存储接口是使用旋转介质（如硬盘、CD、软盘，甚至传统的9磁道磁带）存储数据的最常用方法。
块设备接口的普遍性使得虚拟块设备成为与`Ceph`这样的海量数据存储系统交互的理想候选设备

`Ceph`块设备是精简配置的，可调整大小，并在`Ceph`集群中的多个`OSD`上存储数据条带化。
`Ceph`块设备利用`RADOS`功能，如快照、复制和一致性。
`Ceph`的`RADOS`块设备（RBD）使用内核模块或`librbd`库与`OSD`交互
    
![](images/rbd-artitechture.png)

`Ceph`的`block`设备以无限的可扩展性向内核模块或`kvm`（如QEMU）以及为基于云的计算系统（如OpenStack和CloudStack）提供高性能存储，
这些系统依赖`libvirt`和`QEMU`与`Ceph block`设备集成。您可以使用同一集群同时操作`Ceph-RADOS`网关、`CephFS`文件系统和`Ceph-block`设备。

`Ceph`块设备在`Ceph`存储集群中的多个对象上划分块设备映像，每个对象映射到一个放置组并分布，放置组分布在整个集群中不同的`ceph osd`守护进程上。

精简配置的可快照`Ceph`块设备是虚拟化和云计算的一个有吸引力的选择。
在虚拟机场景中，人们通常在`QEMU/KVM`中部署带有`rbd`网络存储驱动程序的`Ceph`块设备，其中服务端使用`librbd`向客户端提供块设备服务。
许多云计算栈使用`libvirt`与管理程序集成。您可以通过`QEMU`和`libvirt`使用瘦配置的`Ceph`块设备来支持`OpenStack`和`CloudStack`以及其他解决方案。

## Ceph文件系统

`Ceph`文件系统(cepphfs)提供了`posix`兼容的文件系统作为一种服务，它是在基于对象的`Ceph`存储集群之上分层的。
`cepfs`文件映射到`Ceph`存储集群中存储的对象。`Ceph`客户端将`cepfs`文件系统挂载为内核对象或用户空间中的文件系统(FUSE)

![](images/cephfs-artitecture.png)

`Ceph`文件系统服务包括部署在`Ceph`存储集群中的`Ceph`元数据服务器(MDS)。
`MDS`的目的是将所有文件系统元数据(目录、文件所有权、访问模式等)存储在高可用性`Ceph`元数据服务器中，元数据驻留在内存中。
`MDS`(称为Ceph - MDS的守护进程)存在的原因是，简单的文件系统操作，如列出目录或更改目录(ls、cd)，会给`ceph osd`守护进程带来不必要的负担。
因此，将元数据从数据中分离出来意味着`Ceph`文件系统可以提供高性能服务，而不会对`Ceph`存储集群造成负担。


`cepfs`将元数据与数据进行分离，元数据存储在`MDS`中，文件数据存储在`Ceph`存储集群中的一个或多个对象中。
`Ceph`文件系统旨在与`POSIX`兼容。为了实现高可用性或可伸缩性，`ceph-mds`可以作为单个进程运行，也可以将其分发到多个物理机器。

- 高可用：额外的`ceph-mds`实例可以是备用的，随时准备接管任何失效的`active ceph-mds`的职责。这很容易，因为包括日志在内的所有数据都存储在`RADOS`上。该转换由`ceph-mon`自动触发
- 可扩展：多个`ceph mds`实例可以处于活动状态，它们将目录树拆分为子树（以及单个繁忙目录的碎片），从而有效地平衡所有活动服务器之间的负载

### 部署元数据服务器
#### MDS宿主机配置需求
- `MDS`的当前版本是单线程和`cpu`绑定的，用于大多数活动，包括响应客户机请求。
即使如此，一个`MDS`在最活跃的客户端负载下仍然使用大约2到3个`CPU`核。这是由于其他杂项维护线程协同工作造成的。

- 内存：用于`MDS`管理所有客户端和其他活动`MDS`之间的分布式协作元数据缓存，1000个客户端节点的`MDS`将使用至少64`GB`的缓存。

在裸金属集群中，最佳实践是为`MDS`服务器过度供应硬件。即使单个`MDS`守护进程不能充分利用硬件，以后也可以在同一节点上启动更多的活动`MDS`守护进程，以充分利用可用的内核和内存。
此外，通过集群上的工作负载，可以清楚地看到，在同一个节点上使用多个主`MDS`.

从系统高可用性考虑，集群中至少部署两个以上`MDS`守护进程

官方建议将`MDS`与其他`Ceph`守护进程部署在同一宿主机，但需进行配额限制

## Ceph 对象存储

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

# 集成部署
## 硬件需求

`Ceph`被设计成在普通硬件上运行，这使得构建和维护`pb`级数据集群在经济上可行,在规划集群硬件时，需要平衡许多考虑因素，包括故障域和潜在的性能问题。
硬件规划应该包括在多个主机上分布`Ceph`守护进程和其他使用`Ceph`的进程。官方建议在为特定类型的守护进程配置的主机上运行特定类型的`Ceph`守护进程。

即`ceph`集群与客户端应为不同宿主机，具体硬件需求参考如下：

### CPU

`Ceph`元数据服务器动态地重新分配它们的负载，这是`CPU`密集型的。因此，元数据服务器应该具有强大的处理能力(例如，四核或更好的cpu)。`ceph osds`运行`RADOS`服务，使用`CRUSH`计算数据位置，复制数据，并维护它们自己的集群映射副本。
因此，`OSD`应该具有合理的处理能力(例如，双核处理器)。监视器只是维护集群映射的主副本，因此它们不是`CPU`密集型的。
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

    监视器和管理器守护进程的内存使用情况通常随集群的大小而变化。对于小型集群，一般1-2`GB`就足够了。对于大型集群，您应该提供更多(5-10`GB`)。您可能还需要考虑调整`mon_OSD_cache_size`或`rocksdb_cache_size`等设置
 
- `CEPH-MDS`元数据节点

    元数据守护进程的内存利用率取决于它的缓存被配置为消耗多少内存。对于大多数系统，官方建议至少使用1`GB`。具体大小可调整`mds_cache_memory`
    
- `OSDS`(`CEPH-OSD`)存储节点

    默认情况下，使用`BlueStore`后端的`OSD`需要3-5`GB` `RAM`。当使用`BlueStore`时，
    可以通过配置选项`OSD_memory_target`来调整`OSD`的内存消耗。当使用遗留的`FileStore`后端时，
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
  
    `OSD`应该有足够的硬盘驱动器空间来存放对象数据。官方建议硬盘驱动器的最小大小为1`TB`。
    考虑较大磁盘的每`GB`成本优势。官方建议将硬盘驱动器的价格除以千兆字节数，得出每千兆字节的成本，因为较大的驱动器可能对每千兆字节的成本有很大的影响。
    例如，价格为$75.00的1`TB`硬盘的成本为每`GB`$0.07(即$75 / 1024 = 0.0732)。
    相比之下，价格为150美元的3`TB`硬盘的成本为每`GB` 0.05美元(即150美元/ 3072 = 0.0488)。
    在前面的示例中，使用1`TB`的磁盘通常会使每`GB`的成本增加40%——从而大大降低集群的成本效率。
    此外，存储驱动器容量越大，每个`ceph osd`守护进程需要的内存就越多，尤其是在重新平衡、回填和恢复期间。
    一般的经验法则是1`TB`的存储空间需要`1GB`的`RAM`
    
    存储驱动器受到寻道时间、访问时间、读和写时间以及总吞吐量的限制。
    这些物理限制会影响整个系统的性能——尤其是在恢复过程中。
    官方建议为操作系统和软件使用专用的驱动器，为主机上运行的每个`ceph osd`守护进程使用一个驱动器(物理硬盘)。
    大多数`慢OSD`问题是由于在同一个驱动器上运行一个操作系统、多个`OSD`和/或多个日志引起的。
    由于在小型集群上故障排除性能问题的成本可能会超过额外磁盘驱动器的成本，因此可以通过避免过度使用`OSD`存储驱动器来加速集群设计规划
    
    您可以在每个硬盘驱动器上运行多个`ceph osd`进程，但这可能会导致资源争用，并降低总体吞吐量。
    您可以将日志和对象数据存储在同一个驱动器上，但这可能会增加向客户端记录写操作和`ACK`所需的时间。
    `Ceph`必须先向日志写入数据，然后才能对写入数据进行验证
    
**总结为：`Ceph`最佳实践规定，您应该在不同的驱动器上运行操作系统、`OSD`数据和`OSD`日志**

- 固态硬盘
  
    提高性能的一个机会是使用固态驱动器(SSD)来减少随机访问时间和读取延迟，同时加速吞吐量。
    与硬盘驱动器相比，`SSD`每`GB`的成本通常超过10倍，但`SSD`的访问时间通常至少比硬盘驱动器快100倍
    
    `SSD`没有可移动的机械部件，因此它们不必受到与硬盘驱动器相同类型的限制。不过`SSD`确实有很大的局限性。
    在评估`SSD`时，考虑顺序读写的性能是很重要的。
    当存储多个`OSD`的多个日志时，顺序写吞吐量为400MB/s的`SSD`可能比顺序写吞吐量为120MB/s的`SSD`性能更好
    
    由于`SSD`没有可移动的机械部件，所以在`Ceph`中不需要大量存储空间的区域使用`SSD`是有意义的。
    相对便宜的固态硬盘可能会吸引你的经济意识。谨慎使用。
    当选择与`Ceph`一起使用的`SSD`时，可接受的`IOPS`是不够的。对于日志和`SSD`有几个重要的性能考虑因素:
    - 写密集型语义:日志记录涉及写密集型语义，因此您应该确保选择部署的`SSD`在写入数据时的性能等于或优于硬盘驱动器。
    廉价的`SSD`可能会在加速访问时间的同时引入写延迟，因为有时高性能硬盘驱动器的写速度可以与市场上一些更经济的`SSD`一样快甚至更快!
    - 顺序写:当您在一个`SSD`上存储多个日志时，您还必须考虑`SSD`的顺序写限制，因为它们可能会同时处理多个`OSD`日志的写请求。
    - 分区对齐:`SSD`性能的一个常见问题是，人们喜欢将驱动器分区作为最佳实践，但他们常常忽略了使用`SSD`进行正确的分区对齐，这可能导致`SSD`传输数据的速度慢得多。确保`SSD`分区对齐

    虽然`SSD`存储对象的成本非常高，但是通过将`OSD`的日志存储在`SSD`上，将`OSD`的对象数据存储在单独的硬盘驱动器上，可以显著提高`OSD`的性能。
    `OSD`日志配置默认为`/var/lib/ceph/OSD/$cluster-$id/journal`。您可以将此路径挂载到`SSD`或`SSD`分区上，使其与对象数据不只是同一个磁盘上的文件

    `Ceph`加速`CephFS`文件系统性能的一种方法是将`CephFS`元数据的存储与`CephFS`文件内容的存储隔离。
    `Ceph`为`cepfs`元数据提供了一个默认的元数据池。您永远不必为`CephFS`元数据创建一个池，但是您可以为仅指向主机的`SSD`存储介质的`CephFS`元数据池创建一个`CRUSH map`层次结构。

**重要提示: 官方建议探索`SSD`的使用以提高性能。但是，在对`SSD`进行重大投资之前，官方强烈建议检查`SSD`的性能指标，并在测试配置中测试`SSD`，以评估性能**

- 控制器

    磁盘控制器对写吞吐量也有很大的影响。仔细考虑磁盘控制器的选择，以确保它们不会造成性能瓶颈。
    
- 注意事项

    你可以在每个主机上运行多个`OSD`，但是你应该确保`OSD`硬盘的总吞吐量不超过客户端读写数据所需的网络带宽。
    您还应该考虑集群在每个主机上存储的总体数据的百分比。如果某个主机上的百分比很大，并且该主机发生故障，那么它可能会导致一些问题，比如超过了完整的比例，这将导致`Ceph`停止操作，作为防止数据丢失的安全预防措施。

    当您在每个主机上运行多个`OSD`时，还需要确保内核是最新的。请参阅`OS`推荐，了解`glibc`和`syncfs(2)`方面的注意事项，以确保在每个主机上运行多个`OSD`时，您的硬件能够像预期的那样执行    

    拥有大量`OSD`的主机(例如> 20)可能会产生大量线程，特别是在恢复和平衡过程中。许多`Linux`内核默认的最大线程数相对较小(例如，32k)。如果在拥有大量`OSD`的主机上启动`OSD`时遇到问题，请考虑设置`kernel`。将`pid_max`设置为更高的线程数。理论最大值是4,194,303线程。
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
     1     10487808   1875384974  889.3G  ceph osd        ceph data
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
| ceph-OSD       | Processor | 1x 64-bit AMD-64 1x 32-bit ARM dual-core or better |
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

- `Ceph`客户端内核
    - 4.14.x
    - 4.9.x
    
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


## 环境说明

- 节点信息

| 节点名称 | 节点IP | 节点属性 |
| :----:| :----: | :----: |
| ceph01 | 192.168.1.69 | admin,deploy,mon |
| ceph02 | 192.168.1.70 | 单元格 |
| ceph03 | 192.168.1.70 | 单元格 |

## 环境初始化

### 配置yum

**所有ceph节点，包含客户端节点**

> 1、删除原有yum源repo文件

	rm -f /etc/yum.repos.d/*.repo
	
> 2、创建yum源文件

**online**

	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
	
**offline**
    
下载以下文件上传至`/etc/yum.repos.d/`

- [Centos-7.repo](http://mirrors.aliyun.com/repo/Centos-7.repo)
- [epel-7.repo](http://mirrors.aliyun.com/repo/epel-7.repo)

> 3、配置`ceph`镜像源仓库

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

> 4、配置`yum`代理

**适用于主机通过代理访问互联网场景**

以下变量注意替换

- username: 代理用户名
- password: 代理用户密码
- proxy_host: 代理IP地址
- proxy_port: 代理端口


    echo "proxy=http://username:password@proxy_host:proxy_port" >> /etc/yum.conf

### yum依赖导出

**适用无法直连或通过代理连接互联网镜像源**

- 联网主机：用于导出`ceph`依赖,操作系统为`CentOS7`
- 离线主机：实际部署`ceph`应用的主机(多节点实例)

依赖导出（联网主机）

	rm -f /etc/yum.repos.d/*.repo
	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
	
    yum update -y
    yum install yum-plugin-downloadonly -y
    yum install --downloadonly --downloaddir=./ceph ceph ceph-common ceph-deploy
    
生成repo依赖关系（联网主机）

    yum install -y createrepo
    createrepo ./ceph

压缩（联网主机）

    tar zcvf ceph.tar.gz ceph
    
配置使用（离线主机）

    tar zxvf ceph.tar.gz -C /
    
    cat > /etc/yum.repos.d/ceph.repo <<EOF
    [ceph]
    name=python-repo
    baseurl=file:///ceph
    gpgcheck=0
    enabled=1
    EOF
    
    yum install -y ceph ceph-deploy ceph-common

### 配置时钟同步

> 配置dns

该`dns`用以解析时钟服务地址，互联网下应为`114.114.114.114`

    echo "nameserver x.x.x.x" >> /etc/resolv.conf

> 安装ntp

    yum install -y ntp

> 同步

时钟服务地址据实际情况调整

    ntpdate time.wl.com
    echo "*/5 * * * * root ntpdate time.wl.com" >> /etc/crontab

> 调整时区

    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

### 升级内核

导入`kernel`源

[elrepo-release-7.0-4.el7.elrepo.noarch.rpm](https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm)

    rpm -ivh elrepo-release-7.0-4.el7.elrepo.noarch.rpm -y
    
安装最新主线版

    yum -y --enablerepo=elrepo-kernel install kernel-ml.x86_64 kernel-ml-devel.x86_64
    
删除旧版本工具包

     rpm -qa|grep kernel-3|xargs -n1 yum remove -y
     
安装新版本工具包

    yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml-tools.x86_64
   
查看内核列表

    awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
    
重建内核

    grub2-mkconfig -o /boot/grub2/grub.cfg

配置新版内核

    grub2-set-default 0

重启

    reboot
    
### raid卡

适用于已安装`raid`卡主机

- 系统盘：建议raid1
- 数据盘：配置为直通模式（JBOD）
    

## 安装ceph

`ceph`版本为`14.2.16 nautilus`

> 创建ceph目录(deploy节点)

    mkdir -p /etc/ceph
    
> 配置主机互信(deploy节点)

    ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa
    ssh-copy-id ceph01
    ssh-copy-id ceph02
    ssh-copy-id ceph03
    
> 安装`ceph`(所有节点)

    yum install -y ceph ceph-deploy
    
> 初始化mon节点(deploy节点)

    ceph-deploy new ceph01 ceph02 ceph03
    
> 初始化`mon`(deploy节点)

     ceph-deploy mon create-initial
     
> 修改集群文件(deploy节点)

    cd /etc/ceph/
    echo "public_network=192.168.1.0/24" >> /etc/ceph/ceph.conf
    ceph-deploy --overwrite-conf config push ceph01 ceph02 ceph03
    
> 配置admin节点

    cd /etc/ceph/
    ceph-deploy admin ceph01 ceph02 ceph03

> 查看集群状态

    [root@ceph01 ~]# ceph -s
      cluster:
        id:     b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
        health: HEALTH_WARN
                mon ceph03 is low on available space
    
      services:
        mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 31m)
        mgr: no daemons active
        OSD: 0 OSDs: 0 up, 0 in
    
      data:
        pools:   0 pools, 0 pgs
        objects: 0 objects, 0 B
        usage:   0 B used, 0 B / 0 B avail
        pgs:
    
> 安装命令补全

    yum -y install bash-completion

## 配置ceph

### 添加OSD

> ceph01节点添加OSD

列出节点`ceph01`磁盘信息

    ceph-deploy disk list ceph01
    
输出如下

    ...
    [ceph01][INFO  ] Disk /dev/sda: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph01][INFO  ] Disk /dev/sdb: 480.1 GB, 480103981056 bytes, 937703088 sectors
    [ceph01][INFO  ] Disk /dev/sdf: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph01][INFO  ] Disk /dev/sdd: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph01][INFO  ] Disk /dev/sde: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph01][INFO  ] Disk /dev/sdc: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph01][INFO  ] Disk /dev/sdg: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph01][INFO  ] Disk /dev/sdh: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph01][INFO  ] Disk /dev/mapper/centos-root: 478.0 GB, 477953523712 bytes, 933502976 sectors
    [ceph01][INFO  ] Disk /dev/nvme0n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph01][INFO  ] Disk /dev/nvme1n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph01][INFO  ] Disk /dev/nvme2n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph01][INFO  ] Disk /dev/nvme3n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    ...
 
其中`/dev/sda-h`为`SSD`类型磁盘，`/dev/nvme*`为`nvme`类型磁盘，且`/dev/sdb`为系统盘
 
> 查看磁盘挂载

    lsblk
    
输出如下

    NAME              MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sdf                 8:80   0 894.3G  0 disk
    nvme0n1           259:1    0   1.8T  0 disk
    sdd                 8:48   0 894.3G  0 disk
    nvme3n1           259:3    0   1.8T  0 disk
    sdb                 8:16   0 894.3G  0 disk
    ├─sdb2            8:34   0     1G  0 part /boot
    ├─sdb3            8:35   0 445.1G  0 part
    │ ├─centos-swap 253:1    0    16G  0 lvm
    │ └─centos-root 253:0    0 429.1G  0 lvm  /
    └─sdb1            8:33   0     1G  0 part /boot/efi
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

    sda-sdh 为SSD类型
    nvme0n1、nvme1n1、nvme2n1、nvme3n1为nvme类型
    系统盘：nvme0n1
    
> 格式化磁盘

    mkfs.ext4 /dev/sda
    mkfs.ext4 /dev/sdc
    mkfs.ext4 /dev/sdd
    mkfs.ext4 /dev/sde
    mkfs.ext4 /dev/sdf
    mkfs.ext4 /dev/sdg
    mkfs.ext4 /dev/sdh
    mkfs.ext4 /dev/nvme0n1
    mkfs.ext4 /dev/nvme1n1
    mkfs.ext4 /dev/nvme2n1
    mkfs.ext4 /dev/nvme3n1
    
> 擦净节点`SSD`类型磁盘

    ceph-deploy disk zap ceph01 /dev/sda
    
    cd /etc/ceph/
    for i in {c..h};do
    ceph-deploy disk zap ceph01 /dev/sd$i
    done

> 创建`SSD`类型`OSD`节点
 
    cd /etc/ceph
    for i in {c..h};do
    ceph-deploy osd create --data /dev/sd$i ceph01
    done
    
    ceph-deploy osd create --data /dev/sda ceph01
    
> 擦净节点`nvme`类型磁盘

    cd /etc/ceph
    for i in {0..3};do
    ceph-deploy disk zap ceph01 /dev/nvme${i}n1
    done
    
> 创建`nvme`类型`OSD`节点
 
    cd /etc/ceph
    for i in {0..3};do
    ceph-deploy OSD create --data /dev/nvme${i}n1 ceph01
    done
    
> ceph02节点添加OSD

列出节点`ceph02`磁盘信息(ceph01节点执行)

    ceph-deploy disk list ceph02
    
输出如下

    ...
    [root@ceph01 ceph]# ceph-deploy disk list ceph02
    [ceph_deploy.conf][DEBUG ] found configuration file at: /root/.cephdeploy.conf
    [ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list ceph02
    [ceph_deploy.cli][INFO  ] ceph-deploy options:
    [ceph_deploy.cli][INFO  ]  username                      : None
    [ceph_deploy.cli][INFO  ]  verbose                       : False
    [ceph_deploy.cli][INFO  ]  debug                         : False
    [ceph_deploy.cli][INFO  ]  overwrite_conf                : False
    [ceph_deploy.cli][INFO  ]  subcommand                    : list
    [ceph_deploy.cli][INFO  ]  quiet                         : False
    [ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f8c21ecd518>
    [ceph_deploy.cli][INFO  ]  cluster                       : ceph
    [ceph_deploy.cli][INFO  ]  host                          : ['ceph02']
    [ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7f8c22118938>
    [ceph_deploy.cli][INFO  ]  ceph_conf                     : None
    [ceph_deploy.cli][INFO  ]  default_release               : False
    [ceph02][DEBUG ] connected to host: ceph02
    [ceph02][DEBUG ] detect platform information from remote host
    [ceph02][DEBUG ] detect machine type
    [ceph02][DEBUG ] find the location of an executable
    [ceph02][INFO  ] Running command: fdisk -l
    [ceph02][INFO  ] Disk /dev/sdb: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph02][INFO  ] Disk /dev/sdd: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph02][INFO  ] Disk /dev/sda: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph02][INFO  ] Disk /dev/sdf: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph02][INFO  ] Disk /dev/sdc: 480.1 GB, 480103981056 bytes, 937703088 sectors
    [ceph02][INFO  ] Disk /dev/sde: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph02][INFO  ] Disk /dev/mapper/centos-root: 460.8 GB, 460773654528 bytes, 899948544 sectors
    [ceph02][INFO  ] Disk /dev/mapper/centos-swap: 17.2 GB, 17179869184 bytes, 33554432 sectors
    [ceph02][INFO  ] Disk /dev/nvme0n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph02][INFO  ] Disk /dev/nvme3n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph02][INFO  ] Disk /dev/nvme1n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph02][INFO  ] Disk /dev/nvme2n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    ...
 
其中`/dev/sda-f`为`SSD`类型磁盘，`/dev/nvme*`为`nvme`类型磁盘，且`/dev/sdc`为系统盘
 
> 查看磁盘挂载（ceph02节点执行）

    lsblk
    
输出如下

    [root@ceph02 ~]# lsblk
    NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sdf               8:80   0 894.3G  0 disk
    nvme0n1         259:0    0 931.5G  0 disk
    sdd               8:48   0 894.3G  0 disk
    nvme3n1         259:1    0 931.5G  0 disk
    sdb               8:16   0 894.3G  0 disk
    nvme2n1         259:3    0 931.5G  0 disk
    sde               8:64   0 894.3G  0 disk
    sdc               8:32   0 447.1G  0 disk
    ├─sdc2            8:34   0     1G  0 part /boot
    ├─sdc3            8:35   0 445.1G  0 part
    │ ├─centos-swap 253:1    0    16G  0 lvm
    │ └─centos-root 253:0    0 429.1G  0 lvm  /
    └─sdc1            8:33   0     1G  0 part /boot/efi
    nvme1n1         259:2    0 931.5G  0 disk
    sda               8:0    0 894.3G  0 disk
    
磁盘类型说明

    sda-sdf 为SSD类型
    nvme0n1、nvme1n1、nvme2n1、nvme3n1为nvme类型
    系统盘：sdc
    
> 格式化磁盘（ceph02节点执行）

    mkfs.ext4 /dev/sda
    mkfs.ext4 /dev/sdb
    mkfs.ext4 /dev/sdd
    mkfs.ext4 /dev/sde
    mkfs.ext4 /dev/sdf
    mkfs.ext4 /dev/nvme0n1
    mkfs.ext4 /dev/nvme1n1
    mkfs.ext4 /dev/nvme2n1
    mkfs.ext4 /dev/nvme3n1

> 擦净节点`SSD`类型磁盘（ceph01节点执行）

    cd /etc/ceph/
    for i in {a..b};do
    ceph-deploy disk zap ceph02 /dev/sd$i
    done
    
    cd /etc/ceph/
    for i in {d..f};do
    ceph-deploy disk zap ceph02 /dev/sd$i
    done

> 创建`SSD`类型`OSD`节点（ceph01节点执行）
 
    cd /etc/ceph
    for i in {a..b};do
    ceph-deploy OSD create --data /dev/sd$i ceph02
    done
    
    cd /etc/ceph
    for i in {d..f};do
    ceph-deploy OSD create --data /dev/sd$i ceph02
    done
    
> 擦净节点`nvme`类型磁盘（ceph01节点执行）

    cd /etc/ceph
    for i in {0..3};do
    ceph-deploy disk zap ceph02 /dev/nvme${i}n1
    done
    
> 创建`nvme`类型`OSD`节点（ceph01节点执行）
 
    cd /etc/ceph
    for i in {0..3};do
    ceph-deploy OSD create --data /dev/nvme${i}n1 ceph02
    done
    
> ceph03节点添加OSD

列出节点`ceph03`磁盘信息（ceph01节点执行）

    ceph-deploy disk list ceph03
    
输出如下

    ...
    [ceph03][INFO  ] Disk /dev/nvme0n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph03][INFO  ] Disk /dev/nvme2n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph03][INFO  ] Disk /dev/nvme3n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph03][INFO  ] Disk /dev/nvme1n1: 1000.2 GB, 1000204886016 bytes, 1953525168 sectors
    [ceph03][INFO  ] Disk /dev/sdc: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph03][INFO  ] Disk /dev/sda: 480.1 GB, 480103981056 bytes, 937703088 sectors
    [ceph03][INFO  ] Disk /dev/sdb: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph03][INFO  ] Disk /dev/sde: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph03][INFO  ] Disk /dev/sdd: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph03][INFO  ] Disk /dev/sdf: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [ceph03][INFO  ] Disk /dev/mapper/centos-root: 475.7 GB, 475667628032 bytes, 929038336 sectors
    ...
 
其中`/dev/sda-f`为`SSD`类型磁盘，`/dev/nvme*`为`nvme`类型磁盘，且`/dev/sda`为系统盘
 
> 查看磁盘挂载（ceph03节点执行）

    lsblk
    
输出如下

    [root@ceph03 ~]# lsblk
    NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sda               8:0    0 447.1G  0 disk
    ├─sda1            8:1    0     2G  0 part /boot/efi
    ├─sda2            8:2    0     2G  0 part /boot
    └─sda3            8:3    0   443G  0 part
      └─centos-root 253:0    0   443G  0 lvm  /
    sdb               8:16   0 894.3G  0 disk
    sdc               8:32   0 894.3G  0 disk
    sdd               8:48   0 894.3G  0 disk
    sde               8:64   0 894.3G  0 disk
    sdf               8:80   0 894.3G  0 disk
    nvme0n1         259:0    0 931.5G  0 disk
    nvme1n1         259:3    0 931.5G  0 disk
    nvme2n1         259:2    0 931.5G  0 disk
    nvme3n1         259:1    0 931.5G  0 disk
    
磁盘类型说明

    sda-sdf 为SSD类型
    nvme0n1、nvme1n1、nvme2n1、nvme3n1为nvme类型
    系统盘：nvme0n1

> 擦净节点`SSD`类型磁盘

    cd /etc/ceph/
    for i in {b..f};do
    ceph-deploy disk zap ceph03 /dev/sd$i
    done

> 创建`SSD`类型`OSD`节点
 
    cd /etc/ceph
    for i in {b..f};do
    ceph-deploy OSD create --data /dev/sd$i ceph03
    done
    
> 擦净节点`nvme`类型磁盘

    cd /etc/ceph
    for i in {0..3};do
    ceph-deploy disk zap ceph03 /dev/nvme${i}n1
    done
    
> 创建`nvme`类型`OSD`节点
 
    cd /etc/ceph
    for i in {0..3};do
    ceph-deploy OSD create --data /dev/nvme${i}n1 ceph03
    done

#### 常见问题解决

- Unable to add physical volume '/dev/nvme1n1' to volume group 'ceph-e9ba73a1-f31a-4ce7-b0b9-ab16c35a2c49'

        
        pvcreate -ff -y /dev/nvme1n1
    

### crush class

- 说明

从`luminous`版本`ceph`新增了一个功能`crush class`，这个功能又可以称为磁盘智能分组。因为这个功能就是根据磁盘类型自动的进行属性的关联，然后进行分类。无需手动修改`crushmap`，极大的减少了人为的操作。

`ceph`中的每个`OSD`设备都可以选择一个`class`类型与之关联，默认情况下，在创建`OSD`的时候会自动识别设备类型，然后设置该设备为相应的类。通常有三种`class`类型：`hdd`，`ssd`，`nvme`。
    

查看集群OSD crush tree(ceph01节点执行)

    [root@ceph01 ~]# ceph osd crush tree --show-shadow
    ID CLASS WEIGHT   TYPE NAME
    -2   ssd 25.76233 root default~ssd
    -4   ssd  9.75183     host ceph01~ssd
     0   ssd  0.87329         OSD.0
     1   ssd  0.87329         OSD.1
     2   ssd  0.87329         OSD.2
     3   ssd  0.87329         OSD.3
     4   ssd  0.87329         OSD.4
     5   ssd  0.87329         OSD.5
     6   ssd  0.87329         OSD.6
     7   ssd  0.90970         OSD.7
     8   ssd  0.90970         OSD.8
     9   ssd  0.90970         OSD.9
    10   ssd  0.90970         OSD.10
    -6   ssd  8.00525     host ceph02~ssd
    11   ssd  0.87329         OSD.11
    12   ssd  0.87329         OSD.12
    13   ssd  0.87329         OSD.13
    14   ssd  0.87329         OSD.14
    15   ssd  0.87329         OSD.15
    16   ssd  0.90970         OSD.16
    17   ssd  0.90970         OSD.17
    18   ssd  0.90970         OSD.18
    19   ssd  0.90970         OSD.19
    -8   ssd  8.00525     host ceph03~ssd
    20   ssd  0.87329         OSD.20
    21   ssd  0.87329         OSD.21
    22   ssd  0.87329         OSD.22
    23   ssd  0.87329         OSD.23
    24   ssd  0.87329         OSD.24
    25   ssd  0.90970         OSD.25
    26   ssd  0.90970         OSD.26
    27   ssd  0.90970         OSD.27
    28   ssd  0.90970         OSD.28

- 配置

修改nvme类型class

    ceph osd crush rm-device-class 7
    ceph osd crush set-device-class nvme OSD.7
    ceph osd crush rm-device-class 8
    ceph osd crush set-device-class nvme OSD.8
    ceph osd crush rm-device-class 9
    ceph osd crush set-device-class nvme OSD.9
    ceph osd crush rm-device-class 10
    ceph osd crush set-device-class nvme OSD.10
    
    ceph osd crush rm-device-class 16
    ceph osd crush set-device-class nvme OSD.16
    ceph osd crush rm-device-class 17
    ceph osd crush set-device-class nvme OSD.17
    ceph osd crush rm-device-class 18
    ceph osd crush set-device-class nvme OSD.18
    ceph osd crush rm-device-class 19
    ceph osd crush set-device-class nvme OSD.19
    
    ceph osd crush rm-device-class 25
    ceph osd crush set-device-class nvme OSD.25
    ceph osd crush rm-device-class 26
    ceph osd crush set-device-class nvme OSD.26
    ceph osd crush rm-device-class 27
    ceph osd crush set-device-class nvme OSD.27
    ceph osd crush rm-device-class 28
    ceph osd crush set-device-class nvme OSD.28
    
    
> 查看集群OSD crush tree

    [root@ceph01 ~]# ceph osd crush tree --show-shadow
    ID  CLASS WEIGHT   TYPE NAME
    -12  nvme 10.91638 root default~nvme
     -9  nvme  3.63879     host ceph01~nvme
      7  nvme  0.90970         OSD.7
      8  nvme  0.90970         OSD.8
      9  nvme  0.90970         OSD.9
     10  nvme  0.90970         OSD.10
    -10  nvme  3.63879     host ceph02~nvme
     16  nvme  0.90970         OSD.16
     17  nvme  0.90970         OSD.17
     18  nvme  0.90970         OSD.18
     19  nvme  0.90970         OSD.19
    -11  nvme  3.63879     host ceph03~nvme
     25  nvme  0.90970         OSD.25
     26  nvme  0.90970         OSD.26
     27  nvme  0.90970         OSD.27
     28  nvme  0.90970         OSD.28
     -2   ssd 14.84595 root default~ssd
     -4   ssd  6.11304     host ceph01~ssd
      0   ssd  0.87329         OSD.0
      1   ssd  0.87329         OSD.1
      2   ssd  0.87329         OSD.2
      3   ssd  0.87329         OSD.3
      4   ssd  0.87329         OSD.4
      5   ssd  0.87329         OSD.5
      6   ssd  0.87329         OSD.6
     -6   ssd  4.36646     host ceph02~ssd
     11   ssd  0.87329         OSD.11
     12   ssd  0.87329         OSD.12
     13   ssd  0.87329         OSD.13
     14   ssd  0.87329         OSD.14
     15   ssd  0.87329         OSD.15
     -8   ssd  4.36646     host ceph03~ssd
     20   ssd  0.87329         OSD.20
     21   ssd  0.87329         OSD.21
     22   ssd  0.87329         OSD.22
     23   ssd  0.87329         OSD.23
     24   ssd  0.87329         OSD.24
     
### crush pool
#### ssd crush rule
> 创建crush rule

    #ceph osd crush rule create-replicated <rule-name> <root> <failure-domain> <class>

创建`class` 为`SSD`的rule

    ceph osd crush rule create-replicated SSD_rule default host ssd
    
> 创建资源池

    #ceph osd pool create {pool_name} {pg_num} [{pgp_num}]
    ceph osd pool create ssd-pool 256 256
    
> 查看`ssd-pool`crush rule

    [root@ceph01 ~]# ceph osd pool get ssd-pool crush_rule
    crush_rule: replicated_rule

> 设置`ssd-pool`crush rule为`SSD_rule`

    #ceph osd pool set <pool-name> crush_rule <rule-name>
    ceph osd pool set ssd-pool crush_rule SSD_rule

> 查看`ssd-pool`crush rule

    [root@ceph01 ~]# ceph osd pool get ssd-pool crush_rule
    crush_rule: SSD_rule
    
> 设置`ssd-pool`配额

    #osd pool set-quota <poolname> max_objects|max_bytes <val>

设置最大对象数10

    ceph osd pool set-quota ssd-pool max_objects 10
    
设置存储大小为1G

    ceph osd pool set-quota ssd-pool max_bytes 1G
    
> 扩容`ssd-pool`配额

    #osd pool set-quota <poolname> max_objects|max_bytes <val>
    
设置最大对象数20

    ceph osd pool set-quota ssd-pool max_objects 20
    
设置存储大小为2G

    ceph osd pool set-quota ssd-pool max_bytes 2G
    
> 修改`ssd-pool`为`ssd-demo-pool`

     ceph osd pool rename ssd-pool ssd-demo-pool
     
#### nvme crush rule

> 创建crush rule

    #ceph osd crush rule create-replicated <rule-name> <root> <failure-domain> <class>
    
创建`class` 为`nvme`的rule

    ceph osd crush rule create-replicated nvme_rule default host nvme
    
> 创建资源池

    #ceph osd pool create {pool_name} {pg_num} [{pgp_num}]
    ceph osd pool create nvme-pool 256 256
    
> 查看`nvme-pool`crush rule

    [root@ceph01 ~]# ceph osd pool get nvme-pool crush_rule
    crush_rule: replicated_rule

> 设置`nvme-pool`crush rule为`nvme_rule`

    #ceph osd pool set <pool-name> crush_rule <rule-name>
    ceph osd pool set nvme-pool crush_rule nvme_rule

> 查看`nvme-pool`crush rule

    [root@ceph01 ~]# ceph osd pool get nvme-pool crush_rule
    crush_rule: nvme_rule
    
> 设置`nvme-pool`配额

    #osd pool set-quota <poolname> max_objects|max_bytes <val>

设置最大对象数10

    ceph osd pool set-quota nvme-pool max_objects 10
    
设置存储大小为1G

    ceph osd pool set-quota nvme-pool max_bytes 1G
    
> 扩容`ssd-pool`配额

    #osd pool set-quota <poolname> max_objects|max_bytes <val>
    
设置最大对象数20

    ceph osd pool set-quota nvme-pool max_objects 20
    
设置存储大小为2G

    ceph osd pool set-quota nvme-pool max_bytes 2G
    
> 修改`nvme-pool`为`nvme-demo-pool`

     ceph osd pool rename nvme-pool nvme-demo-pool
     
#### 测试crush rule

> 查看`crush class`

    [root@ceph01 ~]# ceph osd crush class ls
    [
        "ssd",
        "nvme"
    ]

> 查看`crush rule`

    [root@ceph01 ~]# ceph osd crush rule ls
    replicated_rule
    SSD_rule
    nvme_rule
    
> 查看池`cursh rule`

    [root@ceph01 ~]# ceph osd pool ls detail
    pool 1 'ssd-demo-pool' replicated size 3 min_size 2 crush_rule 1 object_hash rjenkins pg_num 256 pgp_num 256 autoscale_mode warn last_change 256 flags hashpspool max_bytes 2147483648 max_objects 20 stripe_width 0
    pool 2 'nvme-demo-pool' replicated size 3 min_size 2 crush_rule 2 object_hash rjenkins pg_num 256 pgp_num 256 autoscale_mode warn last_change 266 flags hashpspool max_bytes 2147483648 max_objects 20 stripe_width 0
    
> 创建一个对象`object-ssd`并放到`ssd-demo-pool`中

    [root@ceph01 ~]# rados -p ssd-demo-pool ls
    [root@ceph01 ~]# echo "000000" > object-ssd.txt
    [root@ceph01 ~]# rados -p ssd-demo-pool put object-ssd object-ssd.txt 
    [root@ceph01 ~]# rados -p ssd-demo-pool ls
    object-ssd
    
> 创建一个对象`object-nvme`并放到`nvme-demo-pool`中

    [root@ceph01 ~]# rados -p nvme-demo-pool ls
    [root@ceph01 ~]# echo "111111" > object-nvme.txt
    [root@ceph01 ~]# rados -p nvme-demo-pool put object-nvme object-nvme.txt 
    [root@ceph01 ~]# rados -p nvme-demo-pool ls
    object-nvme

> 查看`object-ssd`对象存储情况

    [root@ceph01 ~]# ceph osd map ssd-demo-pool object-ssd
    OSDmap e267 pool 'ssd-demo-pool' (1) object 'object-ssd' -> pg 1.cffcc003 (1.3) -> up ([13,1,21], p13) acting ([13,1,21], p13)
    
> 查看`object-nvme`对象存储情况

    [root@ceph01 ~]# ceph osd map nvme-demo-pool object-nvme
    OSDmap e267 pool 'nvme-demo-pool' (2) object 'object-nvme' -> pg 2.2d6e9780 (2.80) -> up ([28,19,8], p28) acting ([28,19,8], p28)
    
> 确认存储`OSD`

    [root@ceph01 ~]# ceph osd tree
    ID CLASS WEIGHT   TYPE NAME       STATUS REWEIGHT PRI-AFF
    -1       25.76233 root default
    -3        9.75183     host ceph01
     7  nvme  0.90970         OSD.7       up  1.00000 1.00000
     8  nvme  0.90970         OSD.8       up  1.00000 1.00000
     9  nvme  0.90970         OSD.9       up  1.00000 1.00000
    10  nvme  0.90970         OSD.10      up  1.00000 1.00000
     0   ssd  0.87329         OSD.0       up  1.00000 1.00000
     1   ssd  0.87329         OSD.1       up  1.00000 1.00000
     2   ssd  0.87329         OSD.2       up  1.00000 1.00000
     3   ssd  0.87329         OSD.3       up  1.00000 1.00000
     4   ssd  0.87329         OSD.4       up  1.00000 1.00000
     5   ssd  0.87329         OSD.5       up  1.00000 1.00000
     6   ssd  0.87329         OSD.6       up  1.00000 1.00000
    -5        8.00525     host ceph02
    16  nvme  0.90970         OSD.16      up  1.00000 1.00000
    17  nvme  0.90970         OSD.17      up  1.00000 1.00000
    18  nvme  0.90970         OSD.18      up  1.00000 1.00000
    19  nvme  0.90970         OSD.19      up  1.00000 1.00000
    11   ssd  0.87329         OSD.11      up  1.00000 1.00000
    12   ssd  0.87329         OSD.12      up  1.00000 1.00000
    13   ssd  0.87329         OSD.13      up  1.00000 1.00000
    14   ssd  0.87329         OSD.14      up  1.00000 1.00000
    15   ssd  0.87329         OSD.15      up  1.00000 1.00000
    -7        8.00525     host ceph03
    25  nvme  0.90970         OSD.25      up  1.00000 1.00000
    26  nvme  0.90970         OSD.26      up  1.00000 1.00000
    27  nvme  0.90970         OSD.27      up  1.00000 1.00000
    28  nvme  0.90970         OSD.28      up  1.00000 1.00000
    20   ssd  0.87329         OSD.20      up  1.00000 1.00000
    21   ssd  0.87329         OSD.21      up  1.00000 1.00000
    22   ssd  0.87329         OSD.22      up  1.00000 1.00000
    23   ssd  0.87329         OSD.23      up  1.00000 1.00000
    24   ssd  0.87329         OSD.24      up  1.00000 1.00000
    
`object-ssd`对象存储于`OSD.13`、`OSD.1`、`OSD.21`，即`ssd class`，对应`ssd`类型磁盘

`object-nvme`对象存储于`OSD.28`、`OSD.19`、`OSD.8`，即`nvme class`，对应`nvme`类型磁盘

**最佳实践：创建不同类型存储池（基于HDD、SSD，提供不同场景使用）**

### 安装dashboard
 
- [rpm](http://download.ceph.com/rpm-nautilus/el7/noarch/)
 
> 安装

    ceph-deploy mgr create ceph01
    
> 启用`Dashboard`

    ceph mgr module enable dashboard
    
> 启用必要模块

    ceph mgr module enable pg_autoscaler
    
> 用户、密码、权限

    # 创建用户
    #ceph dashboard ac-user-create <username> <password> administrator
    ceph dashboard ac-user-create admin Ceph-12345 administrator

> 创建自签证书

    ceph dashboard create-self-signed-cert
    
> 查看`Dashboard`地址
  
    [root@ceph01 ~]# ceph mgr services
    {
        "dashboard": "https://ceph01:8443/"
    }
    
> 登录访问

![](images/ceph-ui.png)

> 修改端口

确认配置

    [root@ceph01 ~]# ceph config-key  ls
    [
        "config-history/1/",
        "config-history/2/",
        "config-history/2/+global/osd_pool_default_pg_autoscale_mode",
        "config/global/osd_pool_default_pg_autoscale_mode",
        "mgr/dashboard/accessdb_v1",
        "mgr/dashboard/crt",
        "mgr/dashboard/jwt_secret",
        "mgr/dashboard/key"
    ]
    
修改端口

    ceph config set mgr mgr/dashboard/ssl_server_port 7000

使变更的配置生效
    
    ceph mgr module disable dashboard
    ceph mgr module enable dashboard
    
> 配置访问前缀
   
    ceph config set mgr mgr/dashboard/url_prefix /ceph-ui
    
重启`mgr`

    systemctl restart ceph-mgr@ceph01
      
# ceph存储实践

## 块设备使用

### ceph管理节点

> 创建池（SSD_rule为crush规则）

    [root@ceph01 ~]# ceph osd pool create rbd-demo-pool 64 64 
    pool 'rbd-demo-pool' created
    
> 设置配额

    [root@ceph01 ~]# ceph osd pool set-quota rbd-demo-pool max_bytes 1G
    set-quota max_bytes = 1073741824 for pool rbd-demo-pool
    
> 关联应用

    [root@ceph01 ~]# ceph osd pool application enable rbd-demo-pool rbd
    enabled application 'rbd' on pool 'rbd-demo-pool'
    
> 初始化

    [root@ceph01 ~]# rbd pool init rbd-demo-pool
    
> 创建rbd用户

    ceph auth get-or-create client.qemu mon 'profile rbd' osd 'profile rbd pool=rbd-demo-pool' mgr 'profile rbd pool=rbd-demo-pool' -o /etc/ceph/ceph.client.qemu.keyring

> 创建rbd映像
        
在将块设备添加到节点之前，必须先在`Ceph`存储集群中为其创建映像。要创建块设备映像，请执行以下操作：

    rbd create --size 1G rbd-demo-pool/rbd-demo-image
    
> 查看块设备映像
       
    # rbd ls {poolname}
    [root@ceph01 ~]# rbd ls rbd-demo-pool
    rbd-demo-image
    
> 查看块设备映像信息
    
    [root@ceph01 ~]# rbd info rbd-demo-pool/rbd-demo-image
    rbd image 'rbd-demo-image':
            size 1 GiB in 256 objects
            order 22 (4 MiB objects)
            snapshot_count: 0
            id: 3d92a06e59b5
            block_name_prefix: rbd_data.3d92a06e59b5
            format: 2
            features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
            op_features:
            flags:
            create_timestamp: Fri Mar 19 15:45:58 2021
            access_timestamp: Fri Mar 19 15:45:58 2021
            modify_timestamp: Fri Mar 19 15:45:58 2021
    
### 客户端

> 删除原有yum源repo文件

	rm -f /etc/yum.repos.d/*.repo
	
> 创建yum源文件（客户端）

**online**

	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
	
**offline**
    
下载以下文件上传至`/etc/yum.repos.d/`

- [Centos-7.repo](http://mirrors.aliyun.com/repo/Centos-7.repo)
- [epel-7.repo](http://mirrors.aliyun.com/repo/epel-7.repo)

> 配置`ceph`镜像源仓库

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

> 配置`yum`代理

**适用于主机通过代理访问互联网场景**

以下变量注意替换

- username: 代理用户名
- password: 代理用户密码
- proxy_host: 代理IP地址
- proxy_port: 代理端口


    echo "proxy=http://username:password@proxy_host:proxy_port" >> /etc/yum.conf

> 安装`ceph-common`

    yum install -y ceph-common
    
> 拷贝配置文件

    mkdir -p /etc/ceph
    
客户端创建挂载目录

    mkdir -p /ceph
    chmod 777 /ceph
    
从服务端`scp`以下文件至客户端`/etc/ceph`下

- `/etc/ceph/ceph.client.qemu.keyring`
- `/etc/ceph/ceph.conf`


    scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} ip:/etc/ceph/

> 映射块设备

    [root@localhost ~]# rbd map rbd-demo-pool/rbd-demo-image --name client.qemu
    /dev/rbd0
    [root@localhost ~]# echo "rbd-demo-pool/rbd-demo-image id=qemu,keyring=/etc/ceph/ceph.client.qemu.keyring" >> /etc/ceph/rbdmap
    
> 格式化块设备

     mkfs.ext4 -q /dev/rbd0
     
> 挂载使用

    mount /dev/rbd0 /ceph

> 查看挂载

    lsblk
    
> 查看块设备映射

    [root@localhost ~]# rbd device list
    id pool          namespace image          snap device
    0  rbd-demo-pool           rbd-demo-image -    /dev/rbd0
 
> 修改`fstab`，设置开机挂载

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
    
### 适用场景

**可以当成本地盘来用：**

- 虚机存储
- 开发数据库存储
- 存储日志

## ceph文件系统使用

### 服务端

> 安装`mds`（ceph节点安装，建议3个`mds`）

    ceph-deploy mds create ceph01 ceph02 ceph03  

> 创建`cephfs`存储池与元数据池

    ceph osd pool create cephfs_data 64
    ceph osd pool create cephfs_metadata 64
    
> 创建文件系统

    ceph fs new cephfs cephfs_metadata cephfs_data
    
> 关联应用

    [root@ceph01 ~]# ceph osd pool application enable cephfs_data cephfs
    enabled application 'cephfs' on pool 'cephfs_data'
    
> 设置配额

    ceph osd pool set-quota cephfs_data max_bytes 100G
    
> 创建用户

    [root@ceph01 ~]#  ceph auth get-or-create client.cephfs mon 'allow r' mds 'allow r, allow rw path=/' osd 'allow rw pool=cephfs_data'
    [client.cephfs]
            key = AQCHWlRg46I6EBAAg+xBZnFsqOYIGluPd5h1QA==
            
### 客户端

**内核需4.x**

> 删除原有yum源repo文件

	rm -f /etc/yum.repos.d/*.repo
	
> 创建yum源文件（客户端）

**online**

	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
	
**offline**
    
下载以下文件上传至`/etc/yum.repos.d/`

- [Centos-7.repo](http://mirrors.aliyun.com/repo/Centos-7.repo)
- [epel-7.repo](http://mirrors.aliyun.com/repo/epel-7.repo)

> 配置`ceph`镜像源仓库

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

> 配置`yum`代理

**适用于主机通过代理访问互联网场景**

以下变量注意替换

- username: 代理用户名
- password: 代理用户密码
- proxy_host: 代理IP地址
- proxy_port: 代理端口


    echo "proxy=http://username:password@proxy_host:proxy_port" >> /etc/yum.conf

> 安装`ceph-common`

    yum install -y ceph-common

> 创建目录

配置目录

    mkdir -p /etc/ceph
    
挂载`cephfs`目录

    mkdir -p /cephfs
    
> 创建认证文件

**服务端执行以下命令获取cephfs用户认证信息**

    [root@ceph01 ~]# ceph auth get client.cephfs
    exported keyring for client.cephfs
    [client.cephfs]
            key = AQCHWlRg46I6EBAAg+xBZnFsqOYIGluPd5h1QA==
            caps mds = "allow r, allow rw path=/"
            caps mon = "allow r"
            caps osd = "allow rw pool=cephfs_data"
            
客户端创建认证文件

    cat <<EOF > /etc/ceph/cephfs.key
    AQCHWlRg46I6EBAAg+xBZnFsqOYIGluPd5h1QA==
    EOF
    
> 挂载文件系统

    mount -t ceph 192.168.1.69:6789,192.168.1.70:6789,192.168.1.71:6789:/ /cephfs -o name=cephfs,secretfile=/etc/ceph/cephfs.key

> 创建测试文件

    touch /cephfs/123
    
> 配置开机挂载

    cat <<EOF >> /etc/fstab
    192.168.1.69:6789,192.168.1.70:6789,192.168.1.71:6789:/     /cephfs    ceph    name=cephfs,secretfile=/etc/ceph/cephfs.key,noatime,_netdev    0       2
    EOF

> 重启主机验证

    reboot
    
### 适用场景

- 文件共享
- 网站文件、代码存储
- 数据备份
- 日志存储
- 数据分析

# k8s对接ceph

## k8s-csi

### csi简介

`Kubernetes`从`1.9`版本开始引入容器存储接口`Container Storage Interface`（CSI）机制，用于在`Kubernetes`和外部存储系统之间建立一套标准的存储管理接口，通过该接口为容器提供存储服务。

### csi设计背景

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

### csi架构

`KubernetesCSI`存储插件的关键组件和推荐的容器化部署架构：

![](images/csi-artitechture.png)


#### CSI Controller

`CSI Controller`的主要功能是提供存储服务视角对存储资源和存储卷进行管理和操作。
在`Kubernetes`中建议将其部署为单实例`Pod`，可以使用`StatefulSet`或`Deployment`控制器进行部署，设置副本数量为1，保证为一种存储插件只运行一个控制器实例。
在这个`Pod`内部署两个容器：
- 与`Master`（kube-controller-manager）通信的辅助`sidecar`容器。在`sidecar`容器内又可以包含`external-attacher`和`external-provisioner`两个容器，它们的功能分别如下:
    - `external-attacher`：监控`VolumeAttachment`资源对象的变更，触发针对`CSI`端点的`ControllerPublish`和`ControllerUnpublish`操作。
    - `external-provisioner`：监控`PersistentVolumeClaim`资源对象的变更，触发针对`CSI`端点的`CreateVolume`和`DeleteVolume`操作。
- `CSI Driver`存储驱动容器，由第三方存储提供商提供，需要实现上述接口。

这两个容器通过本地`Socket`（Unix DomainSocket，UDS），并使用`gPRC`协议进行通信。
`sidecar`容器通过`Socket`调用`CSI Driver`容器的`CSI`接口，`CSI Driver`容器负责具体的存储卷操作。

#### CSI Node

`CSI Node`的主要功能是对主机（Node）上的`Volume`进行管理和操作。在`Kubernetes`中建议将其部署为`DaemonSet`，在每个`Node`上都运行一个`Pod`。
在这个`Pod`中部署以下两个容器：

- 与`kubelet`通信的辅助`sidecar`容器`node-driver-registrar`，主要功能是将存储驱动注册到`kubelet`中
- `CSI Driver`存储驱动容器，由第三方存储提供商提供，主要功能是接收`kubelet`的调用，需要实现一系列与`Node`相关的`CSI`接口，例如`NodePublishVolume`接口（用于将Volume挂载到容器内的目标路径）、`NodeUnpublishVolume`接口（用于从容器中卸载Volume），等等。

`node-driver-registrar`容器与`kubelet`通过`Node`主机的一个`hostPath`目录下的`unixsocket`进行通信。`CSI Driver`容器与`kubelet`通过`Node`主机的另一个`hostPath`目录下的`unixsocket`进行通信，同时需要将`kubelet`的工作目录（默认为/var/lib/kubelet）挂载给`CSIDriver`容器，用于为`Pod`进行`Volume`的管理操作（包括mount、umount等）。

## k8s接入ceph块存储

使用[ceph-csi](https://github.com/ceph/ceph-csi) 实现

### ceph服务端

> 创建一个池，用以为`k8s`提供块存储服务

    [root@ceph01 ~]# ceph osd pool create rbd-k8s-pool 256 256 SSD_rule
    pool 'rbd-k8s-pool' created
    
> 设置配额

    [root@ceph01 ~]# ceph osd pool set-quota rbd-k8s-pool max_bytes 100G
    set-quota max_bytes = 107374182400 for pool rbd-k8s-pool
    
> 关联应用

    [root@ceph01 ~]# ceph osd pool application enable rbd-k8s-pool rbd
    enabled application 'rbd' on pool 'rbd-k8s-pool'
    
> 初始化

    rbd pool init rbd-k8s-pool
    
> 创建用户

    [root@ceph01 ~]# ceph auth get-or-create client.kubernetes mon 'profile rbd' osd 'profile rbd pool=rbd-k8s-pool' mgr 'profile rbd pool=rbd-k8s-pool'
    [client.kubernetes]
            key = AQCS6kFg0NRDIBAAorr8r5Oxiz1eYH61VvLVYA==     

### k8s节点

> 下载配置文件

- [ceph-csi-3.2.0.zip](https://github.com/ceph/ceph-csi/archive/v3.2.0.zip)

> 上传配置文件解压

    unzip ceph-csi-3.2.0.zip
    
> 创建一个命名空间，用于管理`ceph-csi`
    
    kubectl create ns ceph-csi
    
> 更改`ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-config-map.yaml`

获取集群信息(`ceph`管理节点执行)

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
    
  
- `b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294`为集群`ID`
- 监控节点地址：`192.168.1.69:6789,192.168.1.70:6789,192.168.1.71:6789`

更改后`csi-config-map.yaml`内容如下：

    
    vim ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-config-map.yaml
    
    ---
    apiVersion: v1
    kind: ConfigMap
    data:
      config.json: |-
        [
          {
            "clusterID": "b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294",
            "monitors": [
              "192.168.1.69:6789",
              "192.168.1.70:6789",
              "192.168.1.71:6789"
            ]
          }
        ]
    metadata:
      name: ceph-csi-config
      
> 创建`csi-config-map`

    kubectl -n ceph-csi apply -f ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-config-map.yaml

> 创建`csi-rbd-secret`

创建

    cat <<EOF > ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-rbd-secret.yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: csi-rbd-secret
      namespace: ceph-csi
    stringData:
      userID: kubernetes
      userKey: AQCS6kFg0NRDIBAAorr8r5Oxiz1eYH61VvLVYA==
    EOF
    
`AQCS6kFg0NRDIBAAorr8r5Oxiz1eYH61VvLVYA==`可通过在`ceph`服务端执行`ceph auth get client.kubernetes`获取

发布

    kubectl apply -f ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-rbd-secret.yaml

> 配置清单中的`namespace`改成`ceph-csi`

    sed -i "s/namespace: default/namespace: ceph-csi/g" $(grep -rl "namespace: default" ./ceph-csi-3.2.0/deploy/rbd/kubernetes)
    sed -i -e "/^kind: ServiceAccount/{N;N;a\  namespace: ceph-csi  # 输入到这里的时候需要按一下回车键，在下一行继续输入
    }" $(egrep -rl "^kind: ServiceAccount" ./ceph-csi-3.2.0/deploy/rbd/kubernetes)

> 创建`ServiceAccount`和`RBAC ClusterRole/ClusterRoleBinding`资源对象

    kubectl create -f ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-provisioner-rbac.yaml
    kubectl create -f ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-nodeplugin-rbac.yaml

> 创建`PodSecurityPolicy`

    kubectl create -f ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-provisioner-psp.yaml
    kubectl create -f ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-nodeplugin-psp.yaml

> 调整`csi-rbdplugin-provisioner.yaml`和`csi-rbdplugin.yaml`

将`csi-rbdplugin.yaml`中的`kms`部分配置注释掉

    # vim ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-rbdplugin.yaml
    ...
    - name: ceph-csi-encryption-kms-config
      mountPath: /etc/ceph-csi-encryption-kms-config/
    ...
    ...
    - name: ceph-csi-encryption-kms-config
      configMap:
        name: ceph-csi-encryption-kms-config
    ...

将`csi-rbdplugin-provisioner.yaml`中的`kms`部分配置注释掉
    
    # vim ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-rbdplugin-provisioner.yaml
    ...
    - name: ceph-csi-encryption-kms-config
      mountPath: /etc/ceph-csi-encryption-kms-config/
    ...
    ...
    - name: ceph-csi-encryption-kms-config
      configMap:
        name: ceph-csi-encryption-kms-config
    ...
    
将`csi-rbdplugin.yaml`中的`image`部分调整为可访问镜像地址

    k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.0.1
    quay.io/cephcsi/cephcsi:v3.2.0
    
将`csi-rbdplugin-provisioner.yaml`中的`image`部分调整为可访问镜像地址

    quay.io/cephcsi/cephcsi:v3.2.0
    k8s.gcr.io/sig-storage/csi-provisioner:v2.0.4
    k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.2
    k8s.gcr.io/sig-storage/csi-attacher:v3.0.2
    k8s.gcr.io/sig-storage/csi-resizer:v1.0.1
    
发布`csi-rbdplugin-provisioner.yaml`和`csi-rbdplugin.yaml`

    kubectl -n ceph-csi create -f ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-rbdplugin-provisioner.yaml
    kubectl -n ceph-csi create -f ceph-csi-3.2.0/deploy/rbd/kubernetes/csi-rbdplugin.yaml

查看运行状态

    [root@ceph01 ~]# kubectl get pod -n ceph-csi
    NAME                                         READY   STATUS    RESTARTS   AGE
    csi-rbdplugin-ddc42                          3/3     Running   0          76s
    csi-rbdplugin-fwwfv                          3/3     Running   0          76s
    csi-rbdplugin-provisioner-76959bd74d-gwd9k   7/7     Running   0          5h32m
    csi-rbdplugin-provisioner-76959bd74d-nb574   7/7     Running   0          5h32m
    
> 创建`StorageClass`

`b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294`为`ceph`集群`ID`注意替换

生成配置文件

    cat <<EOF > ceph-csi-3.2.0/deploy/rbd/kubernetes/storageclass.yaml
    ---
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: ceph-csi-rbd-sc
    provisioner: rbd.csi.ceph.com
    parameters:
      clusterID: b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
      pool: rbd-k8s-pool
      imageFeatures: layering
      csi.storage.k8s.io/provisioner-secret-name: csi-rbd-secret
      csi.storage.k8s.io/provisioner-secret-namespace: ceph-csi
      csi.storage.k8s.io/controller-expand-secret-name: csi-rbd-secret
      csi.storage.k8s.io/controller-expand-secret-namespace: ceph-csi
      csi.storage.k8s.io/node-stage-secret-name: csi-rbd-secret
      csi.storage.k8s.io/node-stage-secret-namespace: ceph-csi
      csi.storage.k8s.io/fstype: ext4
    reclaimPolicy: Delete
    allowVolumeExpansion: true
    mountOptions:
      - discard
    EOF
    
创建

    kubectl apply -f ceph-csi-3.2.0/deploy/rbd/kubernetes/storageclass.yaml
    
配置为默认`storage class`

    kubectl patch storageclass ceph-csi-rbd-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

查看`storage class`

    [root@ceph01 ~]# kubectl get sc
    NAME                        PROVISIONER        RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    ceph-csi-rbd-sc (default)   rbd.csi.ceph.com   Delete          Immediate              true                   117s

> 创建`pvc`验证可用性

生成配置

    cat <<EOF > ceph-csi-3.2.0/deploy/rbd/kubernetes/pvc-demo.yaml 
    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: ceph-pvc-demo
      namespace: default
    spec:
      storageClassName: ceph-csi-rbd-sc
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    EOF
    
创建

    kubectl apply -f ceph-csi-3.2.0/deploy/rbd/kubernetes/pvc-demo.yaml
    
查看

    [root@ceph01 ~]# kubectl get pvc
    NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
    ceph-pvc-demo   Bound    pvc-7b7d4d8a-c4f4-40b6-9372-661ece7c385e   1Gi        RWO            ceph-csi-rbd-sc   13s
    
> `pvc`扩容

生成配置

    cat <<EOF > ceph-csi-3.2.0/deploy/rbd/kubernetes/nginx-demo.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      name: testpv
      labels:
        role: web-frontend
    spec:
      containers:
      - name: web
        image: nginx
        ports:
          - name: web
            containerPort: 80
        volumeMounts:
          - name: ceph-pvc-demo
            mountPath: "/usr/share/nginx/html"
      volumes:
      - name: ceph-pvc-demo
        persistentVolumeClaim:
          claimName: ceph-pvc-demo
    EOF
    
发布

    kubectl apply -f ceph-csi-3.2.0/deploy/rbd/kubernetes/nginx-demo.yaml
    
查看`pvc`

    [root@ceph01 ~]# kubectl get pvc
    NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
    ceph-pvc-demo   Bound    pvc-360f8c5b-0f82-4f17-957b-a7eb5cf93f7e   1Gi        RWO            ceph-csi-rbd-sc   2m50s

编辑修改`pvc`

    kubectl edit pvc ceph-pvc-demo
    
修改以下内容，`storage: 1Gi`调整为`storage: 10Gi`

    ...
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    ...
    
重启

    kubectl get pod testpv -o yaml | kubectl replace --force -f -
    
再次查看`pvc`

    [root@ceph01 ~]# kubectl get pvc
    NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
    ceph-pvc-demo   Bound    pvc-360f8c5b-0f82-4f17-957b-a7eb5cf93f7e   10Gi       RWO            ceph-csi-rbd-sc   9m26s

## k8s接入ceph文件系统

### ceph服务端

> 安装`mds`

    ceph-deploy mds create ceph01 ceph02 ceph03  

> 创建`cephfs`存储池与元数据池，用以为`k8s`提供文件系统服务

    ceph osd pool create cephfs_data 64
    ceph osd pool create cephfs_metadata 64
    
> 创建文件系统

    ceph fs new k8s-cephfs cephfs_metadata cephfs_data
    
> 关联应用

    [root@ceph01 ~]# ceph osd pool application enable cephfs_data cephfs
    enabled application 'cephfs' on pool 'cephfs_data'
    
> 设置配额

    ceph osd pool set-quota cephfs_data max_bytes 100G
    
> 创建用户

    [root@ceph01 kubernetes]# ceph auth get-or-create client.cephfs mon 'allow r' mds 'allow r, allow rw path=/' osd 'allow rw pool=cephfs_data'
    [client.cephfs]
            key = AQCoW0dgQk4qGhAAwayKv70OSyyWB3XpZ1JLYQ==

### k8s节点

> 下载配置文件

- [ceph-csi-3.2.0.zip](https://github.com/ceph/ceph-csi/archive/v3.2.0.zip)

> 上传配置文件解压

    unzip ceph-csi-3.2.0.zip
    
> 创建一个命名空间，用于管理`ceph-csi`
    
    kubectl create ns ceph-csi
    
> 更改`ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-config-map.yaml`

获取集群信息(`ceph`管理节点执行)

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
    
  
- `b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294`为集群`ID`
- 监控节点地址：`192.168.1.69:6789,192.168.1.70:6789,192.168.1.71:6789`

更改后`csi-config-map.yaml`内容如下：

    
    vim ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-config-map.yaml
    
    ---
    apiVersion: v1
    kind: ConfigMap
    data:
      config.json: |-
        [
          {
            "clusterID": "b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294",
            "monitors": [
              "192.168.1.69:6789",
              "192.168.1.70:6789",
              "192.168.1.71:6789"
            ]
          }
        ]
    metadata:
      name: ceph-csi-config
      
> 创建`csi-config-map`

    kubectl -n ceph-csi apply -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-config-map.yaml

> 创建`csi-cephfs-secret`

创建

    cat <<EOF > ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-cephfs-secret.yaml
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: csi-cephfs-secret
      namespace: ceph-csi
    stringData:
      # Required for statically provisioned volumes
      userID: cephfs
      userKey: AQCoW0dgQk4qGhAAwayKv70OSyyWB3XpZ1JLYQ==
    
      # Required for dynamically provisioned volumes
      adminID: admin
      adminKey: AQDkTjNgNObEHBAANGLCF23SLKYmqUd2Nxtbaw==
    EOF
    
`AQCoW0dgQk4qGhAAwayKv70OSyyWB3XpZ1JLYQ====`可通过在`ceph`服务端执行`ceph auth get client.cephfs`获取

发布

    kubectl apply -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-cephfs-secret.yaml

> 配置清单中的`namespace`改成`ceph-csi`

    sed -i "s/namespace: default/namespace: ceph-csi/g" $(grep -rl "namespace: default" ./ceph-csi-3.2.0/deploy/cephfs/kubernetes)
    sed -i -e "/^kind: ServiceAccount/{N;N;a\  namespace: ceph-csi  # 输入到这里的时候需要按一下回车键，在下一行继续输入
    }" $(egrep -rl "^kind: ServiceAccount" ./ceph-csi-3.2.0/deploy/cephfs/kubernetes)

> 创建`ServiceAccount`和`RBAC ClusterRole/ClusterRoleBinding`资源对象

    kubectl create -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-provisioner-rbac.yaml
    kubectl create -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-nodeplugin-rbac.yaml

> 创建`PodSecurityPolicy`

    kubectl create -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-provisioner-psp.yaml
    kubectl create -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-nodeplugin-psp.yaml

> 调整`csi-cephfsplugin-provisioner.yaml`和`csi-cephfsplugin.yaml`
    
将`csi-cephfsplugin.yaml`中的`image`部分调整为可访问镜像地址

    k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.0.1
    quay.io/cephcsi/cephcsi:v3.2.0
    
将`csi-cephfsplugin-provisioner.yaml`中的`image`部分调整为可访问镜像地址

    quay.io/cephcsi/cephcsi:v3.2.0
    k8s.gcr.io/sig-storage/csi-provisioner:v2.0.4
    k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.2
    k8s.gcr.io/sig-storage/csi-attacher:v3.0.2
    k8s.gcr.io/sig-storage/csi-resizer:v1.0.1
    
发布`csi-cephfsplugin-provisioner.yaml`和`csi-cephfsplugin.yaml`

    kubectl -n ceph-csi create -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-cephfsplugin-provisioner.yaml
    kubectl -n ceph-csi create -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/csi-cephfsplugin.yaml

查看运行状态

    kubectl get pod -n ceph-csi

> 创建`StorageClass`

`b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294`为`ceph`集群`ID`注意替换

生成配置文件

    cat <<EOF > ceph-csi-3.2.0/deploy/cephfs/kubernetes/storageclass.yaml
    ---
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: ceph-csi-cephfs-sc
    provisioner: cephfs.csi.ceph.com
    parameters:
      clusterID: b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
      pool: cephfs_data
      fsName: k8s-cephfs
      imageFeatures: layering
      csi.storage.k8s.io/provisioner-secret-name: csi-cephfs-secret
      csi.storage.k8s.io/provisioner-secret-namespace: ceph-csi
      csi.storage.k8s.io/controller-expand-secret-name: csi-cephfs-secret
      csi.storage.k8s.io/controller-expand-secret-namespace: ceph-csi
      csi.storage.k8s.io/node-stage-secret-name: csi-cephfs-secret
      csi.storage.k8s.io/node-stage-secret-namespace: ceph-csi
      csi.storage.k8s.io/fstype: ext4
    reclaimPolicy: Delete
    allowVolumeExpansion: true
    mountOptions:
      - discard
    EOF
    
创建

    kubectl apply -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/storageclass.yaml
    
配置为默认`storage class`(已有默认，需要编辑更改)

    kubectl patch storageclass ceph-csi-rbd-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

查看`storage class`

    [root@ceph01 ~]# kubectl get sc
    NAME                        PROVISIONER           RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    ceph-csi-cephfs-sc          cephfs.csi.ceph.com   Delete          Immediate              true                   5s
    ceph-csi-rbd-sc (default)   rbd.csi.ceph.com      Delete          Immediate              true                   27h

> 创建`pvc`验证可用性

生成配置

    cat <<EOF > ceph-csi-3.2.0/deploy/cephfs/kubernetes/pvc-demo.yaml 
    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: cephfs-pvc-demo
      namespace: default
    spec:
      storageClassName: ceph-csi-cephfs-sc
      accessModes:
      - ReadWriteMany
      resources:
        requests:
          storage: 1Gi
    EOF
    
创建

    kubectl apply -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/pvc-demo.yaml
    
查看

    [root@ceph01 ~]# kubectl get pvc
    NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
    ceph-pvc-demo                          Bound    pvc-360f8c5b-0f82-4f17-957b-a7eb5cf93f7e   20Gi       RWO            ceph-csi-rbd-sc      28h
    cephfs-pvc-demo                        Bound    pvc-9400e0ab-2e44-4ce6-af39-a403441931e5   1Gi        RWX            ceph-csi-cephfs-sc   71s
    
> `pvc`扩容

生成配置

    cat <<EOF > ceph-csi-3.2.0/deploy/cephfs/kubernetes/nginx-demo.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      name: cephfs-testpv
      labels:
        role: web-frontend
    spec:
      containers:
      - name: web
        image: nginx
        ports:
          - name: web
            containerPort: 80
        volumeMounts:
          - name: cephfs-pvc-demo
            mountPath: "/usr/share/nginx/html"
      volumes:
      - name: cephfs-pvc-demo
        persistentVolumeClaim:
          claimName: cephfs-pvc-demo
    EOF
    
发布

    kubectl apply -f ceph-csi-3.2.0/deploy/cephfs/kubernetes/nginx-demo.yaml
    
查看`pvc`

    [root@ceph01 ~]# kubectl get pvc cephfs-pvc-demo
    NAME              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
    cephfs-pvc-demo   Bound    pvc-9400e0ab-2e44-4ce6-af39-a403441931e5   1Gi        RWX            ceph-csi-cephfs-sc   7m2s

编辑修改`pvc`

    kubectl edit pvc cephfs-pvc-demo
    
修改以下内容，`storage: 1Gi`调整为`storage: 10Gi`

    ...
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    ...
    
再次查看`pvc`

    [root@ceph01 ~]# kubectl get pvc cephfs-pvc-demo
    NAME              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
    cephfs-pvc-demo   Bound    pvc-9400e0ab-2e44-4ce6-af39-a403441931e5   10Gi       RWX            ceph-csi-cephfs-sc   9m
    
**与`ceph rbd`不同的是，扩容`pvc`时不需重启后端应用**

# ceph运维管理

## 服务启停

### 按节点启动所有ceph服务

    systemctl start ceph.target
    
或

    sudo systemctl start ceph-osd.target
    sudo systemctl start ceph-mon.target
    sudo systemctl start ceph-mds.target
    
### 按节点停止所有ceph服务

    systemctl stop ceph\*.service ceph\*.target

或

    sudo systemctl stop ceph-mon\*.service ceph-mon.target
    sudo systemctl stop ceph-osd\*.service ceph-osd.target
    sudo systemctl stop ceph-mds\*.service ceph-mds.target
    
### 控制节点管理集群所有服务

启

    sudo systemctl start ceph-osd@{id}
    sudo systemctl start ceph-mon@{hostname}
    sudo systemctl start ceph-mds@{hostname}
    
停

    sudo systemctl stop ceph-osd@{id}
    sudo systemctl stop ceph-mon@{hostname}
    sudo systemctl stop ceph-mds@{hostname}

## pool管理

### 查看`pool`

    [root@ceph01 ~]# ceph osd lspools
    1 ssd-demo-pool
    2 nvme-demo-pool

### 创建一个pool

格式

    ceph osd pool create {pool-name} {pg-num} [{pgp-num}] [replicated] \
         [crush-rule-name] [expected-num-objects]
         
    或
         
    ceph osd pool create {pool-name} {pg-num}  {pgp-num}   erasure \
         [erasure-code-profile] [crush-rule-name] [expected_num_objects]

**最佳实践**

### 设置池的放置组数

    ceph osd pool set {pool-name} pgp_num {pgp_num}

### 获取池的放置组数

    ceph osd pool get {pool-name} pg_num
    
### 获取集群的PG统计信息
  
    # ceph pg dump [--format {format}]
    ceph pg dump -f json

### 将池与应用程序关联

池在使用之前需要与应用程序相关联。将与`cepfs`一起使用的池或由`RGW`自动创建的池将自动关联。
用于与`RBD`一起使用的池应该使用`RBD`工具进行初始化。

    # ceph osd pool application enable {pool-name} {application-name}(cephfs, rbd, rgw)
    [root@ceph01 ~]# ceph osd pool application enable ssd-demo-pool rbd
    enabled application 'rbd' on pool 'ssd-demo-pool'
    [root@ceph01 ~]# ceph osd pool application enable nvme-demo-pool cephfs
    enabled application 'cephfs' on pool 'nvme-demo-pool'

### 池配额

您可以为每个池的最大字节数和/或最大对象数设置池配额。

    # ceph osd pool set-quota {pool-name} [max_objects {obj-count}] [max_bytes {bytes}]
    ceph osd pool set-quota data max_objects 10000
    
要删除配额，请将其值设置为0

    ceph osd pool set-quota data max_objects 0
    
### 删除池

语法格式

    ceph osd pool delete {pool-name} [{pool-name} --yes-i-really-really-mean-it]

修改配置

    vim /etc/ceph/ceph.conf
    
添加如下：

    [mon]
    mon_allow_pool_delete=true

更新

    cd /etc/ceph
    ceph-deploy --overwrite-conf config push ceph01 ceph02 ceph03
    
重启

    systemctl restart ceph-mon.target

    
删除`ddd-pool`

    [root@ceph01 ceph]# ceph osd pool delete ddd-pool ddd-pool --yes-i-really-really-mean-it
    pool 'ddd-pool' removed
    
### 池重命名

    ceph osd pool rename {current-pool-name} {new-pool-name}
    
### 显示池统计信息

    [root@ceph01 ~]# rados df
    POOL_NAME        USED OBJECTS CLONES COPIES MISSING_ON_PRIMARY UNFOUND DEGRADED RD_OPS  RD WR_OPS    WR USED COMPR UNDER COMPR
    nvme-demo-pool 12 KiB       1      0      3                  0       0        0      0 0 B      1 1 KiB        0 B         0 B
    ssd-demo-pool  12 KiB       1      0      3                  0       0        0      0 0 B      1 1 KiB        0 B         0 B
    
    total_objects    2
    total_used       30 GiB
    total_avail      26 TiB
    total_space      26 TiB
    
池`io`

    [root@ceph01 ~]# ceph osd pool stats ssd-demo-pool
    pool ssd-demo-pool id 1
      nothing is going on
      
### 创建池快照
    
    # ceph osd pool mksnap {pool-name} {snap-name}
    [root@ceph01 ~]# ceph osd pool mksnap ssd-demo-pool ssd-demo-pool-snap-20210301
    created pool ssd-demo-pool snap ssd-demo-pool-snap-20210301
    
### 删除池快照

    # ceph osd pool rmsnap {pool-name} {snap-name}
    [root@ceph01 ~]# ceph osd pool rmsnap ssd-demo-pool ssd-demo-pool-snap-20210301
    removed pool ssd-demo-pool snap ssd-demo-pool-snap-20210301
    
### 池其他配置

查看可配置项

    [root@ceph01 ~]# ceph osd pool -h
    
     General usage:
     ==============
    usage: ceph [-h] [-c CEPHCONF] [-i INPUT_FILE] [-o OUTPUT_FILE]
                [--setuser SETUSER] [--setgroup SETGROUP] [--id CLIENT_ID]
                [--name CLIENT_NAME] [--cluster CLUSTER]
                [--admin-daemon ADMIN_SOCKET] [-s] [-w] [--watch-debug]
                [--watch-info] [--watch-sec] [--watch-warn] [--watch-error]
                [--watch-channel {cluster,audit,*}] [--version] [--verbose]
                [--concise] [-f {json,json-pretty,xml,xml-pretty,plain}]
                [--connect-timeout CLUSTER_TIMEOUT] [--block] [--period PERIOD]
    
    Ceph administration tool
    
    optional arguments:
      -h, --help            request mon help
      -c CEPHCONF, --conf CEPHCONF
                            ceph configuration file
      -i INPUT_FILE, --in-file INPUT_FILE
                            input file, or "-" for stdin
      -o OUTPUT_FILE, --out-file OUTPUT_FILE
                            output file, or "-" for stdout
      --setuser SETUSER     set user file permission
      --setgroup SETGROUP   set group file permission
      --id CLIENT_ID, --user CLIENT_ID
                            client id for authentication
      --name CLIENT_NAME, -n CLIENT_NAME
                            client name for authentication
      --cluster CLUSTER     cluster name
      --admin-daemon ADMIN_SOCKET
                            submit admin-socket commands ("help" for help
      -s, --status          show cluster status
      -w, --watch           watch live cluster changes
      --watch-debug         watch debug events
      --watch-info          watch info events
      --watch-sec           watch security events
      --watch-warn          watch warn events
      --watch-error         watch error events
      --watch-channel {cluster,audit,*}
                            which log channel to follow when using -w/--watch. One
                            of ['cluster', 'audit', '*']
      --version, -v         display version
      --verbose             make verbose
      --concise             make less verbose
      -f {json,json-pretty,xml,xml-pretty,plain}, --format {json,json-pretty,xml,xml-pretty,plain}
      --connect-timeout CLUSTER_TIMEOUT
                            set a timeout for connecting to the cluster
      --block               block until completion (scrub and deep-scrub only)
      --period PERIOD, -p PERIOD
                            polling period, default 1.0 second (for polling
                            commands only)
    
     Local commands:
     ===============
    
    ping <mon.id>           Send simple presence/life test to a mon
                            <mon.id> may be 'mon.*' for all mons
    daemon {type.id|path} <cmd>
                            Same as --admin-daemon, but auto-find admin socket
    daemonperf {type.id | path} [stat-pats] [priority] [<interval>] [<count>]
    daemonperf {type.id | path} list|ls [stat-pats] [priority]
                            Get selected perf stats from daemon/admin socket
                            Optional shell-glob comma-delim match string stat-pats
                            Optional selection priority (can abbreviate name):
                             critical, interesting, useful, noninteresting, debug
                            List shows a table of all available stats
                            Run <count> times (default forever),
                             once per <interval> seconds (default 1)
    
    
     Monitor commands:
     =================
    osd pool application disable <poolname> <app> {--yes-i-really-mean-it}   disables use of an application <app> on pool <poolname>
    osd pool application enable <poolname> <app> {--yes-i-really-mean-it}    enable use of an application <app> [cephfs,rbd,rgw] on pool <poolname>
    osd pool application get {<poolname>} {<app>} {<key>}                    get value of key <key> of application <app> on pool <poolname>
    osd pool application rm <poolname> <app> <key>                           removes application <app> metadata key <key> on pool <poolname>
    osd pool application set <poolname> <app> <key> <value>                  sets application <app> metadata key <key> to <value> on pool <poolname>
    osd pool autoscale-status                                                report on pool pg_num sizing recommendation and intent
    osd pool cancel-force-backfill <poolname> [<poolname>...]                restore normal recovery priority of specified pool <who>
    osd pool cancel-force-recovery <poolname> [<poolname>...]                restore normal recovery priority of specified pool <who>
    osd pool create <poolname> <int[0-]> {<int[0-]>} {replicated|erasure}    create pool
     {<erasure_code_profile>} {<rule>} {<int>} {<int>} {<int[0-]>} {<int[0-
     ]>} {<float[0.0-1.0]>}
    osd pool deep-scrub <poolname> [<poolname>...]                           initiate deep-scrub on pool <who>
    osd pool force-backfill <poolname> [<poolname>...]                       force backfill of specified pool <who> first
    osd pool force-recovery <poolname> [<poolname>...]                       force recovery of specified pool <who> first
    osd pool get <poolname> size|min_size|pg_num|pgp_num|crush_rule|         get pool parameter <var>
     hashpspool|nodelete|nopgchange|nosizechange|write_fadvise_dontneed|
     noscrub|nodeep-scrub|hit_set_type|hit_set_period|hit_set_count|hit_set_
     fpp|use_gmt_hitset|target_max_objects|target_max_bytes|cache_target_
     dirty_ratio|cache_target_dirty_high_ratio|cache_target_full_ratio|
     cache_min_flush_age|cache_min_evict_age|erasure_code_profile|min_read_
     recency_for_promote|all|min_write_recency_for_promote|fast_read|hit_
     set_grade_decay_rate|hit_set_search_last_n|scrub_min_interval|scrub_
     max_interval|deep_scrub_interval|recovery_priority|recovery_op_
     priority|scrub_priority|compression_mode|compression_algorithm|
     compression_required_ratio|compression_max_blob_size|compression_min_
     blob_size|csum_type|csum_min_block|csum_max_block|allow_ec_overwrites|
     fingerprint_algorithm|pg_autoscale_mode|pg_autoscale_bias|pg_num_min|
     target_size_bytes|target_size_ratio
    osd pool get-quota <poolname>                                            obtain object or byte limits for pool
    osd pool ls {detail}                                                     list pools
    osd pool mksnap <poolname> <snap>                                        make snapshot <snap> in <pool>
    osd pool rename <poolname> <poolname>                                    rename <srcpool> to <destpool>
    osd pool repair <poolname> [<poolname>...]                               initiate repair on pool <who>
    osd pool rm <poolname> {<poolname>} {--yes-i-really-really-mean-it} {--  remove pool
     yes-i-really-really-mean-it-not-faking}
    osd pool rmsnap <poolname> <snap>                                        remove snapshot <snap> from <pool>
    osd pool scrub <poolname> [<poolname>...]                                initiate scrub on pool <who>
    osd pool set <poolname> size|min_size|pg_num|pgp_num|pgp_num_actual|     set pool parameter <var> to <val>
     crush_rule|hashpspool|nodelete|nopgchange|nosizechange|write_fadvise_
     dontneed|noscrub|nodeep-scrub|hit_set_type|hit_set_period|hit_set_
     count|hit_set_fpp|use_gmt_hitset|target_max_bytes|target_max_objects|
     cache_target_dirty_ratio|cache_target_dirty_high_ratio|cache_target_
     full_ratio|cache_min_flush_age|cache_min_evict_age|min_read_recency_
     for_promote|min_write_recency_for_promote|fast_read|hit_set_grade_
     decay_rate|hit_set_search_last_n|scrub_min_interval|scrub_max_interval|
     deep_scrub_interval|recovery_priority|recovery_op_priority|scrub_
     priority|compression_mode|compression_algorithm|compression_required_
     ratio|compression_max_blob_size|compression_min_blob_size|csum_type|
     csum_min_block|csum_max_block|allow_ec_overwrites|fingerprint_
     algorithm|pg_autoscale_mode|pg_autoscale_bias|pg_num_min|target_size_
     bytes|target_size_ratio <val> {--yes-i-really-mean-it}
    osd pool set-quota <poolname> max_objects|max_bytes <val>                set object or byte limit on pool
    osd pool stats {<poolname>}                                              obtain stats from all pools, or from specified pool
    
### 设置对象副本数

默认为3

    ceph osd pool set {poolname} size {num-replicas}

### pg_autoscale_mode

放置组（PGs）是`Ceph`分发数据的内部实现细节。
过启用`pg autoscaling`，您可以允许集群提出建议或根据集群的使用方式自动调整`PGs`。

系统中的每个池都有一个`pg_autoscale_mode`属性，可以设置为`off`、`on`或`warn`：

- off：禁用此池的自动缩放。由管理员为每个池选择适当的`PG`数量。
- on：启用给定池的`PG`计数的自动调整。
- warn：当`PG`计数需要调整时发出健康警报（默认）

> 为指定池设置放置组数自动伸缩

    # ceph osd pool set <pool-name> pg_autoscale_mode <mode>
    
    [root@ceph01 ~]# ceph osd pool set ssd-demo-pool pg_autoscale_mode on
    set pool 1 pg_autoscale_mode to on
    
> 设置集群内所有池放置组数自动伸缩

    # ceph config set global OSD_pool_default_pg_autoscale_mode <mode>
    
    ceph config set global OSD_pool_default_pg_autoscale_mode on
    
查看集群内放置组数伸缩策略

    [root@ceph01 ~]# ceph osd pool autoscale-status
    POOL             SIZE TARGET SIZE RATE RAW CAPACITY  RATIO TARGET RATIO EFFECTIVE RATIO BIAS PG_NUM NEW PG_NUM AUTOSCALE
    nvme-demo-pool     7               3.0       11178G 0.0000                               1.0    256         32 warn
    ssd-demo-pool      7               3.0       15202G 0.0000                               1.0     32            on
    
创建`ddd-pool`，并查看集群内放置组数伸缩策略

    [root@ceph01 ~]# ceph osd pool create ddd-pool 1 1
    pool 'ddd-pool' created
    [root@ceph01 ~]# ceph osd pool autoscale-status
    POOL             SIZE TARGET SIZE RATE RAW CAPACITY  RATIO TARGET RATIO EFFECTIVE RATIO BIAS PG_NUM NEW PG_NUM AUTOSCALE
    nvme-demo-pool     7               3.0       26380G 0.0000                               1.0    256         32 warn
    ssd-demo-pool      7               3.0       15202G 0.0000                               1.0     32            on
    ddd-pool           0               3.0       26380G 0.0000                               1.0      1         32 on
    
> 查看池伸缩建议

    POOL             SIZE TARGET SIZE RATE RAW CAPACITY  RATIO TARGET RATIO EFFECTIVE RATIO BIAS PG_NUM NEW PG_NUM AUTOSCALE
    nvme-demo-pool     7               3.0       26380G 0.0000                               1.0    256         32 warn
    ssd-demo-pool      7               3.0       15202G 0.0000                               1.0     32            on
    ddd-pool           0               3.0       26380G 0.0000                               1.0     32            on
    
- `SIZE`：存储在池中的数据量
- `TARGET SIZE`：管理员指定的他们希望最终存储在此池中的数据量
- `RATE`：池的乘数，用于确定消耗了多少原始存储容量。例如，3副本池的比率为3.0，而`k=4`，`m=2`擦除编码池的比率为1.5。
- `RAW CAPACITY`：负责存储此池(可能还有其他池)数据的`OSD`上的裸存储容量的总和。
- `RATIO`：当前池正在消耗的总容量的比率(即RATIO = size * rate / raw capacity)。
- `TARGET RATIO`：管理员指定的期望此池消耗的存储空间相对于设置了目标比率的其他池的比率。如果同时指定了目标大小字节和比率，则该比率优先
- `EFFECTIVE RATIO`：有效比率是通过两种方式调整后的目标比率：
    - 减去设置了目标大小的池预期使用的任何容量
    - 在设置了目标比率的池之间规范化目标比率，以便它们共同以空间的其余部分为目标。例如，4个池的目标收益率为1.0，其有效收益率为0.25。
系统使用实际比率和有效比率中的较大者进行计算。
- `PG_NUM`：池的当前`PG`数
- `NEW PG_NUM`：池的`pgu NUM`期望值。它始终是2的幂，并且只有当期望值与当前值相差超过3倍时才会出现。
- `AUTOSCALE`：`pool_pg_autosacle`模式，可以是`on`、`off`或`warn`。

> 自动缩放
     
允许集群根据使用情况自动扩展`PGs`是最简单的方法。`Ceph`将查看整个系统的总可用存储和`PGs`的目标数量，查看每个池中存储了多少数据，并尝试相应地分配`PGs`。
系统采用的方法相对保守，仅在当前`pg`(pg_num)的数量比它认为应该的数量少3倍以上时才对池进行更改。

每个`OSD`的`pg`目标数基于`mon_target_pg_per_OSD`可配置（默认值：100），可通过以下方式进行调整:

    ceph config set global mon_target_pg_per_OSD 100

### 指定池的期望大小

当第一次创建集群或池时，它将消耗集群总容量的一小部分，并且在系统看来似乎只需要少量的放置组。
但是，在大多数情况下，集群管理员都很清楚，随着时间的推移，哪些池将消耗大部分系统容量。
通过向`Ceph`提供此信息，可以从一开始就使用更合适数量的`pg`，从而防止`pg_num`的后续更改以及在进行这些调整时与移动数据相关的开销

池的目标大小可以通过两种方式指定：要么根据池的绝对大小（即字节），要么作为相对于设置了目标大小比的其他池的权重。

`ddd-pool`预计使用`1G`存储空间

    ceph osd pool set ddd-pool target_size_bytes 1G

相对于设置了`target_size_ratio`的其他池，`mpool`预计将消耗1.0。
如果`mpool`是集群中唯一的池，这意味着预计将使用总容量的100%。
如果有第二个带有`target_size_ratio`1.0的池，那么两个池都希望使用50%的集群容量。

    ceph osd pool set mypool target_size_ratio 1.0
    
### 放置组数配置

    # ceph osd pool create {pool-name} pg_num
    
必须选择`pg_num`的值，因为它（当前）无法自动计算。以下是一些常用值：

- 少于`5 OSDs`设置`pg_num`为128
- `5-10 OSDs`设置`pg_num`为512
- `10-50 OSDs`设置`pg_num`为1024
- 如果您有超过`50`个`OSD`，则需要使用[pgcalc](https://ceph.com/pgcalc/) 计算`pg_num`值


                 (OSDs * 100)
    Total PGs =  ------------
                  pool size
                  
结果应始终四舍五入到最接近的二次方,只有2的幂才能平衡放置组中对象的数量。其他值将导致数据在您的`OSD`中的不均匀分布。

例如，对于具有200个`OSD`和3个副本的池大小的群集，您可以按以下方式估计`PG`的数量：

    (200 * 100)
    ----------- = 6667. 最接近该数值的2的幂等为8192
         3

### 放置组解析

放置组（PG）聚合池中的对象，因为在每个对象的基础上跟踪对象放置和对象元数据在计算上非常昂贵，
即，具有数百万个对象的系统无法在每个对象的基础上真实地跟踪放置。

`Ceph`客户端将计算对象应该在哪个放置组中。它通过散列对象`ID`并基于定义池中`pg`的数量和池的`ID`应用一个操作来实现这一点

放置组中的对象内容存储在一组`OSD`中。例如，在大小为2的复制池中，每个放置组将在两个`OSD`上存储对象.

如果`OSD#2`失败，另一个将被分配到放置组`#1`，并将填充`OSD#1`中所有对象的副本。如果池大小从2更改为3，则会为放置组分配一个附加的`OSD`，并接收放置组中所有对象的副本。

放置组不拥有`OSD`,它们与来自同一池甚至其他池的其他放置组共享`OSD`。如果`OSD#2`失败，放置组`#2`还必须使用`OSD#3`还原对象的副本。

当放置组的数量增加时，新的放置组将被分配`OSD`。`挤压`功能的结果也将更改，以前放置组中的某些对象将复制到新放置组中，并从旧放置组中删除。

### 放置组权衡

数据持久性和所有`OSD`之间的均匀分布需要更多的放置组，但是它们的数量应该减少到最小以节省`CPU`和内存。

> 数据持久性
  
单个`OSD`故障后，数据丢失的风险会增大，直到其中包含的数据被完全恢复。让我们想象一个场景，在单个放置组中导致永久的数据丢失:

- `OSD`故障（可看作磁盘故障），包含对象的所有副本丢失。对于放置组内的所有对象，副本的数量突然从3个下降到2个。
- `Ceph`通过选择一个新的`OSD`来重新创建所有对象的第三个副本，从而开始恢复此放置组。
- 同一放置组中的另一个`OSD`在新`OSD`完全填充第三个拷贝之前失败。一些对象将只有一个幸存的副本。
- `Ceph`会选择另一个`OSD`，并继续复制对象，以恢复所需的副本数量。
- 同一放置组中的第三个`OSD`在恢复完成之前失败。如果此`OSD`包含对象的唯一剩余副本，则它将永久丢失。  

在一个包含10个`OSD`、在3个复制池中有512个放置组的集群中，`CRUSH`将给每个放置组三个`OSD`。
最终，每个`OSD`将托管(512 * 3)/ 10 ~= 150个放置组。
因此，当第一个`OSD`失败时，上述场景将同时启动所有150个安置组的恢复。

正在恢复的150个安置组可能均匀地分布在剩余的9个`OSDs`上。
因此，每个剩余的`OSD`都可能向其他所有`OSD`发送对象副本，并接收一些新对象来存储，因为它们成为了新的放置组的一部分。

完成此恢复所需的时间完全取决于`Ceph`集群的体系结构。假设每个`OSD`由一台机器上的1`TB` `SSD`托管，
所有这些`OSD`都连接到`10Gb/s`交换机，单个`OSD`的恢复在M分钟内完成。
如果每台机器有两个`OSD`、没有`SSD`、`1Gb/s`交换机，它至少会慢一个数量级。

在这种大小的集群中，放置组的数量对数据持f久性几乎没有影响。它可能是128或8192，恢复不会慢或快。

但是，将同一个`Ceph`集群增加到20个`OSD`而不是10个`OSD`可能会加快恢复速度，从而显著提高数据持久性。
每个`OSD`现在只参与~75个放置组，而不是在只有10个`OSD`时参与~150个，而且仍然需要剩下的19个`OSD`执行相同数量的对象副本才能恢复。
但是，以前10个`OSD`每个必须复制大约`100GB`，现在它们每个必须复制`50GB`。
如果网络是瓶颈，那么恢复的速度将是现在的两倍。换句话说，当`OSDs`的数量增加时，恢复速度会更快。

如果这个集群增长到40个`OSD`，那么每个`OSD`只能承载35个放置组。
如果`OSD`故障，除非它被另一个瓶颈阻塞，否则恢复将继续加快。
但是，如果这个集群增长到200个`OSD`，每个`OSD`只能承载~7个放置组。
如果一个`OSD`故障，那么在这些放置组中最多21个`OSD`（7*3）之间会发生恢复：恢复所需的时间将比有40个`OSD`时的集群长，这意味着放置组的数量应该增加。

无论恢复时间有多短，第二个`OSD`都有可能在恢复过程中失败。
在上述10个`osd`集群中，如果其中任何一个失败，那么~17个放置组（即~150/9个正在恢复的放置组）将只有一个幸存副本。
如果剩余的8个`OSD`中的任何一个失败，那么两个放置组的最后一个对象很可能会丢失（即大约17/8个放置组，只恢复了剩余的一个副本）。

当群集的大小增加到20个`osd`时，由于丢失3个`osd`而损坏的放置组的数量会下降。
丢失的第二个`OSD`将降级~4（即恢复~75/19个放置组），而不是~17，并且丢失的第三个`OSD`只有在包含幸存副本的四个`OSD`之一时才会丢失数据。
换句话说，如果在恢复时间范围内丢失一个`OSD`的概率为0.0001%，则在具有10个`OSD`的集群中，丢失的概率从17×10×0.0001%变为具有20个`OSD`的集群中的4×20×0.0001%

**简而言之，更多的`osd`意味着更快的恢复和更低的导致永久性丢失放置组的级联故障风险。就数据持久性而言，512或4096个放置组在少于50个`osd`的集群中大致相当。**

> 池中的对象分布
  
理想情况下，对象均匀分布在每个放置组中。由于`CRUSH`计算每个对象的放置组，
但实际上不知道该放置组中的每个`OSD`中存储了多少数据，因此放置组的数量与`OSD`的数量之间的比率可能会显著影响数据的分布。

例如，如果在一个三副本池中有十个`OSD`的单个放置组，那么只会使用三个`OSD`，因为`CRUSH`没有其他选择。
当有更多的放置组可用时，对象更可能均匀地分布在其中。`CRUSH`还尽一切努力将`osd`均匀地分布在所有现有的放置组中。

不均匀的数据分布可能是由osd和放置组之间的比率以外的因素造成的。
由于挤压不考虑对象的大小，一些非常大的对象可能会造成不平衡。
假设100万个4K对象（总共4GB）均匀分布在10个`OSD`上的1024个放置组中。他们将在每个`OSD`上使用`4GB/10=400MB`。
如果将一个`400MB`对象添加到池中，则支持放置该对象的放置组的三个`OSD`将被`400MB+400MB=800MB`填充，而其他七个`OSD`将仅被`400MB`占用。

> 内存、CPU和网络使用情况

对于每个放置组，`osd`和`mon`始终需要内存、网络和`CPU`，甚至在恢复期间需要更多。通过在放置组中聚集对象来共享此开销是它们存在的主要原因之一。

最小化放置组的数量可以节省大量资源。

## rbd管理

### 创建

> 创建池

    [root@ceph01 ~]# ceph osd pool create rbd-demo-pool 64 64
    pool 'rbd-demo-pool' created
    
> 设置配额

    [root@ceph01 ~]# ceph osd pool set-quota rbd-demo-pool max_bytes 1G
    set-quota max_bytes = 1073741824 for pool rbd-demo-pool
    
> 关联`rbd`应用

    [root@ceph01 ~]# ceph osd pool application enable rbd-demo-pool rbd
    enabled application 'rbd' on pool 'rbd-demo-pool'
    
> 初始化

    rbd pool init rbd-demo-pool
    
> 创建rbd用户

语法格式

    ceph auth get-or-create client.{ID} mon 'profile rbd' osd 'profile {profile name} [pool={pool-name}][, profile ...]' mgr 'profile rbd [pool={pool-name}]'

创建ID为`qemu`、对`rbd-demo-pool`池有读写权限的用户

    ceph auth get-or-create client.qemu mon 'profile rbd' osd 'profile rbd pool=rbd-demo-pool' mgr 'profile rbd pool=rbd-demo-pool' -o /etc/ceph/ceph.client.qemu.keyring

> 创建rbd映像
        
在将块设备添加到节点之前，必须先在`Ceph`存储集群中为其创建映像。要创建块设备映像，请执行以下操作：

    # rbd create --size {megabytes} {pool-name}/{image-name}
    rbd create --size 1G rbd-demo-pool/rbd-demo-image
    
### 查看块设备映像
       
> 查看池内映像
       
    # rbd ls {poolname}
    [root@ceph01 ~]# rbd ls rbd-demo-pool
    rbd-demo-image
    

> 查看块设备映像信息
    
    [root@ceph01 ~]# rbd info rbd-demo-pool/rbd-demo-image
    rbd image 'rbd-demo-image':
            size 1 GiB in 256 objects
            order 22 (4 MiB objects)
            snapshot_count: 0
            id: d3ef49824934
            block_name_prefix: rbd_data.d3ef49824934
            format: 2
            features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
            op_features:
            flags:
            create_timestamp: Mon Mar  1 15:48:05 2021
            access_timestamp: Mon Mar  1 15:48:05 2021
            modify_timestamp: Mon Mar  1 15:48:05 2021
            
### 调整块设备映像的大小

#### 缩容
> 收缩大小为`256M`

    [root@ceph01 ~]# rbd resize --size 256M rbd-demo-pool/rbd-demo-image --allow-shrink
    Resizing image: 100% complete...done.
    
> 查看块设备映像信息
    
    [root@ceph01 ~]# rbd info rbd-demo-pool/rbd-demo-image
    rbd image 'rbd-demo-image':
            size 256 MiB in 64 objects
            order 22 (4 MiB objects)
            snapshot_count: 0
            id: d3ef49824934
            block_name_prefix: rbd_data.d3ef49824934
            format: 2
            features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
            op_features:
            flags:
            create_timestamp: Mon Mar  1 15:48:05 2021
            access_timestamp: Mon Mar  1 15:48:05 2021
            modify_timestamp: Mon Mar  1 15:48:05 2021
   
#### 扩容

**扩容大小上限为池配额大小**
            
> 扩容大小至`1G`

    [root@ceph01 ~]# rbd resize --size 1G rbd-demo-pool/rbd-demo-image --allow-shrink
    Resizing image: 100% complete...done.

> 查看块设备映像信息

    [root@ceph01 ~]# rbd info rbd-demo-pool/rbd-demo-image
    rbd image 'rbd-demo-image':
            size 1 GiB in 256 objects
            order 22 (4 MiB objects)
            snapshot_count: 0
            id: d3ef49824934
            block_name_prefix: rbd_data.d3ef49824934
            format: 2
            features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
            op_features:
            flags:
            create_timestamp: Mon Mar  1 15:48:05 2021
            access_timestamp: Mon Mar  1 15:48:05 2021
            modify_timestamp: Mon Mar  1 15:48:05 2021
            
### 删除块设备映像

    # rbd rm {pool-name}/{image-name}
    [root@ceph01 ~]# rbd rm rbd-demo-pool/rbd-demo-image
    Removing image: 100% complete...done.
    
### 挂载块设备

> 删除原有yum源repo文件

	rm -f /etc/yum.repos.d/*.repo
	
> 创建yum源文件（客户端）

**online**

	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
	
**offline**
    
下载以下文件上传至`/etc/yum.repos.d/`

- [Centos-7.repo](http://mirrors.aliyun.com/repo/Centos-7.repo)
- [epel-7.repo](http://mirrors.aliyun.com/repo/epel-7.repo)

> 配置`ceph`镜像源仓库

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

> 配置`yum`代理

**适用于主机通过代理访问互联网场景**

以下变量注意替换

- username: 代理用户名
- password: 代理用户密码
- proxy_host: 代理IP地址
- proxy_port: 代理端口


    echo "proxy=http://username:password@proxy_host:proxy_port" >> /etc/yum.conf

> 安装`ceph-common`

    yum install -y ceph-common
    
> 拷贝配置文件

    mkdir -p /etc/ceph
    
客户端创建挂载目录

    mkdir -p /ceph
    chmod 777 /ceph
    
从服务端`scp`以下文件至客户端`/etc/ceph`下

- `/etc/ceph/ceph.client.qemu.keyring`
- `/etc/ceph/ceph.conf`


    scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} ip:/etc/ceph/

> 映射块设备

    [root@localhost ~]# rbd map rbd-demo-pool/rbd-demo-image --name client.qemu
    /dev/rbd0
    [root@localhost ~]# echo "rbd-demo-pool/rbd-demo-image id=qemu,keyring=/etc/ceph/ceph.client.qemu.keyring" >> /etc/ceph/rbdmap
    
> 格式化块设备

     mkfs.ext4 -q /dev/rbd0
     
> 挂载使用

    mount /dev/rbd0 /ceph

> 查看挂载

    lsblk
    
> 查看块设备映射

    [root@localhost ~]# rbd device list
    id pool          namespace image          snap device
    0  rbd-demo-pool           rbd-demo-image -    /dev/rbd0
 
> 修改`fstab`，设置开机挂载

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
    
## 卸载
    
### 删除文件系统

> 删除文件系统

查看文件系统

    [root@ceph01 ~]# ceph fs ls
    name: k8s-cephfs, metadata pool: cephfs_metadata, data pools: [cephfs_data ]

删除文件系统

    [root@ceph01 ~]# ceph fs fail k8s-cephfs
    k8s-cephfs marked not joinable; MDS cannot join the cluster. All MDS ranks marked failed.
    [root@ceph01 ~]#     ceph fs rm k8s-cephfs --yes-i-really-mean-it

### 删除池

> 查看池

    [root@ceph01 ~]# ceph osd pool ls
    ssd-demo-pool
    nvme-demo-pool
    rbd-demo-pool
    rbd-k8s-pool
    cephfs_data
    cephfs_metadata
    
> 删除池

    ceph osd pool delete ssd-demo-pool ssd-demo-pool --yes-i-really-really-mean-it
    ceph osd pool delete nvme-demo-pool nvme-demo-pool --yes-i-really-really-mean-it
    ceph osd pool delete rbd-demo-pool rbd-demo-pool --yes-i-really-really-mean-it
    ceph osd pool delete rbd-k8s-pool rbd-k8s-pool --yes-i-really-really-mean-it
    ceph osd pool delete cephfs_data cephfs_data --yes-i-really-really-mean-it
    ceph osd pool delete cephfs_metadata cephfs_metadata --yes-i-really-really-mean-it

### 删除OSD

> `ceph`管理节点执行


    #!/bin/bash
    osd_list=`ceph osd ls`
    for var in $osd_list;
    do
        ceph osd crush rm osd.$var
        ceph auth del osd.$var
    done
    
    ceph osd down all
    ceph osd out all
    ceph osd rm all
    
> 所有`ceph osd`节点执行

    for i in `ls /var/lib/ceph/osd/`;
    do
        umount /var/lib/ceph/osd/$i
    done
    
对于`umount: /var/lib/ceph/osd/ceph-*：目标忙。`的情况，执行以下操作

    [root@node2 ~]# fuser -mv  /var/lib/ceph/osd/ceph-1
                         用户     进程号 权限   命令
    /var/lib/ceph/osd/ceph-1:
                         root     kernel mount /var/lib/ceph/osd/ceph-1
                         ceph       5979 F.... ceph-osd
    [root@node2 ~]# kill -9 5979
    
    [root@node2 ~]# fuser -mv  /var/lib/ceph/osd/ceph-1
                         用户     进程号 权限   命令
    /var/lib/ceph/osd/ceph-1:
                         root     kernel mount /var/lib/ceph/osd/ceph-1
    
    [root@node2 ~]# umount /var/lib/ceph/osd/ceph-1
    
手动擦除盘上数据(所有数据节点)

    # 从DM中移除硬盘对应的编码
    dmsetup remove_all
    # 格式化分区
    yum install gdisk -y
    sgdisk -z /dev/<?>

`ceph`管理节点执行

    ceph-deploy disk zap <node-hostname> /dev/<?>
    
### 卸载组件并清空目录
    
    ceph-deploy purge ceph01 ceph02 ceph03
    
    ceph-deploy purgedata ceph01 ceph02 ceph03
    
    ceph-deploy forgetkeys
        
## 参考文献

- [SAN和NAS之间的基本区别](https://www.cnblogs.com/cainiao-chuanqi/p/12204944.html)
- [ceph-csi](https://github.com/ceph/ceph-csi)
