<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [linux](#linux)
  - [虚拟化](#%E8%99%9A%E6%8B%9F%E5%8C%96)
    - [iDRAC控制台安装操作系统](#idrac%E6%8E%A7%E5%88%B6%E5%8F%B0%E5%AE%89%E8%A3%85%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F)
    - [vsphere磁盘扩容](#vsphere%E7%A3%81%E7%9B%98%E6%89%A9%E5%AE%B9)
  - [安全](#%E5%AE%89%E5%85%A8)
    - [系统安全加固](#%E7%B3%BB%E7%BB%9F%E5%AE%89%E5%85%A8%E5%8A%A0%E5%9B%BA)
  - [包管理软件](#%E5%8C%85%E7%AE%A1%E7%90%86%E8%BD%AF%E4%BB%B6)
    - [apt-get配置管理](#apt-get%E9%85%8D%E7%BD%AE%E7%AE%A1%E7%90%86)
    - [gem](#gem)
    - [pip](#pip)
    - [yum](#yum)
    - [rpm包构建](#rpm%E5%8C%85%E6%9E%84%E5%BB%BA)
  - [系统配置](#%E7%B3%BB%E7%BB%9F%E9%85%8D%E7%BD%AE)
    - [监控](#%E7%9B%91%E6%8E%A7)
    - [配置](#%E9%85%8D%E7%BD%AE)
  - [升级更新](#%E5%8D%87%E7%BA%A7%E6%9B%B4%E6%96%B0)
    - [软件升级](#%E8%BD%AF%E4%BB%B6%E5%8D%87%E7%BA%A7)
  - [常用命令](#%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4)
- [集成部署](#%E9%9B%86%E6%88%90%E9%83%A8%E7%BD%B2)
- [数据库](#%E6%95%B0%E6%8D%AE%E5%BA%93)
  - [mysql](#mysql)
  - [oracle](#oracle)
  - [nosql](#nosql)
- [container](#container)
  - [docker](#docker)
  - [k8s](#k8s)
    - [安装](#%E5%AE%89%E8%A3%85)
- [编程语言](#%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80)
  - [golang](#golang)
    - [资源](#%E8%B5%84%E6%BA%90)
    - [环境初始化](#%E7%8E%AF%E5%A2%83%E5%88%9D%E5%A7%8B%E5%8C%96)
- [源码](#%E6%BA%90%E7%A0%81)
  - [源码阅读](#%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB)
    - [docker](#docker-1)
- [软考](#%E8%BD%AF%E8%80%83)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# linux
## 虚拟化
### [iDRAC控制台安装操作系统](/linux/virtaul/iDRAC.md)
### [vsphere磁盘扩容](/linux/virtaul/vsphere.md)
## 安全

### [系统安全加固](/os/security/README.md)
  

## 包管理软件
### [apt-get配置管理](/linux/package/apt.md)
### [gem](/linux/package/gem.md) 
### [pip](/linux/package/pip.md)
### [yum](/linux/package/yum.md)
### [rpm包构建](/linux/rpm/rpmbuild.md)
    
## 系统配置
### 监控

- [磁盘使用率](/linux/monitor/disk.md)

### 配置

- [配置调整](/linux/settings/README.md)

- [时区配置](/linux/timezone.md)

- [ntp配置](/linux/ntp.md)

- [ssl证书签发](https://github.com/weiliang-ms/ssl)

- [访问"卡"等](/linux/block.md)

## 升级更新

### 软件升级
    
- [升级kernel](/linux/update/kernel.md)
- [升级openssl](/linux/update/openssl.md)
- [升级openssh](/linux/update/openssh.md)
- [升级gcc](/linux/update/gcc.md)
        
## 常用命令
- [制作iso镜像](/linux/cmd/mkiso.md)
    
# 集成部署

- 软件安装
    - [redmine](/linux/redmine.md)
    - [install git](/shell/git.md)
    - [redis](https://github.com/weiliang-ms/deploy/blob/master/redis/README.md)
    - [nginx](https://github.com/weiliang-ms/deploy/blob/master/nginx/README.md)
    - [trafodion](/deploy/trafodion.md)
    - [powerdns](/deploy/pdns.md)
    - [python](/deploy/python.md)
    - [gpu驱动](/linux/gpu/gpu.md)
    
# 数据库

## mysql
- [mysql安装部署](/database/mysql/install.md)
- [mysql常用命令](/database/mysql/cmd.md)
- [binlog管理](/database/mysql/binlog.md)

## oracle
- [ora11g安装](https://github.com/weiliang-ms/wl-awesome/blob/master/database/oracle/install.md)
    
## nosql
- [redis cluster k8s解决方案](/database/redis-cluster-k8s.md)

# container

## docker
- [docker安装]()
    - [docker在线安装](/container/docker/docker-install-online.md)
    - [docker离线安装](/container/docker/docker-install-offline.md)
- [docker镜像管理](/container/docker/docker-image.md)
- [docker-compose](/container/docker/docker-compose.md)
- [multi-stage](/container/docker/docker-multi-stage.md)
- [build-image](/container/docker/docker-image.md)
- [network](/container/docker/docker-network.md)
- [gosu](https://blog.csdn.net/boling_cavalry/article/details/93380447)
- [清理容器](/container/docker/clean.md)
## k8s
- [k8s镜像库国内访问仓库地址](/container/k8s/mirror.md)
### 安装
- [rke](/container/k8s/k8s-rke.md)
- [ansible](https://github.com/easzlab/kubeasz)
- [kebeadm安装HA](/container/k8s/k8s-kubeadm.md)
- [kubeadm离线安装](/container/k8s/kubeadm-offline.md)

# 编程语言

## golang
### 资源
- [标准库](https://studygolang.com/pkgdoc)
- [golang圣经](https://books.studygolang.com/gopl-zh)
### 环境初始化
- [环境安装](/program/golang/install.md)
- [配置代理](/program/golang/delegate.md)
- [awesome](https://github.com/avelino/awesome-go)

# 源码

## 源码阅读
### docker
- [cli](code/docker/cli.md)
# 软考
- 系统规划与管理师

