## 为`docker`挂载单独存储目录

### 描述

默认安装情况下，所有`Docker`容器及数据、元数据存储于`/var/lib/docker`下

### 审计方式

`Docker`依赖于`/var/lib/docker`作为默认数据目录，该目录存储所有相关文件，包括镜像文件。
该目录可能会被恶意的写满，导致`Docker`、甚至主机可能无法使用。因此，建议为`Docker`存储目录配置独立挂载点（最好为独立数据盘）

### 修复建议

1. `docker`宿主机增加数据盘`/dev/sdb`

```bash
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

2. 格式化数据盘

```bash
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

3. 配置`/dev/sdb`挂载点为`/var/lib/docker`

**该步骤建议安装`docker`之后进行**

```bash
echo "/dev/sdb /var/lib/docker ext4 defaults 0 0" >> /etc/fstab
```

4. 重启主机测试是否生效

```bash
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

### 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)