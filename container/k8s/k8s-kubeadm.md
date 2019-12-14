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
    
启动kubelet

    systemctl enable --now kubelet
    
下载k8s相关镜像

    for i in `kubeadm config images list 2>/dev/null`; do
        docker pull mirrorgooglecontainers/${i}
        docker tag mirrorgooglecontainers/${i} k8s.gcr.io/${i}
        docker rmi mirrorgooglecontainers/${i}
    done

    



