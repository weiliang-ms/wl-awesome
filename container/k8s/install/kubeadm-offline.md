<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [离线安装](#%E7%A6%BB%E7%BA%BF%E5%AE%89%E8%A3%85)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

配置k8s源

    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=0
    repo_gpgcheck=0
    gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
            http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    EOF
    
    yum clean all && yum makecache 
    
安装yum插件

    yum install yum-plugin-downloadonly -y
    
导出依赖

    yum install --downloadonly --downloaddir=/root/k8s kubelet-1.15.5 kubeadm-1.15.5 kubectl-1.15.5
    
安装kububeadm

    yum install -y kubelet-1.15.5 kubeadm-1.15.5 kubectl-1.15.5 --disableexcludes=kubernetes
    
下载k8s相关镜像

    #k8s.gcr.io被墙，需要走微软代理地址
    for i in `kubeadm config images list 2>/dev/null |sed 's/k8s.gcr.io\///g'`; do
        docker pull gcr.azk8s.cn/google-containers/${i}
        docker tag gcr.azk8s.cn/google-containers/${i} k8s.gcr.io/${i}
        docker rmi gcr.azk8s.cn/google-containers/${i}
    done
    
离线下载镜像

    docker save $(docker images | grep -v REPOSITORY | awk 'BEGIN{OFS=":";ORS=" "}{print $1,$2}') -o /root/k8s/k8s-master.tar
  
打包资源包

    tar zcvf k8s-1.15.5.tar.gz k8s/
    
    
### 离线安装

[离线安装docker](/os/virtaul/containerontainer/docker/docker-install-offline.md)

上传k8s资源包，解压

    tar zxvf k8s-*.tar.gz
    
导入镜像

    docker load -i k8s/k8s-master.tar
    
安装kubeadm

    rpm -ivh k8s/*.rpm --nodeps --force
  
修改时区

    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    
关闭防火墙

    systemctl stop firewalld && systemctl disable firewalld
    
关闭swap

    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    sysctl -p
    
设置内核参数

    modprobe br_netfilter
    cat << EOF | tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables=1
    net.bridge.bridge-nf-call-ip6tables=1
    EOF
    
    sysctl -p /etc/sysctl.d/k8s.conf
    
修改Linux 资源配置文件,调高ulimit最大打开数和systemctl管理的服务文件最大打开数

    echo "* soft nofile 655360" >> /etc/security/limits.conf
    echo "* hard nofile 655360" >> /etc/security/limits.conf
    echo "* soft nproc 655360" >> /etc/security/limits.conf
    echo "* hard nproc 655360" >> /etc/security/limits.conf
    echo "* soft memlock unlimited" >> /etc/security/limits.conf
    echo "* hard memlock unlimited" >> /etc/security/limits.conf
    echo "DefaultLimitNOFILE=1024000" >> /etc/systemd/system.conf
    echo "DefaultLimitNPROC=1024000" >> /etc/systemd/system.conf
      
修改kubelet配置

    sed -i "s;KUBELET_EXTRA_ARGS=;KUBELET_EXTRA_ARGS=\"--fail-swap-on=false\";g" /etc/sysconfig/kubelet

配置hostname
    
**172.16.145.140主要替换为实际IP**

    hostnamectl --static set-hostname master
    echo "172.16.145.140 master" >> /etc/hosts

配置kubelet自启动

    systemctl enable kubelet
    
初始化集群
    
    k8sversion=`kubeadm version -o yaml|grep gitVersion|sed 's#gitVersion:##g'|sed 's/ //g'`
    echo "k8s version: $k8sversion"
    kubeadm init --kubernetes-version=$k8sversion --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --ignore-preflight-errors=Swap
   
配置授权

    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    
[下载flannel.yml](https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml)

    
下载以下镜像并导入

    quay.io/coreos/flannel:v0.11.0-amd64
    
删除主节点污点

    kubectl taint nodes --all node-role.kubernetes.io/master-

安装网络

    kubectl apply -f kube-flannel.yml
    
    

   

    