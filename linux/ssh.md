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
