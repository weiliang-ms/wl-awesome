## 安装docker ##

`适用于CentOS7&Red Hat 7`

> 查看操作系统版本与内核

	#内核要求3.1以上

![](./images/sys_kernel.png)

> 下载docker安装包

	#互联网下载地址
	https://download.docker.com/linux/static/stable/x86_64/docker-19.03.1.tgz

> 上传安装

	#上传至/tmp下，root用户安装
	cd /tmp && tar -xvf docker-19.03.1.tgz && cp docker/* /usr/bin/

> 关闭selinux

	setenforce 0
	sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config

> 配置为系统服务

	cat >/etc/systemd/system/docker.service <<EOF
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

> 启动并设置为开机自启动

	#重载unit配置文件
	systemctl daemon-reload                                                       

	#启动Docker
	systemctl start docker                                                            
	
	#设置开机自启
	systemctl enable docker.service 

> 查看docker状态

	docker --version
	systemctl status docker

![](./docker_status.png)  

### 管理docker ###

> 配置代理

	#适用场景：内网访问互联网docker镜像仓库
	mkdir -p /etc/systemd/system/docker.service.d

	cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
	[Service]
	Environment="HTTP_PROXY=http://xxx.xxx.xxx.xxx:xxxx"
	EOF

	systemctl daemon-reload && systemctl restart docker

> 配置阿里云加速

	#参考地址
	https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors

	sudo mkdir -p /etc/docker
	sudo tee /etc/docker/daemon.json <<-'EOF'
	{
	  "registry-mirrors": ["https://jz73200c.mirror.aliyuncs.com"]
	}
	EOF
	sudo systemctl daemon-reload
	sudo systemctl restart docker   

> 下载镜像

`docker pull`

	docker pull docker.elastic.co/elasticsearch/elasticsearch:7.3.0

![](./docker_pull.png)

> 查看本地镜像
 
`docker images`

	docker images

![](./docker_images.png)

> 持久化镜像至本地磁盘

`docker save -o 目标目录/镜像文件名称 本地镜像:镜像tag值`

	docker save -o /root/elasticsearch-7.3.0.tar docker.elastic.co/elasticsearch/elasticsearch:7.3.0

![](./docker_save.png)

## 安装docker-compose ##

> 下载

	sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose


> 授权

	chmod +x /usr/local/bin/docker-compose

> 查看docker-compose

	#查看版本信息
	docker-compose --version

![](./docker-compose_version.jpg)
