### ceph本地源

**适用无法直连或通过代理连接互联网镜像源**

- 联网主机：用于导出`ceph`依赖,操作系统为`CentOS7`
- 离线主机：实际部署`ceph`应用的主机(多节点实例)

> 依赖导出（联网主机）

```shell
rm -f /etc/yum.repos.d/*.repo
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo

yum update -y
yum install yum-plugin-downloadonly -y
yum install --downloadonly --downloaddir=./ceph ceph ceph-common ceph-deploy
```

> 生成`repo`依赖关系（联网主机）

```shell
yum install -y createrepo
createrepo ./ceph
```

> 压缩（联网主机）

```shell
tar zcvf ceph.tar.gz ceph
```

> 配置使用（离线主机）

```shell
tar zxvf ceph.tar.gz -C /
    
cat > /etc/yum.repos.d/ceph.repo <<EOF
[ceph]
name=python-repo
baseurl=file:///ceph
gpgcheck=0
enabled=1
EOF
yum install -y ceph ceph-deploy ceph-common
```