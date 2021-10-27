- [安装](#%E5%AE%89%E8%A3%85)
  - [升级内核](#%E5%8D%87%E7%BA%A7%E5%86%85%E6%A0%B8)
  - [在线安装](#%E5%9C%A8%E7%BA%BF%E5%AE%89%E8%A3%85)
    - [配置`yum`源](#%E9%85%8D%E7%BD%AEyum%E6%BA%90)
    - [配置yum代理](#%E9%85%8D%E7%BD%AEyum%E4%BB%A3%E7%90%86)
    - [清理旧版本docker](#%E6%B8%85%E7%90%86%E6%97%A7%E7%89%88%E6%9C%ACdocker)
    - [安装docker](#%E5%AE%89%E8%A3%85docker)
  - [配置docker](#%E9%85%8D%E7%BD%AEdocker)
    - [关闭selinux](#%E5%85%B3%E9%97%ADselinux)
    - [调整系统参数](#%E8%B0%83%E6%95%B4%E7%B3%BB%E7%BB%9F%E5%8F%82%E6%95%B0)
    - [配置阿里云加速](#%E9%85%8D%E7%BD%AE%E9%98%BF%E9%87%8C%E4%BA%91%E5%8A%A0%E9%80%9F)
  - [启动](#%E5%90%AF%E5%8A%A8)

# 安装

![](assets/laurel-docker-containers.png)

## 升级内核

建议[升级内核](/os/upgrade/kernel.md) ，以便使用新特性

## 在线安装

### 配置`yum`源

`yum`可用跳过

- `CentOS 7`

```
rm -f /etc/yum.repos.d/*
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
```

### 配置yum代理

宿主机可直接访问互联网情况跳过

> 配置代理

    vi /etc/yum.conf
    
文件最后添加以下内容

    proxy=http://username:password@host:port
    
- username: http代理账号
- password: http代理密码
- host: http代理主机（ip或域名）
- port: http代理端口

### 清理旧版本docker

```bash
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
```
    
### 安装docker

以下安装方式：二选一

> 安装最新版

```bash
yum -y install yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum -y install docker-ce
```

> 安装指定版本

查看可选版本

```bash
[root@localhost ~]# yum list docker-ce --showduplicates|sort -r
 * updates: mirrors.aliyun.com
Loading mirror speeds from cached hostfile
Loaded plugins: fastestmirror
 * extras: mirrors.aliyun.com
docker-ce.x86_64            3:20.10.7-3.el7                     docker-ce-stable
docker-ce.x86_64            3:20.10.6-3.el7                     docker-ce-stable
docker-ce.x86_64            3:20.10.5-3.el7                     docker-ce-stable
docker-ce.x86_64            3:20.10.4-3.el7                     docker-ce-stable
docker-ce.x86_64            3:20.10.3-3.el7                     docker-ce-stable
docker-ce.x86_64            3:20.10.2-3.el7                     docker-ce-stable
docker-ce.x86_64            3:20.10.1-3.el7                     docker-ce-stable
docker-ce.x86_64            3:20.10.0-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.9-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.8-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.7-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.6-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.5-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.4-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.3-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.2-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.15-3.el7                    docker-ce-stable
docker-ce.x86_64            3:19.03.14-3.el7                    docker-ce-stable
docker-ce.x86_64            3:19.03.1-3.el7                     docker-ce-stable
docker-ce.x86_64            3:19.03.13-3.el7                    docker-ce-stable
docker-ce.x86_64            3:19.03.12-3.el7                    docker-ce-stable
docker-ce.x86_64            3:19.03.11-3.el7                    docker-ce-stable
docker-ce.x86_64            3:19.03.10-3.el7                    docker-ce-stable
docker-ce.x86_64            3:19.03.0-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.9-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.8-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.7-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.6-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.5-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.4-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.3-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.2-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.1-3.el7                     docker-ce-stable
docker-ce.x86_64            3:18.09.0-3.el7                     docker-ce-stable
docker-ce.x86_64            18.06.3.ce-3.el7                    docker-ce-stable
docker-ce.x86_64            18.06.2.ce-3.el7                    docker-ce-stable
docker-ce.x86_64            18.06.1.ce-3.el7                    docker-ce-stable
docker-ce.x86_64            18.06.0.ce-3.el7                    docker-ce-stable
docker-ce.x86_64            18.03.1.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            18.03.0.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.12.1.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.12.0.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.09.1.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.09.0.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.06.2.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.06.1.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.06.0.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.03.3.ce-1.el7                    docker-ce-stable
docker-ce.x86_64            17.03.2.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.03.1.ce-1.el7.centos             docker-ce-stable
docker-ce.x86_64            17.03.0.ce-1.el7.centos             docker-ce-stable```
```

安装指定版本

```bash
yum install -y docker-ce-19.03.15-3.el7
```

## 配置docker

### 关闭selinux

```bash
setenforce 0
sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
```
    
### 调整系统参数

```bash
sed -i ':a;$!{N;ba};s@# docker limit BEGIN.*# docker limit END@@' /etc/security/limits.conf

cat <<EOF >> /etc/security/limits.conf
# docker limit BEGIN
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
# docker limit END
EOF

sed -i "/user.max_user_namespaces/d" /etc/sysctl.conf
echo "user.max_user_namespaces=15000" >> /etc/sysctl.conf
sysctl -p
ulimit -u 65535
ulimit -n 65535

echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-arptables = 1' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf
echo 'vm.swappiness = 1' >> /etc/sysctl.conf
echo 'fs.inotify.max_user_instances = 524288' >> /etc/sysctl.conf
#See https://imroc.io/posts/kubernetes/troubleshooting-with-kubernetes-network/
sed -r -i "s@#{0,}?net.ipv4.tcp_tw_recycle ?= ?(0|1)@net.ipv4.tcp_tw_recycle = 0@g" /etc/sysctl.conf
sed -r -i  "s@#{0,}?net.ipv4.ip_forward ?= ?(0|1)@net.ipv4.ip_forward = 1@g" /etc/sysctl.conf
sed -r -i  "s@#{0,}?net.bridge.bridge-nf-call-arptables ?= ?(0|1)@net.bridge.bridge-nf-call-arptables = 1@g" /etc/sysctl.conf
sed -r -i  "s@#{0,}?net.bridge.bridge-nf-call-ip6tables ?= ?(0|1)@net.bridge.bridge-nf-call-ip6tables = 1@g" /etc/sysctl.conf
sed -r -i  "s@#{0,}?net.bridge.bridge-nf-call-iptables ?= ?(0|1)@net.bridge.bridge-nf-call-iptables = 1@g" /etc/sysctl.conf
sed -r -i  "s@#{0,}?vm.max_map_count ?= ?(0|1)@vm.max_map_count = 262144@g" /etc/sysctl.conf
sed -r -i  "s@#{0,}?vm.swappiness ?= ?(0|1)@vm.swappiness = 1@g" /etc/sysctl.conf
sed -r -i  "s@#{0,}?fs.inotify.max_user_instances ?= ?(0|1)@fs.inotify.max_user_instances = 524288@g" /etc/sysctl.conf
awk ' !x[$0]++{print > "/etc/sysctl.conf"}' /etc/sysctl.conf
```
    
> 配置`docker daemon`

```bash
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "log-opts": {
    "max-size": "10m",
    "max-file":"3"
  },
  "userland-proxy": false,
  "live-restore": true,
  "default-ulimits": {
    "nofile": {
      "Hard": 65535,
      "Name": "nofile",
      "Soft": 65535
    }
  },
  "default-address-pools": [
    {
      "base": "172.80.0.0/16",
      "size": 24
    },
    {
      "base": "172.90.0.0/16",
      "size": 24
    }
  ],
  "no-new-privileges": false,
  "default-gateway": "",
  "default-gateway-v6": "",
  "default-runtime": "runc",
  "default-shm-size": "64M",
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```

### 配置阿里云加速

可选

> 调整`/etc/docker/daemon.json`

添加如下内容

```bash
"registry-mirrors": ["https://jz73200c.mirror.aliyuncs.com"]
```

重启

```shell
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 启动

```bash
systemctl daemon-reload
systemctl enable docker --now
```
   