### docker安装

[配置阿里云yum](https://www.cnblogs.com/operationhome/p/11094493.html)

删除旧版本docker

    yum remove docker -y \
      docker-client \
      docker-client-latest \
      docker-common \
      docker-latest \
      docker-latest-logrotate \
      docker-logrotate \
      docker-selinux \
      docker-engine-selinux \
      docker-engine
    rm -rf /etc/systemd/system/docker.service.d
    rm -rf /var/lib/docker
    rm -rf /var/run/docker
    rm -rf /usr/local/docker
    rm -rf /etc/docker
    
安装一些必要的系统工具

    yum -y install yum-utils device-mapper-persistent-data lvm2
    
添加软件源信息

    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    
更新 yum 缓存

    yum makecache fast
    
安装docker-ce

    yum -y install docker-ce
    
关闭selinux
    
    setenforce 0
    sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
    
启动

    systemctl enable docker --now
    
阿里云加速

[加速配置地址](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)

    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<EOF
    {
      "exec-opts": ["native.cgroupdriver=systemd"],
      "registry-mirrors": ["https://jz73200c.mirror.aliyuncs.com"]
    }
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
   