### docker安装

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
   