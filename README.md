[![build status badge](https://img.shields.io/travis/docker-library/docker/master.svg?label=docker%20)](/container/docker)

## linux

- 虚拟化
  - [iDRAC控制台安装操作系统](/linux/virtaul/iDRAC.md)
  - [vsphere磁盘扩容](/linux/virtaul/vsphere.md)
  
- 安全
    - [系统安全加固](/linux/security/system.md)
  
- 系统配置

    - 包管理软件
        - [apt-get配置管理](/linux/package/apt.md)
        - [gem](/linux/package/gem.md) 
        - [pip](/linux/package/pip.md)
        - [yum](/linux/package/yum.md)
        - [rpm包构建](/linux/rpm/rpmbuild.md)
    
    - 监控
       - [磁盘使用率](/linux/monitor/disk.md)

    - [配置调整](/linux/settings/README.md)

    - [时区配置](/linux/timezone.md)
    
    - [ntp配置](/linux/ntp.md)
    
    - [ssl证书签发](https://github.com/weiliang-ms/ssl)
    
    - [访问"卡"等](/linux/block.md)

- 升级更新

    - 软件升级
    
        - [升级kernel](/linux/update/kernel.md)
        - [升级openssl](/linux/update/openssl.md)
        - [升级openssh](/linux/update/openssh.md)
        - [升级gcc](/linux/update/gcc.md)
        
- 常用命令
    - [制作iso镜像](/linux/cmd/mkiso.md)
    
## 集成部署

- 软件安装
    - [redmine](/linux/redmine.md)
    - [install git](/shell/git.md)
    - [redis](https://github.com/weiliang-ms/deploy/blob/master/redis/README.md)
    - [nginx](https://github.com/weiliang-ms/deploy/blob/master/nginx/README.md)
    - [trafodion](/deploy/trafodion.md)
    - [powerdns](/deploy/pdns.md)
    - [python](/deploy/python.md)
    - [gpu驱动](/linux/gpu/gpu.md)
    
## 数据库

- mysql
    - [mysql安装部署](/database/mysql/install.md)
    - [mysql常用命令](/database/mysql/cmd.md)
    - [binlog管理](/database/mysql/binlog.md)

- oracle
    - [ora11g安装](https://github.com/weiliang-ms/wl-awesome/blob/master/database/oracle/install.md)
    
- nosql
    - [redis cluster k8s解决方案](/database/redis-cluster-k8s.md)

## container

- docker
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
- k8s
    - [k8s镜像库国内访问仓库地址](/container/k8s/mirror.md)
    - 安装
        - [rke](/container/k8s/k8s-rke.md)
        - [ansible](https://github.com/easzlab/kubeasz)
        - [kebeadm安装HA](/container/k8s/k8s-kubeadm.md)
        - [kubeadm离线安装](/container/k8s/kubeadm-offline.md)

## 编程语言
- golang
    - 资源
        - [标准库](https://studygolang.com/pkgdoc)
        - [golang圣经](https://books.studygolang.com/gopl-zh)
- 环境初始化
    - [环境安装](/program/golang/install.md)
    - [配置代理](/program/golang/delegate.md)
    - [awesome](https://github.com/avelino/awesome-go)

## 源码

- 源码阅读
    - docker
        - [cli](code/docker/cli.md)

## 软考
- 系统规划与管理师

