[![build status badge](https://img.shields.io/travis/docker-library/docker/master.svg?label=docker%20)](/container/docker)

## linux

- 虚拟化
  - [iDRAC控制台安装操作系统](/linux/virtaul/iDRAC.md)
  - [vsphere磁盘扩容](http://blog.sina.com.cn/s/blog_56a70c0401018dlv.html)
- 系统配置

    - 软件源更改
        - [yum](/linux/yum.md)
        - [apt-get配置管理](/linux/apt.md)
        - [gem](/linux/gem.md) 
    
    - 监控
       - [磁盘使用率](/linux/monitor/disk.md)

    - 配置调整
        - [修改hostname](/linux/hostname.md)
        - [关闭图形化]()

    - 安全策略
        - [防火墙](/linux/security/firewalld.md)

    - [时区配置](/linux/timezone.md)
    
    - [ntp配置](/linux/ntp.md)
    
    - [ssl证书签发](https://github.com/weiliang-ms/ssl)
    
    - [访问"卡"等](/linux/block.md)

- 升级更新

    - 软件升级
        - [升级kernel](/linux/kernel.md)
        - [升级openssl](/linux/openssl.md)
    
## 集成部署

- 软件安装
    - [redmine](/linux/redmine.md)
    - [install git](/shell/git.md)
    - [redis](https://github.com/weiliang-ms/deploy/blob/master/redis/README.md)
    - [nginx](https://github.com/weiliang-ms/deploy/blob/master/nginx/README.md)
    - [trafodion](/deploy/trafodion.md)
    
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
    - [docker安装](/container/docker/docker-install.md)
    - [docker离线安装](/container/docker/docker-install-offline.md)
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

## 软考
- 系统规划与管理师

