# 容器安全

基于`Docker 19.03.8`

## 主机安全配置

### 为docker挂载单独存储目录

- 分析


默认安装情况下，所有`Docker`容器及数据、元数据存储于`/var/lib/docker`下

- 审计方式


`Docker`依赖于`/var/lib/docker`作为默认数据目录，该目录存储所有相关文件，包括镜像文件。
该目录可能会被恶意的写满，导致`Docker`、甚至主机可能无法使用。因此，建议为`Docker`存储目录配置独立挂载点（最好为独立数据盘）

- 修复实践

> `docker`宿主机增加数据盘`/dev/sdb`

```shell script
[root@localhost ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0   30G  0 disk
sr0              11:0    1  4.4G  0 rom
```

> 格式化数据盘

```shell script
[root@localhost ~]# mkfs.ext4 /dev/sdb
mke2fs 1.42.9 (28-Dec-2013)
/dev/sdb is entire device, not just one partition!
Proceed anyway? (y,n) y
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
1966080 inodes, 7864320 blocks
393216 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2155872256
240 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done
```

> 配置`/dev/sdb`挂载点为`/var/lib/docker`

**该步骤建议安装`docker`之后进行**

```shell script
echo "/dev/sdb /var/lib/docker ext4 defaults 0 0" >> /etc/fstab
```

> 重启主机测试是否生效

```shell script
[root@localhost ~]# reboot
[root@localhost ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0   30G  0 disk /var/lib/docker
sr0              11:0    1  4.4G  0 rom
[root@localhost ~]# docker images
REPOSITORY                         TAG       IMAGE ID       CREATED        SIZE
harbor.wl.com/public/alpine   latest    d6e46aa2470d   6 months ago   5.57MB
```

### 容器宿主机加固

- 分析

容器在`Linux`主机上运行，容器宿主机可以运行一个或多个容器。
加强主机以缓解主机安全配置错误是非常重要的

- 审计方式

确保遵守主机的安全规范。询问系统管理员当前主机系统符合哪个安全标准。确保主机系统实际符合主机制定的安全规范

- 修复建议

参考`Linux`主机安全加固规范。

### 更新Docker到最新版本

- 分析

`Docker`软件频繁发布更新，旧版本可能存在安全漏洞

- 审计

查看[release](https://github.com/moby/moby/releases) 与本地版本比较

```shell script
docker version
```

- 风险评估

不要盲目升级`docker`版本，评估升级是否会对现有系统产生影响，充分测试其兼容性（如与`k8s kubeadm`兼容性）

- 修复实践

```shell script
#安装一些必要的系统工具
yum -y install yum-utils device-mapper-persistent-data lvm2

#添加软件源信息
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#更新 yum 缓存
yum makecache fast

#安装docker-ce
yum -y install docker-ce
# 或更新
yum -y update docker-ce
```

### 只有受信任的用户才能控制Docker守护进程

- 分析

`Docker`守护进程需要`root`权限。对于添加到`Docker`组的用户，
为其提供了完整的`root`访问权限。

- 隐患

`Docker`允许在宿主机和访客容器之间共享目录，而不会限制容器的访问权限。
这意味着可以启动容器并将主机上的`/`目录映射到容器。
容器将能够不受任何限制地更改您的主机文件系统。 简而言之，这意味着您只需作为`Docker`组的成员即可获得较高的权限，然后在主机上启动具有映射`/`目录的容器。

- 审计方式

```shell script
[root@localhost ~]# yum install glibc-common -y -q
[root@localhost ~]# getent group docker
docker:x:994:
```

- 结果判定

查看`审计`步骤中的返回值是否含有非信任用户

- 修复建议

从`docker`组中删除任何不受信任的用户。另外，请勿在主机上创建敏感目录到容器卷的映射

## docker守护进程配置

### 不适用不安全的镜像仓库

- 分析

`Docker`在默认情况下，私有仓库被认为是安全的

- 安全隐患

一个安全的镜像仓库建议使用`TLS`。 在`/etc/docker/certs.d/<registry-name>/`目录下，将镜像仓库的`CA`证书副本放置在`Docker`主机上。
不安全的镜像仓库是没有有效的镜像仓库证书或不使用`TLS`的镜像仓库。不应该在生产环境中使用任何不安全的镜像仓库。
不安全的镜像仓库中的镜像可能会被篡改，从而导致生产系统可能受到损害。
此外，如果镜像仓库被标记为不安全，则`docker pull`，`docker push`和`docker push`命令并不能发现，
那样用户可能无限期地使用不安全的镜像仓库而不会发现。

- 审计方式

```shell script
[root@localhost ~]# cat /etc/docker/daemon.json |grep insecure-registries
     "insecure-registries":["gcr.azk8s.cn","dockerhub.azk8s.cn","quay.azk8s.cn","5twf62k1.mirror.aliyuncs.com","registry.docker-cn.com","registry-1.docker.io"],
```

- 修复建议

使用`ssl`签名的镜像仓库（如配置`ssl`证书的`harbor`）

### 不使用aufs存储驱动程序

- 分析

`aufs`存储驱动程序是较旧的存储驱动程序。 它基于`Linux`内核补丁集，不太可能合并到主版本`Linux`内核中。 
`aufs`驱动会导致一些严重的内核崩溃。`aufs`在`Docker`中只是保留了历史遗留支持,现在主要使用`overlay2`和`devicemapper`。
而且最重要的是，在许多使用最新`Linux`内核的发行版中，`aufs`不再被支持

- 审计方式

```shell script
docker info |grep -e "^Storage Driver:"
```


