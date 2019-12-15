### 单机

[配置yum源](/linux/yum.md)

[升级内核](/linux/kernel.md)

[安装docker](/container/docker/docker-install.md)

关闭防火墙

    systemctl stop firewalld && systemctl disable firewalld
    iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat && iptables -P FORWARD ACCEPT
    
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
    
安装依赖

    yum install -y epel-release conntrack ipvsadm ipset jq sysstat curl iptables libseccomp yum-utils device-mapper-persistent-data lvm2

安装kubelet等

    yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    
安装命令补全

    yum install -y bash-completion
    source /usr/share/bash-completion/bash_completion
    source <(kubectl completion bash)
    echo "source <(kubectl completion bash)" >> ~/.bashrc
    
启动kubelet

    systemctl enable --now kubelet
    
下载k8s相关镜像

    for i in `kubeadm config images list 2>/dev/null |sed 's/k8s.gcr.io\///g'`; do
        docker pull gcr.azk8s.cn/google-containers/${i}
        docker tag gcr.azk8s.cn/google-containers/${i} k8s.gcr.io/${i}
        docker rmi gcr.azk8s.cn/google-containers/${i}
    done
    
修改kubelet配置

    sed -i "s;KUBELET_EXTRA_ARGS=;KUBELET_EXTRA_ARGS=\"--fail-swap-on=false\";g" /etc/sysconfig/kubelet

初始化集群
    
    k8sversion=`kubeadm version -o yaml|grep gitVersion|sed 's#gitVersion:##g'|sed 's/ //g'`
    echo "k8s version: $k8sversion"
    kubeadm init --kubernetes-version=$k8sversion --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --ignore-preflight-errors=Swap
   
配置授权

    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    
安装网络

    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

### HA

- 节点说明

    | hostname | IP地址 | 应用|
    | :----: | :----: | :----:|
    | node1 | 172.16.145.160 | docker kubelet kubeadm|
    | node2 | 172.16.145.161 | docker kubelet kubeadm|
    | node3 | 172.16.145.162 | docker kubelet kubeadm|
    
- [所有节点升级内核](/linux/kernel.md)
- [所有节点安装docker](/container/docker/docker-install.md)


    

