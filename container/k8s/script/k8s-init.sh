#!/bin/bash
# 格式为： http://username:password@ip:port
proxy=
ntpserver=
k8sversion=1.15.5
function configYum() {

  echo "[yum]删除已有yum源..."
  rm -f /etc/yum.repos.d/*
  echo "[yum]添加阿里云yum源..."
  cp *.repo /etc/yum.repos.d/
  echo "[yum]配置代理..."
  if [ "$proxy" != "" ]; then
    sed -i '/proxy/d' /etc/yum.conf
    echo "proxy=$proxy" >> /etc/yum.conf
  fi
  echo "[yum]清理yum缓存与更新..."
  yum clean all && yum makecache && yum update -y

}

function updateKernel() {
  echo "[kernel]导入公钥..."
  rpm --import ./RPM-GPG-KEY-elrepo.org
  echo "[kernel]添加源..."
  yum install ./elrepo-release-7.0-4.el7.elrepo.noarch.rpm -y
  echo "[kernel]安装lt版本内核..."
  yum -y --enablerepo=elrepo-kernel install kernel-lt.x86_64 kernel-lt-devel.x86_64
  echo "[kernel]删除旧版本内核..."
  yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64 -y
  echo "[kernel]安装内核工具..."
  yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-lt-tools.x86_64
  grub2-set-default 0
  echo "[reboot]重启..."
  reboot
}

function installDocker() {

  echo "[docker]删除旧版本docker..."
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

  echo "[yum]安装一些必要的系统工具..."
  yum -y install yum-utils device-mapper-persistent-data lvm2

  echo "[yum]添加软件源信息..."
  yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

  echo "[update yum]更新 yum 缓存..."
  yum makecache fast

  echo "[install Docker]安装docker-ce..."
  yum -y install docker-ce

  echo "[selinux]关闭selinux..."
  setenforce 0
  sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config

  echo "[docker]启动docker..."
  systemctl enable docker --now

  echo "[docker]调整docker驱动"
  sudo mkdir -p /etc/docker
  sudo tee /etc/docker/daemon.json <<EOF
    {
      "exec-opts": ["native.cgroupdriver=systemd"],
    }
EOF

  echo "[docker]重载docker"
  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

function modifySysconfig() {

  echo "[timezone]修改时区..."
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

  echo "[firewalld]关闭防火墙..."
  systemctl stop firewalld && systemctl disable firewalld

  echo "[swap]关闭swap..."
  swapoff -a
  sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  sysctl -p

  echo "[kernel]设置内核参数..."
  modprobe br_netfilter
  cat << EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF

  sysctl -p /etc/sysctl.d/k8s.conf

  #修改Linux 资源配置文件,调高ulimit最大打开数和systemctl管理的服务文件最大打开数
  echo "* soft nofile 655360" >> /etc/security/limits.conf
  echo "* hard nofile 655360" >> /etc/security/limits.conf
  echo "* soft nproc 655360" >> /etc/security/limits.conf
  echo "* hard nproc 655360" >> /etc/security/limits.conf
  echo "* soft memlock unlimited" >> /etc/security/limits.conf
  echo "* hard memlock unlimited" >> /etc/security/limits.conf
  echo "DefaultLimitNOFILE=1024000" >> /etc/systemd/system.conf
  echo "DefaultLimitNPROC=1024000" >> /etc/systemd/system.conf

  echo "[ipvs]所有节点安装ipvs管理工具..."
  yum install ipvsadm ipset -y
  echo "[ipvs]所有节点添加ipvs..."
  cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
  chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
}

function installK8s() {

  echo "[k8s]配置k8s源..."
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

  echo "[k8s]安装k8s..."
  yum install -y kubelet-$k8sversion kubeadm-$k8sversion kubectl-$k8sversion --disableexcludes=kubernetes

  echo "[kubelet]修改kubelet配置..."
  sed -i "s;KUBELET_EXTRA_ARGS=;KUBELET_EXTRA_ARGS=\"--fail-swap-on=false\";g" /etc/sysconfig/kubelet

  echo "[kubelet]启动kubelet..."
  systemctl enable --now kubelet

  echo "[completion]安装命令补全..."
  yum install -y bash-completion
  source /usr/share/bash-completion/bash_completion
  source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >> ~/.bashrc

}

function installNtp() {
    echo "[ntpdate]安装ntpdate..."
    yum install -y ntpdate
    ntpdate $ntpserver
    sed -i '/ntpdate/d' /etc/crontab
    echo "*/5 * * * * root ntpdate $ntpserver &> /dev/null" >> /etc/crontab
}

function main() {
    TYPE=$1
    case "$TYPE" in
	"k")
	  updateKernel
    ;;
  *)
    configYum
    installDocker
    modifySysconfig
    installK8s
  esac
}

main