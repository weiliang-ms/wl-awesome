# 安装
![](../../../assets/laurel-docker-containers.png)
## docker在线安装

> 1、配置yum源

[配置阿里云yum](https://www.cnblogs.com/operationhome/p/11094493.html)

> 2、配置yum代理

内网机器通过http proxy上网时使用

    vi /etc/yum.conf
    
文件最后添加以下内容

    proxy=http://username:password@host:port
    
- username: http代理账号
- password: http代理密码
- host: http代理主机（ip或域名）
- port: http代理端口

> 3、删除旧版本docker

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
    
> 4、安装docker

    #安装一些必要的系统工具
    yum -y install yum-utils device-mapper-persistent-data lvm2
    
    #添加软件源信息
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    
    #更新 yum 缓存
    yum makecache fast
    
    #安装docker-ce
    yum -y install docker-ce
    
> 5、关闭selinux

    setenforce 0
    sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
    
> 6、启动

    systemctl enable docker --now
    
> 7、配置阿里云加速

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

## docker离线安装

选取联网主机下载docker二进制文件

[docker二进制文件](https://download.docker.com/linux/static/stable/x86_64/)

上传解压

    tar zxvf docker-*.tgz
    mv docker/* /usr/bin/
    
配置系统服务

    cat > /etc/systemd/system/docker.service <<EOF
    [Unit]
    Description=Docker Application Container Engine
    Documentation=https://docs.docker.com
    After=network-online.target firewalld.service
    Wants=network-online.target
    [Service]
    Type=notify
    # the default is not to use systemd for cgroups because the delegate issues still
    # exists and systemd currently does not support the cgroup feature set required
    # for containers run by docker
    ExecStart=/usr/bin/dockerd
    ExecReload=/bin/kill -s HUP 
    # Having non-zero Limit*s causes performance problems due to accounting overhead
    # in the kernel. We recommend using cgroups to do container-local accounting.
    LimitNOFILE=infinity
    LimitNPROC=infinity
    LimitCORE=infinity
    # Uncomment TasksMax if your systemd version supports it.
    # Only systemd 226 and above support this version.
    #TasksMax=infinity
    TimeoutStartSec=0
    # set delegate yes so that systemd does not reset the cgroups of docker containers
    Delegate=yes
    # kill only the docker process, not all processes in the cgroup
    KillMode=process
    # restart the docker process if it exits prematurely
    Restart=on-failure
    StartLimitBurst=3
    StartLimitInterval=60s
    [Install]
    WantedBy=multi-user.target
    EOF

关闭selinux
    
    setenforce 0
    sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
    
启动

    systemctl daemon-reload
    systemctl enable docker --now
    
## 配置代理 ##

	#适用场景：内网访问互联网docker镜像仓库
	mkdir -p /etc/systemd/system/docker.service.d

	cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
	[Service]
	Environment="HTTP_PROXY=http://xxx.xxx.xxx.xxx:xxxx"
	EOF

	systemctl daemon-reload && systemctl restart docker
   