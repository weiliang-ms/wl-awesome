<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [单机](#%E5%8D%95%E6%9C%BA)
- [HA](#ha)
  - [所有节点安装kubeadm和kubelet](#%E6%89%80%E6%9C%89%E8%8A%82%E7%82%B9%E5%AE%89%E8%A3%85kubeadm%E5%92%8Ckubelet)
  - [配置负载均衡](#%E9%85%8D%E7%BD%AE%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1)
  - [创建集群](#%E5%88%9B%E5%BB%BA%E9%9B%86%E7%BE%A4)
  - [新worker节点加入集群](#%E6%96%B0worker%E8%8A%82%E7%82%B9%E5%8A%A0%E5%85%A5%E9%9B%86%E7%BE%A4)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 单机

[配置yum源](/linux/package/yum.md)

[升级内核](/linux/update/kernel.md)

[安装docker](/os/virtaul/containerontainer/docker/docker-install-online.md)

关闭防火墙

```shell
systemctl stop firewalld && systemctl disable firewalld
```
    iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat && iptables -P FORWARD ACCEPT
    
关闭swap

```shell
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sysctl -p
```
    
设置内核参数

```shell
modprobe br_netfilter
cat << EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF

sysctl -p /etc/sysctl.d/k8s.conf
```
    
修改Linux 资源配置文件,调高ulimit最大打开数和systemctl管理的服务文件最大打开数

```shell
echo "* soft nofile 655360" >> /etc/security/limits.conf
echo "* hard nofile 655360" >> /etc/security/limits.conf
echo "* soft nproc 655360" >> /etc/security/limits.conf
echo "* hard nproc 655360" >> /etc/security/limits.conf
echo "* soft memlock unlimited" >> /etc/security/limits.conf
echo "* hard memlock unlimited" >> /etc/security/limits.conf
echo "DefaultLimitNOFILE=1024000" >> /etc/systemd/system.conf
echo "DefaultLimitNPROC=1024000" >> /etc/systemd/system.conf
```
    
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

### 安装指定版本

> 查看版本列表

```bash
yum list kubeadm --showduplicates|sort -r
```

> 安装指定版本`kubeadm`

安装`1.18.6`版本

```bash
version=1.18.6-0
yum install -y kubelet-$version kubeadm-$version kubectl-$version --disableexcludes=kubernetes
```
    
> 安装命令补全

```bash
yum install -y bash-completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```
    
> 启动`kubelet`

```bash
systemctl enable kubelet --now
```
    
下载k8s相关镜像

```bash
for i in `kubeadm config images list 2>/dev/null |sed 's/k8s.gcr.io\///g'`; do
    docker pull registry.aliyuncs.com/google-containers/${i}
    docker tag registry.aliyuncs.com/google-containers/${i} k8s.gcr.io/${i}
    docker rmi registry.aliyuncs.com/google-containers/${i}
done
```
    
修改kubelet配置

    sed -i "s;KUBELET_EXTRA_ARGS=;KUBELET_EXTRA_ARGS=\"--fail-swap-on=false\";g" /etc/sysconfig/kubelet

启动kubelet

    systemctl enable --now kubelet
    
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

[参考地址1](https://www.kubernetes.org.cn/5551.html)
[参考地址2](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

- 架构图

![](images/kubeadm-ha-topology-stacked-etcd.svg)

- 节点说明

    | hostname | IP地址 | 应用|
    | :----: | :----: | :----:|
    | node1 | 172.16.145.160 | docker kubelet kubeadm kubectl keepalived harproxy control-plane|
    | node2 | 172.16.145.161 | docker kubelet kubeadm kubectl keepalived harproxy control-plane|
    | node3 | 172.16.145.162 | docker kubelet kubeadm kubectl keepalived harproxy control-plane|
    |  | 172.16.145.200 | |

172.16.145.200为虚拟IP
    
    
- [所有节点升级内核](/linux/update/kernel.md)
- [所有节点安装docker](/os/virtaul/containerontainer/docker/docker-install-online.md)

添加Host解析

    cat >> /etc/hosts <<EOF
    172.16.145.160 node1
    172.16.145.161 node2 
    172.16.145.162 node3
    EOF

所有节点关闭防火墙

    systemctl stop firewalld && systemctl disable firewalld
    
所有节点关闭swap

    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    sysctl -p
    
所有节点设置内核参数

    modprobe br_netfilter
    cat << EOF | tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables=1
    net.bridge.bridge-nf-call-ip6tables=1
    net.ipv4.ip_forward = 1
    EOF
    
    sysctl -p /etc/sysctl.d/k8s.conf
    
所有节点安装ipvs管理工具

    yum install ipvsadm ipset -y

所有节点添加ipvs

    cat > /etc/sysconfig/modules/ipvs.modules <<EOF
    #!/bin/bash
    modprobe -- ip_vs
    modprobe -- ip_vs_rr
    modprobe -- ip_vs_wrr
    modprobe -- ip_vs_sh
    modprobe -- nf_conntrack_ipv4
    EOF
    chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
    
修改docker cgroup driver为systemd

根据文档[CRI installation](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)中的内容，对于使用systemd作为init system的Linux的发行版，
使用systemd作为docker的cgroup driver可以确保服务器节点在资源紧张的情况更加稳定，
因此这里修改各个节点上docker的cgroup driver为systemd

    cat >> /etc/docker/daemon.json <<EOF
    {
      "exec-opts": ["native.cgroupdriver=systemd"]
    }
    EOF
    
重启
    
    systemctl restart docker
    
#### 所有节点安装kubeadm和kubelet

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

    yum install -y epel-release conntrack jq sysstat curl iptables libseccomp yum-utils device-mapper-persistent-data lvm2
    
安装kubelet等

    yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    
安装命令补全

    yum install -y bash-completion
    source /usr/share/bash-completion/bash_completion
    source <(kubectl completion bash)
    echo "source <(kubectl completion bash)" >> ~/.bashrc
    
修改kubelet配置

    sed -i "s;KUBELET_EXTRA_ARGS=;KUBELET_EXTRA_ARGS=\"--fail-swap-on=false\";g" /etc/sysconfig/kubelet
    
启动kubelet

    systemctl enable --now kubelet
    
下载k8s相关镜像

    for i in `kubeadm config images list 2>/dev/null |sed 's/k8s.gcr.io\///g'`; do
        docker pull gcr.azk8s.cn/google-containers/${i}
        docker tag gcr.azk8s.cn/google-containers/${i} k8s.gcr.io/${i}
        docker rmi gcr.azk8s.cn/google-containers/${i}
    done
    
配置时钟同步

    yum -y install ntpdate
    ntpdate ntp1.aliyun.com
    echo "*/5 * * * * bash ntpdate ntp1.aliyun.com" >> /etc/crontab
    
修改时区

    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    
#### 配置负载均衡

**keepalived+haproxy方式**

所有节点安装harproxy

    yum -y install haproxy
    
修改配置文件

    vim /etc/haproxy/haproxy.cfg
    
添加以下配置

    frontend kubernetes-apiserver
        mode                 tcp
        bind                 *:8443
        option               tcplog
        default_backend      kubernetes-apiserver
    backend kubernetes-apiserver
        mode        tcp
        balance     roundrobin
        server      node1 172.16.145.160:6443 check
        server      node2 172.16.145.161:6443 check
        server      node3 172.16.145.162:6443 check
      
        
启动

    systemctl enable haproxy --now

安装keepalived

    yum install -y keepalived
    
node1节点配置

    cat > /etc/keepalived/keepalived.conf <<-'EOF'
    ! Configuration File for keepalived
    
    global_defs {
       router_id k8s-master01
    }
    
    vrrp_instance VI_1 {
        state MASTER
        interface ens33
        virtual_router_id 51
        priority 150
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass weiliang
        }
        virtual_ipaddress {
            172.16.145.200/24
        }
    }
    EOF
    
node2节点配置

    cat > /etc/keepalived/keepalived.conf <<-'EOF'
    ! Configuration File for keepalived
    
    global_defs {
       router_id k8s-master02
    }
    
    vrrp_instance VI_1 {
        state BAKUP
        interface ens33
        virtual_router_id 51
        priority 150
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass weiliang
        }
        virtual_ipaddress {
            172.16.145.200/24
        }
    }
    EOF
    
node3节点配置

    cat > /etc/keepalived/keepalived.conf <<-'EOF'
    ! Configuration File for keepalived
    
    global_defs {
       router_id k8s-master03
    }
    
    vrrp_instance VI_1 {
        state BAKUP
        interface ens33
        virtual_router_id 51
        priority 150
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass weiliang
        }
        virtual_ipaddress {
            172.16.145.200/24
        }
    }
    EOF
    
启动keepalived

    systemctl enable keepalived --now
    
#### 创建集群

节点1初始化

    kubeadm init --control-plane-endpoint "172.16.145.200:8443" --upload-certs --ignore-preflight-errors=Swap
 
所有节点执行配置授权

    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
     
配置网络

    kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml

根据init输出信息，获取到tocken等信息进行节点添加
  
- 其他master节点加入


    kubeadm join 172.16.145.200:8443 --token awtvoq.ljszotcg6j99uy66 \
        --discovery-token-ca-cert-hash sha256:7e902395862e37d768dc4df48300013ad5571902a52302b2443856fa565fd657 \
        --control-plane --certificate-key dcd50768c16c5f124b86248820eca802f44ed1e9e4f546661e0f4d81750ee7fa
    
- 其他node节点加入集群


    kubeadm join 172.16.145.200:8443 --token awtvoq.ljszotcg6j99uy66 \
        --discovery-token-ca-cert-hash sha256:7e902395862e37d768dc4df48300013ad5571902a52302b2443856fa565fd657

node2 node3加入集群成为control-plane

    kubeadm join 172.16.145.200:8443 --token awtvoq.ljszotcg6j99uy66 \
            --discovery-token-ca-cert-hash sha256:7e902395862e37d768dc4df48300013ad5571902a52302b2443856fa565fd657 \
            --control-plane --certificate-key dcd50768c16c5f124b86248820eca802f44ed1e9e4f546661e0f4d81750ee7fa
    
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config  
   
#### 新worker节点加入集群

[配置yum源](/linux/package/yum.md)

可选

- [升级内核](/linux/update/kernel.md)

[安装docker](/os/virtaul/containerontainer/docker/docker-install-online.md)

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
    
配置k8s源

    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
    enabled=1t
    gpgcheck=0
    repo_gpgcheck=0
    gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
            http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    EOF
    
    yum clean all && yum makecache 
    
安装依赖

    yum install -y epel-release conntrack ipvsadm ipset jq sysstat curl iptables libseccomp yum-utils device-mapper-persistent-data lvm2

安装kubelet等

    yum install -y kubelet kubeadm --disableexcludes=kubernetes
    
安装命令补全

    yum install -y bash-completion
    source /usr/share/bash-completion/bash_completion
    source <(kubectl completion bash)
    echo "source <(kubectl completion bash)" >> ~/.bashrc
    
下载k8s相关镜像

    #k8s.gcr.io被墙，需要走微软代理地址
    for i in `kubeadm config images list 2>/dev/null |sed 's/k8s.gcr.io\///g'`; do
        docker pull gcr.azk8s.cn/google-containers/${i}
        docker tag gcr.azk8s.cn/google-containers/${i} k8s.gcr.io/${i}
        docker rmi gcr.azk8s.cn/google-containers/${i}
    done
  
配置时钟同步

    yum -y install ntpdate
    ntpdate ntp1.aliyun.com
    echo "*/5 * * * * bash ntpdate ntp1.aliyun.com" >> /etc/crontab
    
修改时区

```shell
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```
      
修改kubelet配置

    sed -i "s;KUBELET_EXTRA_ARGS=;KUBELET_EXTRA_ARGS=\"--fail-swap-on=false\";g" /etc/sysconfig/kubelet

启动kubelet

    systemctl enable --now kubelet
    
获取加入集群的token等

    kubeadm token create --print-join-command
          
设置Hostname

    hostnamectl --static set-hostname work1
          
查看节点信息

    kubectl get node
    
![](images/work-node.png)

重复添加解决

    https://blog.csdn.net/wzygis/article/details/84098247

   

    