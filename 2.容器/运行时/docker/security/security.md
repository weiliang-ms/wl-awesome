{% raw %}

- [容器安全](#%E5%AE%B9%E5%99%A8%E5%AE%89%E5%85%A8)
  - [2.`docker`守护进程配置](#2docker%E5%AE%88%E6%8A%A4%E8%BF%9B%E7%A8%8B%E9%85%8D%E7%BD%AE)
    - [2.6 使用默认`cgroup`](#26-%E4%BD%BF%E7%94%A8%E9%BB%98%E8%AE%A4cgroup)
    - [2.7 设置容器的默认空间大小](#27-%E8%AE%BE%E7%BD%AE%E5%AE%B9%E5%99%A8%E7%9A%84%E9%BB%98%E8%AE%A4%E7%A9%BA%E9%97%B4%E5%A4%A7%E5%B0%8F)
    - [2.8 启用`docker`客户端命令的授权](#28-%E5%90%AF%E7%94%A8docker%E5%AE%A2%E6%88%B7%E7%AB%AF%E5%91%BD%E4%BB%A4%E7%9A%84%E6%8E%88%E6%9D%83)
    - [2.9 配置集中和远程日志记录](#29-%E9%85%8D%E7%BD%AE%E9%9B%86%E4%B8%AD%E5%92%8C%E8%BF%9C%E7%A8%8B%E6%97%A5%E5%BF%97%E8%AE%B0%E5%BD%95)
    - [2.10 禁用旧仓库版本（v1）上的操作](#210-%E7%A6%81%E7%94%A8%E6%97%A7%E4%BB%93%E5%BA%93%E7%89%88%E6%9C%ACv1%E4%B8%8A%E7%9A%84%E6%93%8D%E4%BD%9C)
    - [2.11 启用实时恢复](#211-%E5%90%AF%E7%94%A8%E5%AE%9E%E6%97%B6%E6%81%A2%E5%A4%8D)
    - [2.12 禁用`userland`代理](#212-%E7%A6%81%E7%94%A8userland%E4%BB%A3%E7%90%86)
    - [2.13 应用守护进程范围的自定义`seccomp`配置文件](#213-%E5%BA%94%E7%94%A8%E5%AE%88%E6%8A%A4%E8%BF%9B%E7%A8%8B%E8%8C%83%E5%9B%B4%E7%9A%84%E8%87%AA%E5%AE%9A%E4%B9%89seccomp%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
    - [2.14 生产环境中避免实验性功能](#214-%E7%94%9F%E4%BA%A7%E7%8E%AF%E5%A2%83%E4%B8%AD%E9%81%BF%E5%85%8D%E5%AE%9E%E9%AA%8C%E6%80%A7%E5%8A%9F%E8%83%BD)
    - [2.15 限制容器获取新的权限](#215-%E9%99%90%E5%88%B6%E5%AE%B9%E5%99%A8%E8%8E%B7%E5%8F%96%E6%96%B0%E7%9A%84%E6%9D%83%E9%99%90)
  - [3.`docker`守护程序文件配置](#3docker%E5%AE%88%E6%8A%A4%E7%A8%8B%E5%BA%8F%E6%96%87%E4%BB%B6%E9%85%8D%E7%BD%AE)
    - [3.1 设置`docker`文件的所有权为`root:root`](#31-%E8%AE%BE%E7%BD%AEdocker%E6%96%87%E4%BB%B6%E7%9A%84%E6%89%80%E6%9C%89%E6%9D%83%E4%B8%BArootroot)
    - [3.2 设置`docker.service`文件权限为644或更多限制性](#32-%E8%AE%BE%E7%BD%AEdockerservice%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90%E4%B8%BA644%E6%88%96%E6%9B%B4%E5%A4%9A%E9%99%90%E5%88%B6%E6%80%A7)
    - [3.3 设置`docker.socket`文件的所有权为`root:root`](#33-%E8%AE%BE%E7%BD%AEdockersocket%E6%96%87%E4%BB%B6%E7%9A%84%E6%89%80%E6%9C%89%E6%9D%83%E4%B8%BArootroot)
    - [3.4 设置`docker.socket`文件权限为`644`或更多限制性](#34-%E8%AE%BE%E7%BD%AEdockersocket%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90%E4%B8%BA644%E6%88%96%E6%9B%B4%E5%A4%9A%E9%99%90%E5%88%B6%E6%80%A7)
    - [3.5 设置`/etc/docker`目录所有权为`root:root`](#35-%E8%AE%BE%E7%BD%AEetcdocker%E7%9B%AE%E5%BD%95%E6%89%80%E6%9C%89%E6%9D%83%E4%B8%BArootroot)
    - [3.6 设置`/etc/docker`目录权限为`755`或更多限制性](#36-%E8%AE%BE%E7%BD%AEetcdocker%E7%9B%AE%E5%BD%95%E6%9D%83%E9%99%90%E4%B8%BA755%E6%88%96%E6%9B%B4%E5%A4%9A%E9%99%90%E5%88%B6%E6%80%A7)
    - [3.7 设置仓库证书文件所有权为`root:root`](#37-%E8%AE%BE%E7%BD%AE%E4%BB%93%E5%BA%93%E8%AF%81%E4%B9%A6%E6%96%87%E4%BB%B6%E6%89%80%E6%9C%89%E6%9D%83%E4%B8%BArootroot)
    - [3.8 设置仓库证书文件权限为`444`或更多限制性](#38-%E8%AE%BE%E7%BD%AE%E4%BB%93%E5%BA%93%E8%AF%81%E4%B9%A6%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90%E4%B8%BA444%E6%88%96%E6%9B%B4%E5%A4%9A%E9%99%90%E5%88%B6%E6%80%A7)
    - [3.9 设置`TLS CA`证书文件所有权为`root:root`](#39-%E8%AE%BE%E7%BD%AEtls-ca%E8%AF%81%E4%B9%A6%E6%96%87%E4%BB%B6%E6%89%80%E6%9C%89%E6%9D%83%E4%B8%BArootroot)
    - [3.10 设置`TLS CA`证书文件权限为`444`或更多限制性](#310-%E8%AE%BE%E7%BD%AEtls-ca%E8%AF%81%E4%B9%A6%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90%E4%B8%BA444%E6%88%96%E6%9B%B4%E5%A4%9A%E9%99%90%E5%88%B6%E6%80%A7)
    - [3.11 设置`docker`服务器证书文件所有权为`root:root`](#311-%E8%AE%BE%E7%BD%AEdocker%E6%9C%8D%E5%8A%A1%E5%99%A8%E8%AF%81%E4%B9%A6%E6%96%87%E4%BB%B6%E6%89%80%E6%9C%89%E6%9D%83%E4%B8%BArootroot)
    - [3.12 设置`Docker`服务器证书文件权限为`400`或更多限制](#312-%E8%AE%BE%E7%BD%AEdocker%E6%9C%8D%E5%8A%A1%E5%99%A8%E8%AF%81%E4%B9%A6%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90%E4%B8%BA400%E6%88%96%E6%9B%B4%E5%A4%9A%E9%99%90%E5%88%B6)
    - [3.13 设置`docker.sock`文件所有权为`root:docker`](#313-%E8%AE%BE%E7%BD%AEdockersock%E6%96%87%E4%BB%B6%E6%89%80%E6%9C%89%E6%9D%83%E4%B8%BArootdocker)
    - [3.14 设置`docker.sock`文件权限为`660`或更多限制性](#314-%E8%AE%BE%E7%BD%AEdockersock%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90%E4%B8%BA660%E6%88%96%E6%9B%B4%E5%A4%9A%E9%99%90%E5%88%B6%E6%80%A7)
    - [3.15 设置`docker.json`文件所有权为`root:root`](#315-%E8%AE%BE%E7%BD%AEdockerjson%E6%96%87%E4%BB%B6%E6%89%80%E6%9C%89%E6%9D%83%E4%B8%BArootroot)
    - [3.16 设置`docker.json`文件权限为`644`或更多限制性](#316-%E8%AE%BE%E7%BD%AEdockerjson%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90%E4%B8%BA644%E6%88%96%E6%9B%B4%E5%A4%9A%E9%99%90%E5%88%B6%E6%80%A7)
  - [4.容器镜像和构建文件](#4%E5%AE%B9%E5%99%A8%E9%95%9C%E5%83%8F%E5%92%8C%E6%9E%84%E5%BB%BA%E6%96%87%E4%BB%B6)
    - [4.1 创建容器的用户](#41-%E5%88%9B%E5%BB%BA%E5%AE%B9%E5%99%A8%E7%9A%84%E7%94%A8%E6%88%B7)
    - [4.2 容器使用可信的基础镜像](#42-%E5%AE%B9%E5%99%A8%E4%BD%BF%E7%94%A8%E5%8F%AF%E4%BF%A1%E7%9A%84%E5%9F%BA%E7%A1%80%E9%95%9C%E5%83%8F)
    - [4.3 容器中不安装没有必要的软件包](#43-%E5%AE%B9%E5%99%A8%E4%B8%AD%E4%B8%8D%E5%AE%89%E8%A3%85%E6%B2%A1%E6%9C%89%E5%BF%85%E8%A6%81%E7%9A%84%E8%BD%AF%E4%BB%B6%E5%8C%85)
    - [4.4 扫描镜像漏洞并且构建包含安全补丁的镜像](#44-%E6%89%AB%E6%8F%8F%E9%95%9C%E5%83%8F%E6%BC%8F%E6%B4%9E%E5%B9%B6%E4%B8%94%E6%9E%84%E5%BB%BA%E5%8C%85%E5%90%AB%E5%AE%89%E5%85%A8%E8%A1%A5%E4%B8%81%E7%9A%84%E9%95%9C%E5%83%8F)
    - [4.5 启用`docker`内容信任](#45-%E5%90%AF%E7%94%A8docker%E5%86%85%E5%AE%B9%E4%BF%A1%E4%BB%BB)
    - [4.6 将`HEALTHCHECK`说明添加到容器镜像](#46-%E5%B0%86healthcheck%E8%AF%B4%E6%98%8E%E6%B7%BB%E5%8A%A0%E5%88%B0%E5%AE%B9%E5%99%A8%E9%95%9C%E5%83%8F)
    - [4.7 在`dockerfile`中使用`copy`而不是`add`](#47-%E5%9C%A8dockerfile%E4%B8%AD%E4%BD%BF%E7%94%A8copy%E8%80%8C%E4%B8%8D%E6%98%AFadd)
    - [4.8 涉密信息不存储在`dockerfile`](#48-%E6%B6%89%E5%AF%86%E4%BF%A1%E6%81%AF%E4%B8%8D%E5%AD%98%E5%82%A8%E5%9C%A8dockerfile)
    - [4.9 仅安装已经验证的软件包](#49-%E4%BB%85%E5%AE%89%E8%A3%85%E5%B7%B2%E7%BB%8F%E9%AA%8C%E8%AF%81%E7%9A%84%E8%BD%AF%E4%BB%B6%E5%8C%85)
    - [4.10 正确设置容器上的`CPU`优先级](#410-%E6%AD%A3%E7%A1%AE%E8%AE%BE%E7%BD%AE%E5%AE%B9%E5%99%A8%E4%B8%8A%E7%9A%84cpu%E4%BC%98%E5%85%88%E7%BA%A7)
    - [4.11 `Linux`内核功能在容器内受限](#411-linux%E5%86%85%E6%A0%B8%E5%8A%9F%E8%83%BD%E5%9C%A8%E5%AE%B9%E5%99%A8%E5%86%85%E5%8F%97%E9%99%90)
    - [4.12 不使用特权容器](#412-%E4%B8%8D%E4%BD%BF%E7%94%A8%E7%89%B9%E6%9D%83%E5%AE%B9%E5%99%A8)
    - [4.13 敏感的主机系统目录未挂载在容器上](#413-%E6%95%8F%E6%84%9F%E7%9A%84%E4%B8%BB%E6%9C%BA%E7%B3%BB%E7%BB%9F%E7%9B%AE%E5%BD%95%E6%9C%AA%E6%8C%82%E8%BD%BD%E5%9C%A8%E5%AE%B9%E5%99%A8%E4%B8%8A)
    - [4.14 `SSH`不在容器中运行](#414-ssh%E4%B8%8D%E5%9C%A8%E5%AE%B9%E5%99%A8%E4%B8%AD%E8%BF%90%E8%A1%8C)
    - [4.15 特权端口禁止映射到容器内](#415-%E7%89%B9%E6%9D%83%E7%AB%AF%E5%8F%A3%E7%A6%81%E6%AD%A2%E6%98%A0%E5%B0%84%E5%88%B0%E5%AE%B9%E5%99%A8%E5%86%85)
    - [4.16 只映射必要的端口](#416-%E5%8F%AA%E6%98%A0%E5%B0%84%E5%BF%85%E8%A6%81%E7%9A%84%E7%AB%AF%E5%8F%A3)
    - [4.17 确保容器的内存使用合理](#417-%E7%A1%AE%E4%BF%9D%E5%AE%B9%E5%99%A8%E7%9A%84%E5%86%85%E5%AD%98%E4%BD%BF%E7%94%A8%E5%90%88%E7%90%86)
    - [4.18 设置容器的根文件系统为只读](#418-%E8%AE%BE%E7%BD%AE%E5%AE%B9%E5%99%A8%E7%9A%84%E6%A0%B9%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E4%B8%BA%E5%8F%AA%E8%AF%BB)
    - [4.19 确保进入容器的流量绑定到特定的主机接口](#419-%E7%A1%AE%E4%BF%9D%E8%BF%9B%E5%85%A5%E5%AE%B9%E5%99%A8%E7%9A%84%E6%B5%81%E9%87%8F%E7%BB%91%E5%AE%9A%E5%88%B0%E7%89%B9%E5%AE%9A%E7%9A%84%E4%B8%BB%E6%9C%BA%E6%8E%A5%E5%8F%A3)
    - [4.20 容器重启策略`on-failure`设置为`5`](#420-%E5%AE%B9%E5%99%A8%E9%87%8D%E5%90%AF%E7%AD%96%E7%95%A5on-failure%E8%AE%BE%E7%BD%AE%E4%B8%BA5)
    - [4.21 确保主机的进程命名空间不共享](#421-%E7%A1%AE%E4%BF%9D%E4%B8%BB%E6%9C%BA%E7%9A%84%E8%BF%9B%E7%A8%8B%E5%91%BD%E5%90%8D%E7%A9%BA%E9%97%B4%E4%B8%8D%E5%85%B1%E4%BA%AB)
    - [4.22 主机的`IPC`命令空间不共享](#422-%E4%B8%BB%E6%9C%BA%E7%9A%84ipc%E5%91%BD%E4%BB%A4%E7%A9%BA%E9%97%B4%E4%B8%8D%E5%85%B1%E4%BA%AB)
    - [4.23 主机设备不直接共享给容器](#423-%E4%B8%BB%E6%9C%BA%E8%AE%BE%E5%A4%87%E4%B8%8D%E7%9B%B4%E6%8E%A5%E5%85%B1%E4%BA%AB%E7%BB%99%E5%AE%B9%E5%99%A8)
    - [4.24 设置装载传播模式不共享](#424-%E8%AE%BE%E7%BD%AE%E8%A3%85%E8%BD%BD%E4%BC%A0%E6%92%AD%E6%A8%A1%E5%BC%8F%E4%B8%8D%E5%85%B1%E4%BA%AB)
    - [4.25 设置主机的`UTS`命令空间不共享](#425-%E8%AE%BE%E7%BD%AE%E4%B8%BB%E6%9C%BA%E7%9A%84uts%E5%91%BD%E4%BB%A4%E7%A9%BA%E9%97%B4%E4%B8%8D%E5%85%B1%E4%BA%AB)
    - [4.26 `docker exec`命令不能使用特权选项](#426-docker-exec%E5%91%BD%E4%BB%A4%E4%B8%8D%E8%83%BD%E4%BD%BF%E7%94%A8%E7%89%B9%E6%9D%83%E9%80%89%E9%A1%B9)
    - [4.27 `docker exec`命令不能与`user`选项一起使用](#427-docker-exec%E5%91%BD%E4%BB%A4%E4%B8%8D%E8%83%BD%E4%B8%8Euser%E9%80%89%E9%A1%B9%E4%B8%80%E8%B5%B7%E4%BD%BF%E7%94%A8)
    - [4.28 检查容器运行时状态](#428-%E6%A3%80%E6%9F%A5%E5%AE%B9%E5%99%A8%E8%BF%90%E8%A1%8C%E6%97%B6%E7%8A%B6%E6%80%81)
    - [4.29 限制使用`PID cgroup`](#429-%E9%99%90%E5%88%B6%E4%BD%BF%E7%94%A8pid-cgroup)
    - [4.30 不要使用`Docker`的默认网桥`docker0`](#430-%E4%B8%8D%E8%A6%81%E4%BD%BF%E7%94%A8docker%E7%9A%84%E9%BB%98%E8%AE%A4%E7%BD%91%E6%A1%A5docker0)
    - [4.31 任何容器内不能安装`Docker`套接字](#431-%E4%BB%BB%E4%BD%95%E5%AE%B9%E5%99%A8%E5%86%85%E4%B8%8D%E8%83%BD%E5%AE%89%E8%A3%85docker%E5%A5%97%E6%8E%A5%E5%AD%97)
  - [5.`Docker`安全操作](#5docker%E5%AE%89%E5%85%A8%E6%93%8D%E4%BD%9C)
    - [5.1 避免镜像泛滥](#51-%E9%81%BF%E5%85%8D%E9%95%9C%E5%83%8F%E6%B3%9B%E6%BB%A5)
    - [5.2 避免容器泛滥](#52-%E9%81%BF%E5%85%8D%E5%AE%B9%E5%99%A8%E6%B3%9B%E6%BB%A5)
  - [最佳实践](#%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5)
    - [安装](#%E5%AE%89%E8%A3%85)
    - [配置](#%E9%85%8D%E7%BD%AE)
    - [文件权限调整](#%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90%E8%B0%83%E6%95%B4)
  - [参考文档](#%E5%8F%82%E8%80%83%E6%96%87%E6%A1%A3)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 容器安全

基于`Docker 19.03.8`

## 概述

云原生时代下，容器广受欢迎，因为它能简化应用或服务及其所有依赖项的构建、封装与推进，而且这种简化涵盖整个生命周期，并且跨越不同的环境和部署目标。
然而，容器安全依然面临着一些挑战。本文从几个角度切入，剖析容器加固常用方式方法。

在审查`Docker`安全性时，有四个主要方面需要考虑:

- 内核的内在安全性及其对名称空间和`cgroup`的支持
- `Docker`守护进程本身的攻击面
- 容器配置文件中的漏洞，要么是默认的，要么是用户自定义的
- 内核的`强化`安全特性以及它们如何与容器交互

## 1 主机安全配置

## 2.`docker`守护进程配置





### 2.6 使用默认`cgroup`

- 描述

查看`--cgroup-parent`选项允许设置用于所有容器的默认`cgroup parent`。 如果没有特定用例,则该设置应保留默认值。

- 隐患分析

系统管理员可定义容器应运行的`cgroup`。 若系统管理员没有明确定义`cgroup`，容器也会在`docker cgroup`下运行。
应该监测和确认使用情况。通过加到与默认不同的`cgroup`，导致不合理地共享资源，从而可能会主机资源耗尽

- 审计方式

```bash
ps -ef|grep dockerd
```

确保`--cgroup-parent`参数未设置或设置为适当的非默认`cgroup`

- 修复建议

如无特殊需求，默认值即可

### 2.7 设置容器的默认空间大小

- 描述

在某些情况下，可能需要大于`10G`（容器默认存储大小）的容器空间。需要仔细选择空间的大小

- 隐患分析

守护进程重启时可以增加容器空间的大小。用户可以通过设置默认容器空间值来进行扩大，但不允许缩小。
设立该值的时候需要谨慎，防止设置不当带来空间耗尽的情况

- 审计方式

```bash
ps -ef|grep dockerd
```

执行上述命令，它不应显示任何`--storage-opt dm.basesize`参数

- 修复建议

如无特殊需求，默认值即可

### 2.8 启用`docker`客户端命令的授权

- 描述

使用本机`Docker`授权插件或第三方授权机制与`Docker`守护程序来管理对`Docker`客户端命令的访问。

- 隐患分析

`Docker`默认是没有对客户端命令进行授权管理的功能。
任何有权访问`Docker`守护程序的用户都可以运行任何`Docker`客户端命令。
对于使用`Docker`远程`API`来调用守护进程的调用者也是如此。
如果需要细粒度的访问控制，可以使用授权插件并将其添加到`Docker`守护程序配置中。
使用授权插件，`Docker`管理员可以配置更细粒度访问策略来管理对`Docker`守护进程的访问。
`Docker`的第三方集成可以实现他们自己的授权模型，以要求`Docker`的本地授权插件
（即`Kubernetes`，`Cloud Foundry`，`Openshift`）之外的`Docker`守护进程的授权。

- 审计方式

```bash
ps -ef|grep dockerd
或
cat /etc/docker/daemon.json|grep userland-proxy
```

如果使用`Docker`本地授权，可使用`--authorization-plugin`参数加载授权插件。

- 修复建议

如无特殊需求，默认值即可

### 2.9 配置集中和远程日志记录

- 描述

`Docker`现在支持各种日志驱动程序。存储日志的最佳方式是支持集中式和远程日志记录

- 审计方式

运行`docker info`并确保日志记录驱动程序属性被设置为适当的。

```bash
[root@localhost ~]# docker info --format '{{.LoggingDriver}}'
json-file
```

- 修复建议

> 配置`json-file`驱动

```bash
[root@localhost ~]# cat /etc/docker/daemon.json
{
     "log-driver":"json-file",
     "log-opts":{
         "max-size":"50m",
         "max-file":"3"
     }
}
```

> 重启

```bash
systemctl daemon-reload
systemctl restart docker
```

### 2.10 禁用旧仓库版本（v1）上的操作

- 描述

最新的`Docker`镜像仓库是`v2`。遗留镜像仓库版本`v1`上的所有操作都应受到限制

- 隐患分析

`Docker`镜像仓库`v2`在`v1`中引入了许多性能和安全性改进。
它支持容器镜像来源验证和其他安全功能。因此，对`Docker v1`仓库的操作应该受到限制

- 审计方式

```bash
ps -ef|grep dockerd
```

上面的命令应该列出`--disable-legacy-registry`作为传递给`Docker`守护进程的选项。

- 修复建议

**注意：**`17.12+`版本已移除，无需配置

> 编辑配置文件

```bash
vi /etc/systemd/system/docker.service
```

`ExecStart=/usr/bin/dockerd`添加参数`--userns-remap=default`

> 重载服务

```bash
systemctl daemon-reload
systemctl restart docker
```

### 2.11 启用实时恢复

- 描述

`live-restore`参数可以支持无守护程序的容器运行。
它确保`Docker`在关闭或恢复时不会停止容器，并在重新启动后重新连接到容器。

- 隐患分析

可用性作为安全一个重要的属性。 在`Docker`守护进程中设置`--live-restore`标志可确保当`Docker`守护进程不可用时容器执行不会中断。 
这也意味着当更新和修复`Docker`守护进程而不会导致容器停止工作。

- 审计方式

```bash
[root@localhost ~]# docker info --format '{{.LiveRestoreEnabled}}'
false
```

- 修复建议

> 编辑文件

```bash
mkdir -p /etc/docker/
vi /etc/docker/daemon.json
```

添加如下内容

```
"live-restore": true
```

> 重载服务

```bash
systemctl daemon-reload
systemctl restart docker
```

### 2.12 禁用`userland`代理 

- 描述

当容器端口需要被映射时，`Docker`守护进程都会启动用于端口转发的`userland-proxy`方式。如果使用了`DNAT`方式，该功能可以被禁用

- 隐患分析

`Docker`引擎提供了两种机制将主机端口转发到容器,`DNAT`和`userland-proxy`。
在大多数情况下，`DNAT`模式是首选，因为它提高了性能，并使用本地`Linux iptables`功能而需要附加组件。
如果`DNAT`可用，则应在启动时禁用`userland-proxy`以减少安全风险。

- 审计方法

```bash
ps -ef|grep dockerd
或
cat /etc/docker/daemon.json|grep userland-proxy
```

确保`userland-proxy`配置为`false`

- 修复建议

> 编辑文件

```bash
mkdir -p /etc/docker/
vi /etc/docker/daemon.json
```

添加如下内容

```
"userland-proxy": false,
```

> 重载服务

```bash
systemctl daemon-reload
systemctl restart docker
```

### 2.13 应用守护进程范围的自定义`seccomp`配置文件

- 描述

如果需要，您可以选择在守护进程级别自定义`seccomp`配置文件，并覆盖`Docker`的默认`seccomp`配置文件

- 隐患分析

大量系统调用暴露于每个用户级进程，其中许多系统调用在整个生命周期中都未被使用。
大多数应用程序不需要所有的系统调用，因此可以通过减少可用的系统调用来增加安全性。
可自定义`seccomp`配置文件，而不是使用`Docker`的默认`seccomp`配置文件。
如果`Docker`的默认配置文件够用的话，则可以选择忽略此建议

- 审计

```bash
[root@localhost ~]# docker info --format '{{.SecurityOptions}}'
```

- 修复建议

错误配置的`seccomp`配置文件可能会中断的容器运行。`Docker`默认的策略兼容性很好，可以解决一些基本的安全问题。
所以，在[重写默认值](https://docs.docker.com/engine/security/seccomp/) 时，你应该非常小心

### 2.14 生产环境中避免实验性功能

- 描述

避免生产环境中的实验性功`-Experimental`

- 隐患分析

`Docker`实验功能现在是一个运行时`Docker`守护进程标志, 
其作为运行时标志传递给`Docker`守护进程，激活实验性功能。
实验性功能现在虽然比较稳定，但是一些功能可能没有大规模经使用，并不能保证`API`的稳定性，所以不建议在生产环境中使用

- 审计方法

```bash
[root@localhost ~]# docker version --format '{{.Server.Experimental}}'
false
```

- 修复建议

不要将`--Experimental`作为运行时参数传递给`Docker`守护进程

### 2.15 限制容器获取新的权限

- 描述

默认情况下，限制容器通过`suid`或`sgid`位获取附加权限

- 隐患分析

一个进程可以在内核中设置`no_new_priv`。 它支持`fork`，`clone`和`execve`。
`no_new_priv`确保进程或其子进程不会通过`suid`或`sgid`位获得任何其他特权。
这样，很多危险的操作就降低安全风险。在守护程序级别进行设置可确保默认情况下，所有新容器不能获取新的权限。

- 审计方法

```bash
ps -ef|grep dockerd
或
cat /etc/docker/daemon.json|grep no-new-privileges
```

确保`no-new-privileges`配置为`false`

- 修复建议

> 编辑文件

```bash
mkdir -p /etc/docker/
vi /etc/docker/daemon.json
```

添加如下内容

```
"no-new-privileges": false
```

> 重载服务

```bash
systemctl daemon-reload
systemctl restart docker
```

## 3.`docker`守护程序文件配置

### 3.1 设置`docker`文件的所有权为`root:root`

- 描述

- 隐患分析

`docker.service`文件包含可能会改变`Docker`守护进程行为的敏感参数。
因此，它应该由`root`拥有和归属，以保持文件的完整性。

- 审计方式

```bash
systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 ls -l
```

返回值应为

```
-rw-r--r-- 1 root root 1157 Apr 26 08:04 /etc/systemd/system/docker.service
```

- 修复建议

若所属用户非`root:root`，修改授权
```bash
systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 chown root:root
```

### 3.2 设置`docker.service`文件权限为644或更多限制性

- 描述

验证`docker.service`文件权限是否正确设置为`644`或更多限制

- 隐患分析

`docker.service`文件包含可能会改变`Docker`守护进程行为的敏感参数。
因此，它应该由`root`拥有和归属，以保持文件的完整性。

- 审计方式

```bash
[root@localhost ~]# systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 stat -c %a
644
```

- 修复建议

若权限非`644`，修改授权
```bash
systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 chmod 644
```

### 3.3 设置`docker.socket`文件的所有权为`root:root`

- 描述

验证`docker.socket`文件所有权和组所有权是否正确设置为`root`

- 隐患分析

`docker.socket`文件包含可能会改变`Docker`远程`API`行为的敏感参数。
因此，它应该拥有`root`权限，以保持文件的完整性。

- 审计方式

```bash
systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 ls -l
```

返回值应为

```
-rw-r--r-- 1 root root 197 Mar 10  2020 /usr/lib/systemd/system/docker.socket
```

- 修复建议

若所属用户非`root:root`，修改授权
```bash
systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 chown root:root
```

### 3.4 设置`docker.socket`文件权限为`644`或更多限制性

- 描述

验证`docker.socket`文件权限是否正确设置为`644`或更多限制

- 隐患分析

`docker.socket`文件包含可能会改变`Docker`远程`API`行为的敏感参数。
因此，它应该拥有`root`权限，以保持文件的完整性。

- 审计方式

```bash
[root@localhost ~]# systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 stat -c %a
644
```

- 修复建议

若权限非`644`，修改授权
```bash
systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 chmod 644
```

### 3.5 设置`/etc/docker`目录所有权为`root:root`

- 描述

验证`/etc/docker`目录所有权和组所有权是否正确设置为`root:root`

- 隐患分析

除了各种敏感文件之外，`/etc/docker`目录还包含证书和密钥。 
因此，它应该由`root:root`拥有和归组来维护目录的完整性。

- 审计方式

```bash
[root@localhost ~]# stat -c %U:%G /etc/docker
root:root
```

- 修复建议

若所属用户非`root:root`，修改授权
```bash
chown root:root /etc/docker
```

### 3.6 设置`/etc/docker`目录权限为`755`或更多限制性

- 描述

验证`/etc/docker`目录权限是否正确设置为`755`

- 隐患分析

除了各种敏感文件之外，`/etc/docker`目录还包含证书和密钥。 
因此，它应该由`root:root`拥有和归组来维护目录的完整性。

- 审计方式

```bash
[root@localhost ~]# stat -c %a /etc/docker
755
```

- 修复建议

若所属用户非`root:root`，修改授权
```bash
chmod 755 /etc/docker
```

### 3.7 设置仓库证书文件所有权为`root:root`

- 描述

验证所有仓库证书文件（通常位于`/etc/docker/certs.d/<registry-name>` 目录下）均由`root`拥有并归组所有

- 隐患分析

`/etc/docker/certs.d/<registry-name>`目录包含`Docker`镜像仓库证书。
这些证书文件必须由`root`和其组拥有，以维护证书的完整性

- 审计方式

```bash
[root@localhost ~]# stat -c %U:%G /etc/docker/certs.d/* 
root:root
```

- 修复建议

若所属用户非`root:root`，修改授权
```bash
chown root:root /etc/docker/certs.d/*
```

### 3.8 设置仓库证书文件权限为`444`或更多限制性 

- 描述

验证所有仓库证书文件（通常位于`/etc/docker/certs.d/<registry-name>` 目录下）所有权限是否正确设置为`444`

- 隐患分析

`/etc/docker/certs.d/<registry-name>`目录包含`Docker`镜像仓库证书。
这些证书文件必须具有`444`权限，以维护证书的完整性。

- 审计方式

```bash
[root@localhost ~]# stat -c %a /etc/docker/certs.d/*
755
```

- 修复建议

若权限非`444`，修改授权
```bash
chmod 444 /etc/docker/certs.d/*
```

### 3.9 设置`TLS CA`证书文件所有权为`root:root`

- 描述

验证`TLS CA`证书文件均由`root`拥有并归组所有

- 隐患分析

`TLS CA`证书文件应受到保护，不受任何篡改。它用于指定的`CA`证书验证。
因此，它必须由`root`拥有，以维护`CA`证书的完整性。

- 审计方式

```bash
[root@localhost ~]# ls /etc/docker/certs.d/*/* |xargs -n1 stat -c %U:%G
root:root
root:root
root:root
```

- 修复建议

若所属用户非`root:root`，修改授权
```bash
chown root:root /etc/docker/certs.d/*/*
```

### 3.10 设置`TLS CA`证书文件权限为`444`或更多限制性

- 描述

验证所有仓库证书文件（通常位于`/etc/docker/certs.d/<registry-name>` 目录下）所有权限是否正确设置为`444`

- 隐患分析

`TLS CA`证书文件应受到保护，不受任何篡改。它用于指定的`CA`证书验证。
这些证书文件必须具有`444`权限，以维护证书的完整性。

- 审计方式

```bash
[root@localhost ~]# stat -c %a /etc/docker/certs.d/*/*
644
644
644
```

- 修复建议

若权限非`444`，修改授权
```bash
chmod 444 /etc/docker/certs.d/*/*
```

### 3.11 设置`docker`服务器证书文件所有权为`root:root`

- 描述

验证`Docker`服务器证书文件（与`--tlscert`参数一起传递的文件）是否由`root`和其组拥有

- 隐患分析

`Docker`服务器证书文件应受到保护，不受任何篡改。它用于验证`Docker`服务器。
因此，它必须由`root`拥有以维护证书的完整性。

- 审计方式

**注意:** `/root/docker`替换为docker服务端实际证书存放目录

```bash
[root@localhost ~]# ls -l /root/docker
total 44
-rw-r--r-- 1 root root 3326 Apr 26 02:55 ca-key.pem
-rw-r--r-- 1 root root 1980 Apr 26 02:56 ca.pem
-rw-r--r-- 1 root root   17 Apr 26 02:57 ca.srl
-rw-r--r-- 1 root root 1801 Apr 26 02:57 cert.pem
-rw-r--r-- 1 root root 1582 Apr 26 02:57 client.csr
-rw-r--r-- 1 root root   30 Apr 26 02:57 extfile-client.cnf
-rw-r--r-- 1 root root   86 Apr 26 02:56 extfile.cnf
-rw-r--r-- 1 root root 3243 Apr 26 02:57 key.pem
-rw-r--r-- 1 root root 1862 Apr 26 02:56 server-cert.pem
-rw-r--r-- 1 root root 1594 Apr 26 02:56 server.csr
-rw-r--r-- 1 root root 3243 Apr 26 02:56 server-key.pem

```

- 修复建议

若所属用户非`root:root`，修改授权
```bash
chown root:root /root/docker/*
```

### 3.12 设置`Docker`服务器证书文件权限为`400`或更多限制

- 描述

验证`Docker`服务器证书文件（与`--tlscert`参数一起传递的文件）权限是否为`400`

- 隐患分析

`Docker`服务器证书文件应受到保护，不受任何篡改。它用于验证`Docker`服务器。
因此，它必须由`root`拥有以维护证书的完整性。

- 审计方式

**注意:** `/root/docker`替换为docker服务端实际证书存放目录

```bash
[root@localhost ~]# ls -l /root/docker
total 44
-rw-r--r-- 1 root root 3326 Apr 26 02:55 ca-key.pem
-rw-r--r-- 1 root root 1980 Apr 26 02:56 ca.pem
-rw-r--r-- 1 root root   17 Apr 26 02:57 ca.srl
-rw-r--r-- 1 root root 1801 Apr 26 02:57 cert.pem
-rw-r--r-- 1 root root 1582 Apr 26 02:57 client.csr
-rw-r--r-- 1 root root   30 Apr 26 02:57 extfile-client.cnf
-rw-r--r-- 1 root root   86 Apr 26 02:56 extfile.cnf
-rw-r--r-- 1 root root 3243 Apr 26 02:57 key.pem
-rw-r--r-- 1 root root 1862 Apr 26 02:56 server-cert.pem
-rw-r--r-- 1 root root 1594 Apr 26 02:56 server.csr
-rw-r--r-- 1 root root 3243 Apr 26 02:56 server-key.pem

```

- 修复建议

若权限非`400`，修改授权
```bash
chmod 400 /root/docker/*
```

### 3.13 设置`docker.sock`文件所有权为`root:docker`

- 描述

验证`docker.sock`文件由`root`拥有，而用户组为`docker`。

- 隐患分析

`Docker`守护进程以`root`用户身份运行。 因此，默认的`Unix`套接字必须由`root`拥有。 
如果任何其他用户或进程拥有此套接字，那么该非特权用户或进程可能与`Docker`守护进程交互。
另外，这样的非特权用户或进程可能与容器交互，这样非常不安全。
另外，`Docker`安装程序会创建一个名为`docker`的用户组。
可以将用户添加到该组，然后这些用户将能够读写默认的`Docker Unix`套接字。
`docker`组成员由系统管理员严格控制。 如果任何其他组拥有此套接字，那么该组的成员可能会与`Docker`守护进程交互。。
因此，默认的`Docker Unix`套接字文件必须由`docker`组拥有权限，以维护套接字文件的完整性

- 审计

```bash
[root@localhost ~]# stat -c %U:%G /var/run/docker.sock
root:docker
```

- 修复建议

若所属用户非`root:docker`，修改授权
```bash
chown root:docker /var/run/docker.sock
```

### 3.14 设置`docker.sock`文件权限为`660`或更多限制性

- 描述

验证`docker`套接字文件是否具有`660`或更多限制的权限

- 隐患分析

只有`root`和`docker`组的成员允许读取和写入默认的`Docker Unix`套接字。
因此，`Docker`套接字文件必须具有`660`或更多限制的权限

- 审计

```bash
[root@localhost ~]# stat -c %a /var/run/docker.sock
660
```

- 修复建议

若权限非`660`，修改授权
```bash
chmod 660 /var/run/docker.sock
```

### 3.15 设置`docker.json`文件所有权为`root:root` 

- 描述

验证`docker.json`文件由`root`归属。

- 隐患分析

`docker.json`文件包含可能会改变`Docker`守护程序行为的敏感参数。
因此，它应该由`root`拥有，以维护文件的完整性

- 审计

```bash
[root@localhost ~]# stat -c %U:%G /etc/docker/daemon.json
root:root
```

- 修复建议

若所属用户非`root:root`，修改授权
```bash
chown root:root /etc/docker/daemon.json
```

### 3.16 设置`docker.json`文件权限为`644`或更多限制性

- 描述

验证`docker.json`文件权限是否正确设置为`644`或更多限制

- 隐患分析

`docker.json`文件包含可能会改变`Docker`守护程序行为的敏感参数。
因此，它应该由`root`拥有，以维护文件的完整性

- 审计方式

```bash
[root@localhost ~]# stat -c %a /etc/docker/daemon.json
644
```

- 修复建议

若权限非`644`，修改授权
```bash
chmod 644 /etc/docker/daemon.json
```

## 4.容器镜像和构建文件

### 4.1 创建容器的用户

- 描述

为容器镜像的`Dockerfile`中的容器创建非`root`用户

- 隐患分析

如果可能，指定非`root`用户身份运行容器是个很好的做法。
虽然用户命名空间映射可用，但是如果用户在容器镜像中指定了用户，则默认情况下容器将作为该用户运行，并且不需要特定的用户命名空间重新映射。

- 审计方式

```bash
[root@localhost ~]# docker ps |grep ccc|awk '{print $1}'|xargs -n1 docker inspect --format='{{.Id}}:User={{.Config.User}}'
4e53c86daf89a1bac0ed178d043663d2af162ca813ff17864ebdb964d8233459:User=
```

上述命令应该返回容器用户名或用户`ID`。 如果为空，则表示容器以`root`身份运行

- 修复建议

确保容器镜像的`Dockerfile`包含以下指令：`USER <用户名或 ID>`
其中用户名或`ID`是指可以在容器基础镜像中找到的用户。 如果在容器基础镜像中没有创建特定用户，则在`USER`指令之前添加`useradd`命令以添加特定用户。
例如，在`Dockerfile`中创建用户：
```
RUN useradd -d /home/username -m -s /bin/bash username USER username
```

**注意:** 如果镜像中有容器不需要的用户，请考虑删除它们。
删除这些用户后，提交镜像，然后生成新的容器实例以供使用。

### 4.2 容器使用可信的基础镜像

- 描述

确保容器镜像是从头开始编写的，或者是基于通过安全仓库下载的另一个已建立且可信的基本镜像

- 隐患分析

官方存储库是由`Docker`社区或供应商优化的`Docker`镜像。
可能还存在其他不安全的公共存储库。 在从`Docker`和第三方获取容器镜像时，需谨慎使用。

- 审计方式

> 1.检查`Docker`主机以查看执行以下命令使用的`Docker`镜像：

```bash
docker images
```

这将列出当前可用于`Docker`主机的所有容器镜像。
访谈系统管理员并获取证据，证明镜像列表是通过安全的镜像仓库获到的，也可简单的从镜像的`TAG`名称来判断是否为可信镜像。

> 2.检查镜像信息

对于在`Docker`主机上找到的每个`Docker`镜像，检查镜像的构建方式，以验证是否来自可信来源：

```bash
docker history  <imageName>
```

- 修复建议

    - 中间件等应用使用官方镜像
    - 构建镜像时选用`alpine`、`CentOS`等官方镜像
 
从源头杜绝不安全镜像

### 4.3 容器中不安装没有必要的软件包

- 描述

容器往往是操作系统的最简的版本，不要安装任何不需要的软件。

- 隐患分析

安装不必要的软件可能会增加容器的攻击风险。因此，除了容器的真正需要的软件之外，不要安装其他多余的软件。

- 审计方式

> 1.通过执行以下命令列出所有运行的容器实例：

```bash
docker ps
```
> 对于每个容器实例，执行以下或等效的命令

```bash
docker exec <container-id> rpm -qa
```

`rpm -qa`命令可根据容器镜像系统类型进行相应变更

- 修复建议

    - 中间件等应用使用官方镜像
    - 构建镜像时选用`alpine`、`CentOS`等官方精简后的镜像

从源头杜绝安装没有必要的软件包

### 4.4 扫描镜像漏洞并且构建包含安全补丁的镜像

- 描述

应该经常扫描镜像以查找漏洞。重建镜像安装最新的补丁。

- 隐患分析

安全补丁可以解决软件的安全问题。可以使用镜像漏洞扫描工具来查找镜像中的任何类型的漏洞，然后检查可用的补丁以减轻这些漏洞。
修补程序将系统更新到最新的代码库。此外，如果镜像漏洞扫描工具可以执行二进制级别分析，而不仅仅是版本字符串匹配，则会更好

- 审计方式

> 1.通过执行以下命令列出所有运行的容器实例

```bash
docker ps --quiet
```
> 2.对于每个容器实例，执行下面的或等效的命令来查找容器中安装的包的列表,确保安装各种受影响软件包的安全更新。 

```bash
docker exec <container-id> rpm -qa
```

- 修复建议

定期更新基础镜像版本`tag`（或使用`latest`版本镜像，每日执行构建）及镜像内必须软件版本

### 4.5 启用`docker`内容信任

- 描述

默认情况下禁用内容信任，为了安全起见，可以启用

- 隐患分析

内容信任为向远程`Docker`镜像仓库发开和接收的数据提供了使用数字签名的能力。
这些签名允许客户端验证特定镜像标签的完整性和发布者。这确保了容器镜像的来源的合法性。

- 审计方式

### 4.6 将`HEALTHCHECK`说明添加到容器镜像

- 描述

在`Docker`容器镜像中添加`HEALTHCHECK`指令以对正在运行的容器执行运行状况检查。

- 安全出发点

安全性最重要的一个特性就是可用性。将`HEALTHCHECK`指令添加到容器镜像可确保`Docker`引擎定期检查运行的容器实例是否符合该指令，
以确保实例仍在运行。根据报告的健康状况，`Docker`引擎可以退出非工作容器并实例化新容器。

- 审计

运行以下命令，并确保`Docker`镜像对`HEALTHCHECK`指令设置

```bash
[root@localhost ~]# docker inspect --format='{{.Config.Healthcheck}}' 8a2fb25a19f5
<nil>
```

应当返回设置值而非`nil`

- 修复建议

按照`Docker`文档，并使用`HEALTHCHECK`指令重建容器镜像。

### 4.7 在`dockerfile`中使用`copy`而不是`add` 

- 描述

在`Dockerfile`中使用`COPY`指令而不是`ADD`指令

- 隐患分析

`COPY`指令只是将文件从本地主机复制到容器文件系统。
`ADD`指令可能会从远程`URL`下载文件并执行诸如解包等操作。
因此，`ADD`指令增加了从`URL`添加恶意文件的风险

- 审计

步骤 1：运行以下命令获取镜像列表

```bash
docker images
```

步骤 2：对上述列表中的每个镜像执行以下命令，并查找任何`ADD`指令：

```
for i in `docker images --quiet`;do
docker history $i |grep ADD > /dev/null
if [ $? -eq 0 ];then
    echo "imageID: $i has 'ADD' direct..."
fi
done
```

- 修复建议

在`Dockerfile`中使用`COPY`指令

### 4.8 涉密信息不存储在`dockerfile`

- 描述

不要在`Dockerfile`中存储任何涉密信息

- 隐患分析

通过使用`Docker`历史命令，可以查看各种工具和实用程序。
通常情况，镜像发布者提供`Dockerfile`来构建镜像。所以，`Dockerfile`中的涉密信息可能会被暴露并被恶意利用。

- 审计方式

第 1 步：运行以下命令以获取镜像列表：

```bash
docker images
```
第 2 步：对上面列表中的每个镜像运行以下命令，并查找是否有涉密信息：

```bash
docker history <imageID>
```

如果有权访问镜像的`Dockerfile`，请确认没有涉密信息（不应该有涉密的信息，如用户账号，私钥证书等。）

- 修复建议

不要在`Dockerfile`中存储任何类型的涉密信息

### 4.9 仅安装已经验证的软件包

- 描述

在将软件包安装到镜像中之前，验证软件包可靠性

- 隐患分析

验证软件包的可靠性对于构建安全的容器镜像至关重要。不合法的软件包可能具有恶意或者存在一些可能被利用的已知漏洞

- 审计方式

第 1 步：运行以下命令以获取镜像列表：

```bash
docker images
```

第 2 步：对上面列表中的每个镜像运行以下命令，并查看软件包的合法性

```bash
docker history <imageID>
```

若可以访问镜像的`Dockerfile`，请验证是否检查了软件包的合法性

- 修复建议

使用`GPG`密钥下载和验证您所选择的软件包或任何其他安全软件包分发机制

### 4.10 正确设置容器上的`CPU`优先级

- 描述

默认情况下，`Docker`主机上的所有容器均可共享资源。通过使用`Docker`主机的资源管理功能（如`CPU`共享），可以控制容器可能占用的主机`CPU`资源

- 隐患分析

默认情况下`CPU`时间在容器间平均分配。 如果需要，为了控制容器实例之间的`CPU`时间，可以使用`CPU`共享功能。
`CPU`共享允许将一个容器优先于另一个容器，并禁止较低优先级的容器更频繁占用`CPU`资源。可确保高优先级的容器更好地运行

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:CpuShares={{.HostConfig.CpuShares}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:CpuShares=0
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:CpuShares=0
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:CpuShares=0
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:CpuShares=0
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:CpuShares=0
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:CpuShares=0
```

如果上述命令返回`0`或`1024`，则表示`CPU`无限制。
如果上述命令返回非`1024`值以外的非零值，则表示`CPU`已经限制。

- 修复建议

管理容器之间的`CPU`份额。为此，请使用`--cpu-shares`参数启动容器

### 4.11 `Linux`内核功能在容器内受限

- 描述

默认情况下，`Docker`使用一组受限制的`Linux`内核功能启动容器。
这意味着可以将任何进程授予所需的功能，而不是`root`访问。
使用`Linux`内核功能，这些进程不必以`root`用户身份运行。

- 隐患分析

`Docker`支持添加和删除功能，允许使用非默认配置文件。
这可能会使`Docker`通过移除功能更加安全，或者通过增加功能来减少安全性。
因此，建议除去容器进程明确要求的所有功能。
例如，容器进程通常不需要如下所示的功能：`NET_ADMIN`、`SYS_ADMIN`、 `SYS_MODULE`

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet |xargs docker inspect --format '{{.Id}}:CapAdd={{.HostConfig.CapAdd}} CapDrop={{.HostConfig.CapDrop}}'
7121e891641679fda571e67a0e9953d263feca2508b013c70ae2546f6336b1a0:CapAdd=<no value> CapDrop=<no value>
bb3875c107daa062f2eccb10bd48ad54954cecd7d51a5eba385335f377b7aae9:CapAdd=<no value> CapDrop=<no value>
7a3a2c9e524a9d44ae857abd52447f86940dd49e1947291e7985b98e3c6a309a:CapAdd=<no value> CapDrop=<no value>
0780c27f8eb858e172e6a7458d2b2221130e6dde0f64887d396ad5bc350a4a64:CapAdd=<no value> CapDrop=<no value>
```

验证添加和删除的`Linux`内核功能是否符合每个容器实例的容器进程所需的功能

- 修复建议

只添加必须功能特性

```bash
docker run -dit --cap-drop=all --cap-add={"NET_ADMIN", "SYS_ADMIN"} centos /bin/bash
```

默认情况下，以下功能可用于容器:

`AUDIT_WRITE`、`CHOWN`、`DAC_OVERRIDE`、`FOWNER`、`FSETID`、`KILL`、`MKNOD`、`NET_BIND_SERVICE`、`NET_RAW`、
`SETFCAP`、`SETGID`、`SETPCAP`、`SETUID`、`SYS_CHROOT`

> Linux kernel capabilities机制介绍

默认情况下，`Docker`启动具有一组受限功能的容器。

`capabilities`机制将二进制`root/no-root`二分法转换为细粒度的访问控制系统。
只需要绑定`1024`以下端口的进程(比如`web`服务器)不需要以`root`身份运行:它们只需要被授予`net_bind_service`能力即可。
对于通常需要根特权的几乎所有特定领域，还有许多其他功能。

典型的服务器以`root`身份运行多个进程，包括`SSH`守护进程、`cron`守护进程、日志守护进程、内核模块、网络配置工具等。
容器是不同的，因为几乎所有这些任务都由容器周围的基础设施处理:

- `SSH`访问通常由运行在`Docker`宿主机管理
- 必要时，`cron`应该作为一个用户进程运行，专门为需要调度服务的应用程序定制，而不是作为一个平台范围的工具
- 日志管理通常也交给`Docker`，或者像`Loggly`或`Splunk`这样的第三方服务
- 硬件管理是不相关的，这意味着您永远不需要在容器中运行`udevd`或等效的守护进程
- 网络管理也都在宿主机上设置，除非特殊需求。这意味着容器不需要执行`ifconfig`、`route`或`ip`命令（当然，除非容器被专门设计成路由器或防火墙）


这意味这大部分情况下，容器完全不需要真正的`root`权限。因此，容器可以运行一个减少的`capabilities`集，容器中的`root`也比真正的`root`拥有更少的`capabilities`,比如：

- 完全禁止任何`mount`操作
- 禁止访问络`socket`
- 禁止访问一些文件系统的操作，比如创建新的设备`node`等等
- 禁止模块加载

这意味这就算攻击者在容器中取得了`root`权限，也很难造成严重破坏

这不会影响到普通的`web`应用程序，但会大大减少恶意用户的攻击。默认情况下，`Docker`会删除所有需要的功能，使用`allowlist`而不是`denylist`方法

运行`Docker`容器的一个主要风险是，给容器的默认功能集和挂载可能会提供不完全的隔离

`Docker`支持添加和删除`capabilities`功能，允许使用非默认配置文件。这可能会使`Docker`通过删除功能而变得更安全，或者通过增加功能而变得更不安全。对于用户来说，最佳实践是删除除其流程显式需要的功能之外的所有功能

**简言之：`Linux Kernel capabilities`提供更细粒度的`root`权限控制**

### 4.12 不使用特权容器

- 描述

使用`--privileged`标志将所有`Linux`内核功能提供给容器，从而覆盖`-cap-add`和`-cap-drop`标志。若无必须请不要使用

- 隐患分析

`--privileged`标志给容器提供所有功能,并且还提升了`cgroup`控制器执行的所有限制。
换句话说，容器可以做几乎主机可以做的一切。这个标志存在允许特殊用例,就像在`Docker`中运行`Docker`一样

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet |xargs docker inspect --format '{{.Id}}:Privileged={{.HostConfig.Privileged}}'
7121e891641679fda571e67a0e9953d263feca2508b013c70ae2546f6336b1a0:Privileged=false
bb3875c107daa062f2eccb10bd48ad54954cecd7d51a5eba385335f377b7aae9:Privileged=false
7a3a2c9e524a9d44ae857abd52447f86940dd49e1947291e7985b98e3c6a309a:Privileged=false
0780c27f8eb858e172e6a7458d2b2221130e6dde0f64887d396ad5bc350a4a64:Privileged=false
```

确保`Privileged`为`false`

- 修复措施

不要运行带有`--privileged`标志的容器。例如，不要启动如下容器：

```bash
docker run -idt --privileged centos /bin/bash
```

### 4.13 敏感的主机系统目录未挂载在容器上

- 描述

不应允许将敏感的主机系统目录（如下所示）作为容器卷进行挂载，特别是在读写模式下。

```bash
boot dev etc lib lib64 proc run sbin sys usr var
```

- 隐患分析

如果敏感目录以读写方式挂载，则可以对这些敏感目录中的文件进行更改。
这些更改可能会降低安全性，且直接影响`Docker`宿主机

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet |xargs docker inspect --format '{{.Id}}:Volumes={{.Mounts}}'
7121e891641679fda571e67a0e9953d263feca2508b013c70ae2546f6336b1a0:Volumes=[map[Destination:/config Driver:local Mode: Name:800e943d52c78312b2d6dd53bed41999fd5f7780af5098f688a894fb74f4360f Propagation: RW:true Source:/var/lib/docker/volumes/800e943d52c78312b2d6dd53bed41999fd5f7780af5098f688a894fb74f4360f/_data Type:volume]]
bb3875c107daa062f2eccb10bd48ad54954cecd7d51a5eba385335f377b7aae9:Volumes=[map[Destination:/var/lib/postgresql/data Driver:local Mode: Name:774546bf5c3dcfe5f90a60012c5f1f2bdeb57a5908cdc1922b3dc75550ceeaa4 Propagation: RW:true Source:/var/lib/docker/volumes/774546bf5c3dcfe5f90a60012c5f1f2bdeb57a5908cdc1922b3dc75550ceeaa4/_data Type:volume]]
7a3a2c9e524a9d44ae857abd52447f86940dd49e1947291e7985b98e3c6a309a:Volumes=[map[Destination:/usr/src/redmine/config/configuration.yml Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/config/configuration.yml Type:bind] map[Destination:/usr/src/redmine/files Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/files Type:bind] map[Destination:/usr/src/redmine/app/models/attachment.rb Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/config/attachment.rb Type:bind] map[Destination:/usr/src/redmine/config.ru Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/config/config.ru Type:bind]]
0780c27f8eb858e172e6a7458d2b2221130e6dde0f64887d396ad5bc350a4a64:Volumes=[map[Destination:/var/lib/mysql Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/mysql Type:bind]]
```

- 修复建议

不要将主机敏感目录挂载在容器上，尤其是在读写模式下

### 4.14 `SSH`不在容器中运行

- 描述

`SSH`服务不应该在容器内运行

- 隐患分析

在容器内运行`SSH`可以增加安全管理的复杂性
难以管理`SSH`服务器的访问策略和安全合规性
难以管理各种容器的密钥和密码
难以管理`SSH`服务器的安全升级
可以在不使用`SSH`情况下对容器进行`shell`访问，避免不必要地增加安全管理的复杂性。

- 审计方式

```bash
for i in `docker ps --quiet`;do
docker exec $i ps -el|grep sshd >/dev/null
if [ $? -eq 0 ]; then
    echo "container : $i run sshd..."
fi
done
```

返回值如下，说明下面几个容器内部运行`ssh`服务

```bash
container : 0781479bef1b run sshd...
container : fea9d4d5708a run sshd...
container : 38bb65479056 run sshd...
container : 212fec812c01 run sshd...
```

- 修复建议

卸载容器内部`ssh`服务或重新构建不含有`ssh`的镜像，运行容器

### 4.15 特权端口禁止映射到容器内

- 描述

低于`1024`的`TCP/IP`端口号被认为是特权端口，由于各种安全原因，普通用户和进程不允许使用它们。

- 隐患分析

默认情况下，如果用户没有明确声明容器端口进行主机端口映射，`Docker`会自动地将容器端口映射到主机上的`49153-65535`中。
但是，如果用户明确声明它，`Docker`可以将容器端口映射到主机上的特权端口。
这是因为容器使用不限制特权端口映射的`NET_BIND_SERVICE Linux`内核功能来执行。
特权端口接收和发送各种敏感和特权的数据。允许`Docker`使用它们可能会带来严重的影响

- 审计方式

通过执行以下命令列出容器的所有运行实例及其端口映射

```bash
[root@localhost ~]# docker ps --quiet |xargs docker inspect --format '{{.Id}}:Ports={{.NetworkSettings.Ports}}'                               7121e891641679fda571e67a0e9953d263feca2508b013c70ae2546f6336b1a0:Ports=map[6060/tcp:[map[HostIp:0.0.0.0 HostPort:6060]] 6061/tcp:<nil>]
bb3875c107daa062f2eccb10bd48ad54954cecd7d51a5eba385335f377b7aae9:Ports=map[5432/tcp:[map[HostIp:0.0.0.0 HostPort:5432]]]
7a3a2c9e524a9d44ae857abd52447f86940dd49e1947291e7985b98e3c6a309a:Ports=map[3000/tcp:[map[HostIp:0.0.0.0 HostPort:4000]]]
0780c27f8eb858e172e6a7458d2b2221130e6dde0f64887d396ad5bc350a4a64:Ports=map[3306/tcp:[map[HostIp:0.0.0.0 HostPort:3316]]]
```

查看列表，并确保容器端口未映射到低于`1024`的主机端口号

- 修复建议

启动容器时，不要将容器端口映射到特权主机端口。另外，确保没有容器在`Docker`文件中特权端口映射声明

### 4.16 只映射必要的端口

- 描述

容器镜像的`Dockerfile`定义了在容器实例上默认要打开的端口。端口列表可能与在容器内运行的应用程序相关

- 隐患分析

一个容器可以运行在`Dockerfile`文件中为其镜像定义的端口，也可以任意传递运行时参数以打开一个端口列表。
此外，`Dockerfile`文件可能会进行各种更改，暴露的端口列表可能与在容器内运行的应用程序不相关。
推荐做法是不要打开不需要的端口

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Ports={{.NetworkSettings.Ports}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:Ports=map[80/tcp:[map[HostIp:192.168.235.128 HostPort:18080]]]
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:Ports=map[80/tcp:[map[HostIp:0.0.0.0 HostPort:8080]]]
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Ports=map[]
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Ports=map[]
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Ports=map[]
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Ports=map[]
```

查看列表，并确保映射的端口是容器真正需要的端口

### 4.17 确保容器的内存使用合理

- 描述

默认情况下，`Docker`主机上的所有容器均等共享资源。
通过使用`Docker`主机的资源管理功能，例如内存限制，您可以控制容器可能消耗的内存量

- 隐患分析

默认情况下，容器可以使用主机上的所有内存。
您可以使用内存限制机制来防止由于一个容器消耗了所有主机资源而导致拒绝服务，以致同一主机上的其他容器无法执行预期功能

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Memory={{.HostConfig.Memory}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:Memory=0
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:Memory=0
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Memory=0
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Memory=0
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Memory=0
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Memory=0
```

如果上述命令返回0，则表示内存无限制。如果上述命令返回非零值，则表示已有内存限制策略

- 修复建议

建议使用`--momery`参数运行容器，例如可以如下运行一个容器

```bash
docker run -idt --memory 256m centos
```

### 4.18 设置容器的根文件系统为只读

- 描述

通过使用`Docker`运行的只读选项，容器的根文件系统应被视为`只读镜像`。 这样可以防止在容器运行时写入容器的根文件系统

- 隐患分析

启用此选项会迫使运行时的容器明确定义其数据写入策略，可减少安全风险，
因为容器实例的文件系统不能被篡改或写入，除非它对文件系统文件夹和目录具有明确的读写权限。

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:ReadonlyRootfs={{.HostConfig.ReadonlyRootfs}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:ReadonlyRootfs=false
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:ReadonlyRootfs=false
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:ReadonlyRootfs=false
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:ReadonlyRootfs=false
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:ReadonlyRootfs=false
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:ReadonlyRootfs=false
```

如果上述命令返回`true`，则表示容器的根文件系统是只读的。
如果上述命令返回`false`，则意味着容器的根文件系统是可写的

- 修复建议

在容器的运行时添加一个只读标志以强制容器的根文件系统以只读方式装入

```bash
docker run  <Run arguments> -read-only <Container Image Name or ID> <Command>
```

在容器的运行时启用只读选项，包括但不限于如下：

> 1.使用`--tmpfs` 选项为非持久数据写入临时文件系统

```bash
docker run -idt --read-only --tmpfs "/run" --tmpfs "/tmp" centos bash
```

> 2.启用Docker rw在容器的运行时载入，以便将容器数据直接保存在Docker主机文件系统上

```bash
docker run -idt --read-only -v /opt/app/data:/run/app/data:rw centos
```

> 3.在容器运行期间，将容器数据传输到容器外部，以便保持容器数据。包括托管数据库，网络文件共享和 API。

### 4.19 确保进入容器的流量绑定到特定的主机接口

- 描述

默认情况下，`Docker`容器可以连接到外部，但外部无法连接到容器。
每个传出连接都源自主机自己的`IP`地址。所以只允许通过主机上的特定外部接口访问容器服务

- 隐患分析

如果主机上有多个网络接口，则容器可以接受任何网络接一上公开端口的连接，这可能不安全。
很多时候，特定的端口暴露在外部，并且在这些端口上运行诸如入侵检测，入侵防护，防火墙，负载均衡等服务以筛选传入的公共流量。
因此，只允许来自特定外部接口的传入连接

- 审计方式

通过执行以下命令列出容器的所有运行实例及其端口映射

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Ports={{.NetworkSettings.Ports}}'
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:Ports=map[80/tcp:[map[HostIp:0.0.0.0 HostPort:8080]]]
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Ports=map[]
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Ports=map[]
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Ports=map[]
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Ports=map[]
```

查看列表并确保公开的容器端口与特定接口绑定，而不是通配符`IP`地址`- 0.0.0.0`
例如，如果上述命令返回是不安全的，并且容器可以接受指定端口8080上的任何主机接口上的连接

- 修复建议

将容器端口绑定到所需主机端口上的特定主机接口。

```bash
[root@localhost ~]# docker run -idt --name=nginx2 -p 192.168.235.128:18080:80 --network=nginx-net nginx:1.14-alpine
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Ports={{.NetworkSettings.Ports}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:Ports=map[80/tcp:[map[HostIp:192.168.235.128 HostPort:18080]]]
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:Ports=map[80/tcp:[map[HostIp:0.0.0.0 HostPort:8080]]]
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Ports=map[]
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Ports=map[]
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Ports=map[]
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Ports=map[]
```

### 4.20 容器重启策略`on-failure`设置为`5`

- 描述

在`docker run`命令中使用`--restart`标志，可以指定重启策略，以便在廿出时确定是否重启容器。
基于安全考虑，应该设置重启尝试次数限制为5次

- 隐患分析

如果无限期地尝试启动容器，可能会导致主机上的拒绝服务。
这可能是一种简单的方法来执行分布式拒绝服务攻击，特别是在同一主机上有多个容器时。
此外，忽略容器的廿出状态并始终尝试重新启动容器导致未调查容器终止的根本原因。
如果一个容器被终止，应该做的是去调查它重启的原因，而不是试图无限期地重启它。 
因此，建议使用故障重启策略并将其限制为最多 5 次重启尝试

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:RestartPolicyName={{.HostConfig.RestartPolicy.Name}} MaximumRetryCount={{.HostConfig.RestartPolicy.MaximumRetryCount}}'
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:RestartPolicyName=no MaximumRetryCount=0
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:RestartPolicyName=no MaximumRetryCount=0
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:RestartPolicyName=no MaximumRetryCount=0
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:RestartPolicyName=no MaximumRetryCount=0
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:RestartPolicyName=no MaximumRetryCount=0
```

- 修复建议

如果一个容器需要自己重新启动，可以如下设置：

```bash
docker run -idt --restart=on-failure:5 nginx
```

### 4.21 确保主机的进程命名空间不共享

- 描述

进程`ID（PID）`命名空间隔离进程`ID`空间，这意味着不同`PID`命名空间中的进程可以具有相同的`PID`。这就是容器和主机之间的进程级隔离

- 隐患分析

`PID`名称空间提供了进程的隔离。`PID`命名空间删除了系统进程的视图，并允许重用包括`PID`的进程`ID`。
如果主机的`PID`名称空间与容器共享，它基本上允许容器内的进程查看主机上的所有进程。
这就打破了主机和容器之间进程级别隔离的优点。若访问容器最终可以知道主机系统上运行的所有进程，甚至可以从容器内杀死主机系统进程。
这可能是灾难性的。因此，不要将容器与主机的进程名称空间共享

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:PidMode={{.HostConfig.PidMode}}'
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:PidMode=
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:PidMode=
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:PidMode=
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:PidMode=
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:PidMode=
```

如果上述命令返回`host`，则表示主机`PID`名称空间与容器共享，存在安全风险

- 修复建议

不要使用`--pid=host`参数启动容器。例如，不要启动一个容器，如下所示

````bash
docker run -idt --pid=host centos
````

### 4.22 主机的`IPC`命令空间不共享

- 描述

`IPC（POSIX / Sys IPC）`命名空间提供命名共享内存段，信号量和消息队列的分离。因此主机上的`IPC`命名空间不应该与容器共享，并且应该保持独立。

- 隐患分析

`IPC`命名空间提供主机和容器之间的`IPC`分离。
如果主机的`IPC`名称空间与容器共享，它允许容器内的进程查看主机系统上的所有`IPC`。
这打破了主机和容器之间`IPC`级别隔离的好处。可通过访问容器操纵主机`IPC`。
这可能是灾难性的。 因此，不要将主机的`IPC`名称空间与容器共享

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:IpcMode={{.HostConfig.IpcMode}}'
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:IpcMode=private
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:IpcMode=private
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:IpcMode=private
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:IpcMode=private
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:IpcMode=private
```

如果上述命令返回`host`，则意味着主机`IPC`命名空间与容器共享。

- 修复建议

不要使用`--ipc=host`参数启动容器。 例如，不要启动如下容器

```bash
docker run -idt --ipc=host centos
```

- 说明

共享内存段用于加速进程间通信。 它通常被高性能应用程序使用。
如果这些应用程序被容器化为多个容器，则可能需要共享容器的`IPC`名称空间以实现高性能。 
在这种情况下，您仍然应该共享容器特定的`IPC`命名空间而不是整个主机`IPC`命名空间。
可以将容器的`IPC`名称空间与另一个容器共享，如下所示：

```bash
docker run -idt --ipc=container:e43299eew043243284 centos
```

### 4.23 主机设备不直接共享给容器

- 描述

主机设备可以在运行时直接共享给容器。 不要将主机设备直接共享给容器，特别是对不受信任的容器

- 隐患分析

选项`--device` 将主机设备共享给容器，因此容器可以直接访问这些主机设备。
不允许容器以特权模式运行以访问和操作主机设备默认情况下，容器将能够读取，写入和`mknod`这些设备。
此外，容器可能会从主机中删除设备。 因此，不要直接将主机设备共享给容器。如果必须的将主机设备共享给容器，请适当地使用共享权限：

```bash
w -> write
r -> read
m -> mknod
```

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Devices={{.HostConfig.Devices}}'
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Devices=[]
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Devices=[]
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Devices=[]
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:Devices=[]
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Devices=[]
```

验证是否需要从容器中访问主机设备，并且正确设置所需的权限。如果上述命令返回[]，则容器无权访问主机设备

- 修复建议

不要将主机设备直接共享于容器。如果必须将主机设备共享给容器，请使用正确的一组权限，以下为错误示范

```bash
docker run --interactive --tty --device=/dev/tty0:/dev/tty0:rwm centos bash
```

### 4.24 设置装载传播模式不共享

- 描述

装载传播模式允许在容器上以`shared`、`private`和`slave`模式挂载数据卷。只有必要的时候才使用共享模式

- 隐患分析

共享模式下挂载卷不会限制任何其他容器的安装并对该卷进行更改。
如果使用的数据卷对变化比较敏感，则这可能是灾难性的。最好不要将安装传播模式设置为共享

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{.Id}:Propagation={{range $mnt:=.Mounts}}{{json $mnt.Propagation}}{{end}}'
{.Id}:Propagation=
{.Id}:Propagation=
{.Id}:Propagation=
{.Id}:Propagation=
{.Id}:Propagation=
```

上述命令将返回已安装卷的传播模式。除非需要，不应将传播模式设置为共享。

- 修复建议

不建议以共享模式传播中安装卷。例如，不要启动容器，如下所示

```bash
docker run <Run arguments> --volume=/hostPath:/containerPath:shared <Container Image Name or ID> <Command>
```

### 4.25 设置主机的`UTS`命令空间不共享

- 描述

`UTS`命名空间提供两个系统标识符的隔离：主机名和`NIS`域名。
它用于设置在该名称空间中运行进程可见的主机名和域名。
在容器中运行的进程通常不需要知道主机名和域名。因此，名称空间不应与主机共享

- 隐患分析

与主机共享`UTS`命名空间提供了容器可更改主机的主机名。这是不安全的

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet --all |xargs docker inspect --format '{{.Id}}:UTSMode={{.HostConfig.UTSMode}}'
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:UTSMode=
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:UTSMode=
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:UTSMode=
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:UTSMode=
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:UTSMode=
```
如果上述命令返回`host`，则意味着主机`UTS`名称空间与容器共享，是不符合要求的。
如果上述命令不返回任何内容，则主机的`UTS`名称空间不共享

- 修复建议

不要使用`--uts=host`参数启动容器。例如，不要启动如下容器：

```bash
docker run -idt --uts=host alpine
```

### 4.26 `docker exec`命令不能使用特权选项

- 描述

不要使用`--privileged`选项来执行`docker exec`

- 隐患分析

在`docker exec`中使用`--privileged`选项可为命令提供扩展的`Linux`功能。这可能会造成不安全的情况

- 修复建议

在`docker exec`命令中不要使用`--privileged`选项

### 4.27 `docker exec`命令不能与`user`选项一起使用

- 描述

不要使用`--user`选项执行`docker exec`

- 隐患分析

在`docker exec`中使用`--user`选项以该用户身份在容器内执行该命令。这可能会造成不安全的情况。
例如，假设你的容器是以`tomcat`用户（或任何其他非`root`用户）身份运行的，
那么可以使用`--user=root`选项以`root`用户身份运行命令，这是非常危险的

- 修复建议

在`docker exec`命令中不要使用`--user`选项

### 4.28 检查容器运行时状态

- 描述

如果容器镜像没有定义`HEALTHCHECK`指令，请在容器运行时使用`--health-cmd`参数来检查容器运行状况

- 隐患分析

可用性是安全一个重要特性。如果您用的容器镜像没有预定义的`HEALTHCHECK`指令，
请使用`--health-cmd`参数在运行时检查容器运行状况。根据报告的健康状况，可以采取必要的措施

- 审计方式

运行以下命令并确保所有容器都报告运行状况

```bash
[root@localhost ~]# docker ps --quiet |xargs -n1 docker inspect --format='{{.State.Health.Status}}'
Template parsing error: template: :1:8: executing "" at <.State.Health.Status>: map has no entry for key "Health"
Template parsing error: template: :1:8: executing "" at <.State.Health.Status>: map has no entry for key "Health"
Template parsing error: template: :1:8: executing "" at <.State.Health.Status>: map has no entry for key "Health"
Template parsing error: template: :1:8: executing "" at <.State.Health.Status>: map has no entry for key "Health"
```

- 修复建议

添加`--health-cmd`参数

```bash
[root@localhost ~]# docker run --name=test -d \
>     --health-cmd='stat /etc/passwd || exit 1' \
>     --health-interval=2s \
> busybox:1.31.1 sleep 1d
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc
[root@localhost ~]# 1.31.1
-bash: 1.31.1: command not found
[root@localhost ~]# sleep 2; docker inspect --format='{{.State.Health.Status}}' test
healthy
[root@localhost ~]# docker exec test rm /etc/passwd
[root@localhost ~]# sleep 2; docker inspect --format='{{.State.Health.Status}}' test
unhealthy
```


### 4.29 限制使用`PID cgroup`

- 描述

在容器运行时使用`--pids-limit`标志

- 隐患分析

攻击者可以在容器内发射`fork`炸弹。 这个`fork`炸弹可能会使整个系统崩溃，并需要重新启动主机以使系统重新运行。 
`PIDs cgroup --pids-limit`将通过限制在给定时间内可能发生在容器内的`fork`数来防止这种攻击

- 审计分析

运行以下命令并确保`PidsLimit`未设置为`0`或`-1`。
`PidsLimit`为`0`或`-1`意味着任何数量的进程可以同时在容器内分叉。

```bash
[root@localhost ~]# docker ps --quiet | xargs docker inspect --format='{{.Id}}:PidsLi                                                            mit={{.HostConfig.PidsLimit}}'
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:PidsLimit=<no value>
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:PidsLimit=<no value>
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:PidsLimit=<no value>
```

- 修复建议

升级内核至`4.3+`，添加`--pids-limit参数`，如

```bash
docker run -idt --name=box --pids-limit=100 busybox:1.31.1
```

### 4.30 不要使用`Docker`的默认网桥`docker0`

- 描述

不要使用`Docker`的默认`bridge docker0`。 使用`Docker`的用户定义的网络进行容器联网

- 隐患分析

`Docker`将以桥模式创建的虚拟接口连接到名为`docker0`的公共桥。
这种默认网络模型易受`ARP`欺骗和`MAC`洪泛攻击的攻击，因为没有应用过滤

- 审计方式

运行以下命令，并验证容器是否在用户定义的网络上，而不是默认的`docker0`网桥

```bash
[root@localhost ~]# docker network ls --quiet|xargs docker network inspect --format='{{.Name}}.{{.Options}}'|grep docker0
bridge.map[com.docker.network.bridge.default_bridge:true com.docker.network.bridge.enable_icc:true com.docker.network.bridge.enable_ip_masquerade:true com.docker.network.bridge.host_binding_ipv4:0.0.0.0 com.docker.network.bridge.name:docker0 com.docker.network.driver.mtu:1500]
```

若返回值不为空，说明使用`docker0`网桥

- 修复建议

**使用自定义网桥**

> 关于自定义网桥与默认docker0网桥的主要区别

- 自定义网桥自动提供容器间的`DNS`解析

默认网桥通过`IP`地址实现容器间的寻址，也可通过`--link`参数实现容器`DNS`解析（容器A名称->容器A IP地址），但不推荐`--link`方式

- 自定义网桥提供更好的隔离

如果宿主机上所有容器没有指定`--network`参数，那它们将使用默认网桥`docker0`，并可以无限制的互相通信，存在一定安全隐患。

而自定义网桥提供了的网络隔离，只有相同网络域（network）内的容器才能相互访问

> 创建自定义网桥

```bash
docker network create nginx-net
```

> 运行测试用例

```bash
[root@localhost ~]# docker run -idt --name=nginx --network=nginx-net nginx:1.14-alpine
[root@localhost ~]# docker run -idt --name=box --network=nginx-net busybox:1.31.1
[root@localhost ~]# docker exec box wget nginx -S
Connecting to nginx (172.18.0.2:80)
  HTTP/1.1 200 OK
  Server: nginx/1.14.2
  Date: Sat, 01 May 2021 07:06:59 GMT
  Content-Type: text/html
  Content-Length: 612
  Last-Modified: Wed, 10 Apr 2019 01:08:42 GMT
  Connection: close
  ETag: "5cad421a-264"
  Accept-Ranges: bytes
```

### 4.31 任何容器内不能安装`Docker`套接字

- 描述

`docker socket`不应该安装在容器内

- 隐患分析

如果`Docker`套接字安装在容器内，它将允许在容器内运行的进程执行`Docker`命令，这有效地允许完全控制主机

- 审计方式

```bash
[root@localhost ~]# docker ps --quiet | xargs docker inspect --format='{{.Id}}:Volumes={{.Mounts}}'|grep docker.sock
```

上述命令将返回`docker.sock`作为卷映射到容器的任何实例

- 修复建议

确保没有容器将`docker.sock`作为卷

## 5.`Docker`安全操作

### 5.1 避免镜像泛滥

- 描述

不要在同一主机上保留大量容器镜像，根据需要仅使用标记的镜像。 

- 隐患分析

标记镜像有助于从`latest`退回到生产中镜像的特定版本。
如果实例化了未使用或旧标签的镜像，则可能包含可能被利用的漏洞。
此外，如果您无法从系统中删除未使用的镜像，并且存在各种此类冗余和未使用的镜像，主机文件空间可能会变满，从而导致拒绝服务。

- 审计方式

> 1.通过执行以下命令列出当前实例化的所有镜像`ID`

```bash
[root@localhost ~]# docker images --quiet | xargs docker inspect --format='{{.Id}}:Image={{.Config.Image}}'
sha256:d6e46aa2470df1d32034c6707c8041158b652f38d2a9ae3d7ad7e7532d22ebe0:Image=sha256:3543079adc6fb5170279692361be8b24e89ef1809a374c1b4429e1d560d1459c
```

> 2.通过执行以下命令列出系统中存在的所有镜像

```bash
[root@localhost ~]# docker images
REPOSITORY                         TAG       IMAGE ID       CREATED        SIZE
harbor.wl.com/public/alpine   latest    d6e46aa2470d   6 months ago   5.57MB
```

> 3.比较步骤1和步骤2中的镜像`ID`列表，找出当前未实例化的镜像。如果发现未使用或旧镜像，请与系统管理员讨论是否需要在系统上保留这些镜像

- 修复建议

保留您实际需要的一组镜像，并建立工作流程以从主机中删除陈旧的镜像。
此外，使用诸如按摘要的功能从镜像仓库中获取特定镜像。
对于无用镜像，应予以删除

### 5.2 避免容器泛滥

- 描述

不要在同一主机上保留大量无用容器 

- 隐患分析

容器的灵活性使得运行多个应用程序实例变得很容易，并间接导致存在于不同安全补丁级别的`Docker`镜像。
因此，避免容器泛滥，并将主机上的容器数量保持在可管理的总量上

- 审计方式

> 1.查找主机上的容器总数

```bash
[root@localhost ~]# docker info --format '{{.Containers}}'
1
```
> 2.执行以下命令以查找主机上实际正在运行或处于停止状态的容器总数。

```bash
[root@localhost ~]# docker info --format '{{.ContainersStopped}}'
0
[root@localhost ~]# docker info --format '{{.ContainersRunning}}'
1
```

如果主机上保留的容器数量与主机上实际运行的容器数量之间的差异很大（比如说 25 或更多），
那么请清理无用容器（确保`stopped`无用再进行清理）。

- 修复建议

定期检查每个主机的容器清单，并使用以下命令清理已停止的容器

```
[root@localhost ~]# docker container prune
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
Total reclaimed space: 0B
```

## 最佳实践

### 安装

> 安装更新`CentOS 7`最新稳定版

降低低版本操作系统可能存在的安全漏洞

> 安装更新最新稳定版内核

- [香港镜像源](http://hkg.mirror.rackspace.com/elrepo/kernel/el7/x86_64/RPMS/)

更新高版本内核以支持`docker`新特性、降低内核导致的安全漏洞风险

> 安装最新稳定版`docker-ce`

- [docker-ce 二进制下载地址](https://download.docker.com/mac/static/stable/x86_64/)
- [docker-ce 镜像源](https://mirrors.tuna.tsinghua.edu.cn/docker-ce/)

### 配置

> 配置`limit`参数

```bash
ulimit -HSn 65536
cat <<EOF >>/etc/security/limits.conf
*    soft    nofile    65536
*    hard    nofile    65536
*    soft    noproc    10240
*    hard    noproc    10240
EOF
```

> 配置内核参数

```bash
cat <<EOF >>/etc/sysctl.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
user.max_user_namespaces=15000
EOF
sysctl -p
```

> 配置`docker daemon`

```bash
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "log-opts": {
    "max-size": "5m",
    "max-file":"3"
  },
  "userland-proxy": false,
  "live-restore": true,
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  },
  "default-address-pools": [
    {
      "base": "172.80.0.0/16",
      "size": 24
    },
    {
      "base": "172.90.0.0/16",
      "size": 24
    }
  ],
  "no-new-privileges": false,
  "default-gateway": "",
  "default-gateway-v6": "",
  "default-runtime": "runc",
  "default-shm-size": "64M",
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload
systemctl restart docker
```
 
### 文件权限调整

```bash
chmod 755 /etc/docker
chown root:root /etc/docker
chmod 660 /var/run/docker.sock
chown root:docker /var/run/docker.sock
systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 chmod 644
systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 chmod 644
systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 chown root:root
systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 chown root:root
if [ -d /etc/docker/certs.d/ ];then chmod 444 /etc/docker/certs.d/*; fi
if [ -d /etc/docker/certs.d/ ];then chown root:root /etc/docker/certs.d/*; fi
if [ -f /etc/docker/daemon.json ];then chown root:root /etc/docker/daemon.json; fi
```
 
## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)

{% endraw %}