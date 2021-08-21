<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [k8s](#k8s)
  - [rke安装k8s集群](#rke%E5%AE%89%E8%A3%85k8s%E9%9B%86%E7%BE%A4)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## k8s

### rke安装k8s集群

[rke文档地址](https://rancher.com/docs/rancher/v2.x/en/installation/ha/)

> 1、环境准备

- 虚拟机 * 3

- 配置[阿里云yum源](https://www.cnblogs.com/-xuan/p/10674562.html)

> 2、下载rke二进制文件

安装节点下载即可

	curl -L https://github.com/rancher/rke/releases/download/v0.3.2/rke_linux-amd64 -o /usr/bin/rke
	chmod +x /usr/bin/rke

> 3、关闭防火墙、selinux等

关闭所有主机的selinux、firewalld

	setenforce 0
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	systemctl stop firewalld && systemctl disable firewalld

> 4、安装docker

所有节点

	yum install -y epel-release
	yum install -y yum-utils net-tools conntrack-tools wget
	yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
	yum install -y docker-ce-18.06.1.ce

启动

	systemctl start docker
	systemctl enable docker

配置加速

	sudo mkdir -p /etc/docker
	sudo tee /etc/docker/daemon.json <<-'EOF'
	{
	  "registry-mirrors": ["https://jz73200c.mirror.aliyuncs.com"]
	}
	EOF
	sudo systemctl daemon-reload
	sudo systemctl restart docker

> 5、初始化docker用户

所有节点

	useradd -m docker && echo "1qaz@WSX" | passwd --stdin docker

> 6、安装节点配置互信

	ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa

	ssh-copy-id docker@节点地址

> 7、创建集群配置文件

	cat > rancher-cluster.yml <<EOF
	nodes:
	  - address: 192.168.146.134
	    internal_address: 192.168.146.134
	    user: docker
	    role: [controlplane,worker,etcd]
	  - address: 192.168.146.135
	    internal_address: 192.168.146.135
	    user: docker
	    role: [controlplane,worker,etcd]
	  - address: 192.168.146.136
	    internal_address: 192.168.146.136
	    user: docker
	    role: [controlplane,worker,etcd]
	
	services:
	  etcd:
	    snapshot: true
	    creation: 6h
	    retention: 24h
	EOF

> 8.下载镜像

可提前下载好所需镜像

	docker pull rancher/rke-tools:v0.1.50
	docker pull rancher/hyperkube:v1.15.5-rancher1
	docker pull rancher/coreos-etcd:v3.3.10-rancher1

> 9、构建集群

	rke up --config ./rancher-cluster.yml

> 10、查看结果

![](../foundation/images/rke-finish.png)

> 11、配置

主节点

	mkdir ~/.kube
	cat kube_config_rancher-cluster.yml > ~/.kube/config

> 12、安装kubectl等

	cat > /etc/yum.repos.d/kubernetes.repo <<EOF
	[kubernetes]
	name=Kubernetes
	baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
	enabled=1
	gpgcheck=0
	repo_gpgcheck=0
	gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
	http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
	EOF

主机点安装Kubectl即可

	yum -y install kubectl

安装自动补全

	yum install -y bash-completion
	source /usr/share/bash-completion/bash_completion
	source <(kubectl completion bash)
	echo "source <(kubectl completion bash)" >> ~/.bashrc

> 13、查看节点信息

	kubectl get node

![](../foundation/images/k8s-node-info.png)

> 14、发布应用测试

	cat >> nginx.yaml <<EOF
	apiVersion: v1
	kind: Service
	metadata:
	  labels:
	    app: nginx-service
	  name: nginx-service
	  namespace: default
	spec:
	  ports:
	  - port: 80
	    protocol: TCP
	    targetPort: 80
	  selector:
	    app: nginx
	  sessionAffinity: None
	  type: ClusterIP
	---
	apiVersion: apps/v1
	kind: Deployment
	metadata:
	  name: nginx-deployment
	spec:
	  selector:
	    matchLabels:
	      app: nginx
	  replicas: 6
	  template:
	    metadata:
	      labels:
	        app: nginx
	    spec:
	      containers:
	      - name: nginx
	        image: nginx:1.16.0
	        ports:
	        - containerPort: 80
	EOF

创建

	kubectl apply -f nginx.yaml

查看状态
	
	kubectl get pod -o wide

![](../foundation/images/nginx-pod.png)

查看svc，测试

	kubectl get svc
	
![](../foundation/images/nginx-service.png)

删除

	kubectl delete deploy --all
	kubectl delete svc/nginx-service