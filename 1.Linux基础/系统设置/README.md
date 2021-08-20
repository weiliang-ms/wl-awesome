<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [系统设置](#%E7%B3%BB%E7%BB%9F%E8%AE%BE%E7%BD%AE)
  - [参数设置](#%E5%8F%82%E6%95%B0%E8%AE%BE%E7%BD%AE)
    - [时钟服务器配置](#%E6%97%B6%E9%92%9F%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE)
    - [时区配置](#%E6%97%B6%E5%8C%BA%E9%85%8D%E7%BD%AE)
    - [关闭防火墙](#%E5%85%B3%E9%97%AD%E9%98%B2%E7%81%AB%E5%A2%99)
    - [关闭`selinux`](#%E5%85%B3%E9%97%ADselinux)
    - [调整文件描述符等](#%E8%B0%83%E6%95%B4%E6%96%87%E4%BB%B6%E6%8F%8F%E8%BF%B0%E7%AC%A6%E7%AD%89)
    - [配置`yum`本地源](#%E9%85%8D%E7%BD%AEyum%E6%9C%AC%E5%9C%B0%E6%BA%90)
    - [配置`sudo`用户](#%E9%85%8D%E7%BD%AEsudo%E7%94%A8%E6%88%B7)
    - [配置互信](#%E9%85%8D%E7%BD%AE%E4%BA%92%E4%BF%A1)
    - [关闭图形化](#%E5%85%B3%E9%97%AD%E5%9B%BE%E5%BD%A2%E5%8C%96)
    - [配置hostname](#%E9%85%8D%E7%BD%AEhostname)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 系统设置

## 参数设置

### 时钟服务器配置

至少保证`5`分钟同步一次

```shell
*/5 * * * * ntpdate ntp-server
```

### 时区配置

配置为上海时区

```shell
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### 关闭防火墙

```shell
systemctl disable firewalld --now
```

### 关闭`selinux`

```shell
setenforce 0
sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
```

### 调整文件描述符等

```shell
cat >> /etc/pam.d/login <<EOF
session    required     /lib64/security/pam_limits.so
session    required     pam_limits.so
EOF

scp /etc/security/limits.conf /etc/security/limits.conf.bak
true > /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
*   soft   nofile   65536
*   hard   nofile   65536
*   soft   nproc    16384
*   hard   nproc    16384
*   soft   stack    10240
*   hard   stack    32768
EOF

scp /etc/security/limits.d/20-nproc.conf /etc/security/limits.d/20-nproc.conf.bak
true > /etc/security/limits.d/20-nproc.conf
cat >> /etc/security/limits.d/20-nproc.conf<<EOF
*          soft    nproc    unlimited
*          hard    nproc    unlimited
EOF

echo 8061540 > /proc/sys/fs/file-max
```

### 配置`yum`本地源

```shell
rm -rf /etc/yum.repos.d/*
mount -o loop CentOS-7-x86_64-DVD-2009.iso /media
mkdir -p /yum
cp -r /media/* /yum
umount /media
rm -f CentOS-7-x86_64-DVD-2009.iso
```

配置文件

```shell
cat > /etc/yum.repos.d/c7.repo <<EOF
[c7repo]
name=c7repo
baseurl=file:///yum
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
```

### 配置`sudo`用户

[强密码生成](https://tool.ip138.com/random/)

或利用以下指令生成

```shell
pwmake 128
```

初始化用户，配置sudo权限

```shell
useradd -m neusoft && echo "m&t+arz4SEvWq5)QG" | passwd --stdin neusoft
echo "neusoft        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
```

### 配置互信

配置`root`用户

```shell
ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa
cat .ssh/id_rsa.pub > ~/.ssh/authorized_keys
chmod -R 600 ~/.ssh
```

### 关闭图形化

centos7

```bash
systemctl set-default multi-user.target
init 3
```
    
### 配置hostname

- 方法一

```shell
cat >> /etc/sysconfig/network <<EOF
HOSTNAME=oracle
EOF
echo oracle >/proc/sys/kernel/hostname
```

- 方法二

```shell
cat >> /etc/sysconfig/network <<EOF
HOSTNAME=oracle
EOF
sysctl kernel.hostname=oracle
```

- 方法三

```shell
cat >> /etc/sysconfig/network <<EOF
HOSTNAME=oracle
EOF
hostname oracle
```
	
- 方法四

```shell
hostnamectl --static set-hostname master
```
