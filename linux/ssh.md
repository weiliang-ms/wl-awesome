<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [更新openssh](#%E6%9B%B4%E6%96%B0openssh)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

https://www.cnblogs.com/pengyong1211/p/10308658.html


## 更新openssh

下载最新版,当前最新版本`openssh-8.2p1`（2020-03-06）

[openssh-8.2p1.tar.gz](https://openbsd.hk/pub/OpenBSD/OpenSSH/portable/openssh-8.2p1.tar.gz)

安装gcc

```bash
yum install -y gcc zlib-devel openssl-devel
```

上传解压,配置

```bash
tar zxvf openssh-8.2p1.tar.gz
cd openssh-8.2p1
./configure --prefix=/usr --sysconfdir=/etc/ssh
```

备份ssh配置

```bash
mkdir -p /etc/sshbak
mv  /etc/ssh/* /etc/sshbak/  
```

编译安装

```bash
make && make install
```
