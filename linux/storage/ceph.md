### ceph添加磁盘

> 列出节点`ceph01`磁盘信息

    ceph-deploy disk list ceph01
    
输出如下

    ...
    [ceph01][DEBUG ] /dev/dm-0 other, xfs, mounted on /
    [ceph01][DEBUG ] /dev/nvme0n1 other, ext4
    [ceph01][DEBUG ] /dev/nvme1n1 other, ext4
    [ceph01][DEBUG ] /dev/nvme2n1 other, ext4
    [ceph01][DEBUG ] /dev/nvme3n1 other, ext4
    [ceph01][DEBUG ] /dev/sda :
    [ceph01][DEBUG ]  /dev/sda3 other, LVM2_member
    [ceph01][DEBUG ]  /dev/sda1 other, vfat, mounted on /boot/efi
    [ceph01][DEBUG ]  /dev/sda2 other, xfs, mounted on /boot
    [ceph01][DEBUG ] /dev/sdb other, unknown
    [ceph01][DEBUG ] /dev/sdc other, ext4
    [ceph01][DEBUG ] /dev/sdd other, ext4
    [ceph01][DEBUG ] /dev/sde other, ext4
    [ceph01][DEBUG ] /dev/sdf other, ext4
    [ceph01][DEBUG ] /dev/sdg other, ext4
    [ceph01][DEBUG ] /dev/sdh other, ext4
    ...
    
> 擦净节点磁盘

    ceph-deploy disk zap ceph01:/dev/sdb ceph02:/dev/sdb ceph03:/dev/sdb 
    ceph-deploy disk zap ceph01:/dev/sdc ceph02:/dev/sdc ceph03:/dev/sdc
    ceph-deploy disk zap ceph01:/dev/sdd ceph02:/dev/sdd ceph03:/dev/sdd 
    ceph-deploy disk zap ceph01:/dev/sde ceph02:/dev/sde ceph03:/dev/sde 
    ceph-deploy disk zap ceph01:/dev/sdf ceph02:/dev/sdf ceph03:/dev/sdf 
    
    ceph-deploy disk zap ceph01:/dev/sdg
    ceph-deploy disk zap ceph01:/dev/sdh
    
> 创建OSD节点

    ceph-deploy osd create ceph01:/dev/sdb ceph02:/dev/sdb ceph03:/dev/sdb
    ceph-deploy osd create ceph01:/dev/sdc ceph02:/dev/sdc ceph03:/dev/sdc
    ceph-deploy osd create ceph01:/dev/sdd ceph02:/dev/sdd ceph03:/dev/sdd
    ceph-deploy osd create ceph01:/dev/sde ceph02:/dev/sde ceph03:/dev/sde
    ceph-deploy osd create ceph01:/dev/sdf ceph02:/dev/sdf ceph03:/dev/sdf
    
    ceph-deploy osd create ceph01:/dev/sdg
    ceph-deploy osd create ceph01:/dev/sdh
    
> 创建资源池

    ceph osd pool create {pool_name} {pg_num} [{pgp_num}]

> 归置组大小设置

确定 pg_num 取值是强制性的，因为不能自动计算。下面是几个常用的值：
    
- 少于 5 个 OSD 时可把 pg_num 设置为 128

- OSD 数量在 5 到 10 个时，可把 pg_num 设置为 512

- OSD 数量在 10 到 50 个时，可把 pg_num 设置为 4096

> 查看存储池统计信息

     rados df
     
### 块设备（rdb）

> 创建块设备，指定资源池

    rbd create foo-3 --size=100G --pool rbd2
    
> 查看块设备

    rbd list <poolname>
    
> 删除块设备

    rbd rm <poolname>/rbdname
    
### 客户端挂载块设备

> 配置yum

    cat > /etc/yum.repos.d/ceph.repo <<EOF
    [Ceph]
    name=Ceph packages for $basearch
    baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/x86_64/
    enabled=1
    gpgcheck=0
    type=rpm-md
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    priority=1
    
    [Ceph-noarch]
    name=Ceph noarch packages
    baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/noarch/
    enabled=1
    gpgcheck=0
    type=rpm-md
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    priority=1
    
    [ceph-source]
    name=Ceph source packages
    baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/SRPMS/
    enabled=1
    gpgcheck=0
    type=rpm-md
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    priority=1
    EOF

> 安装客户端

    yum install -y epel-release
    yum install -y ceph-common
    
> 拷贝配置文件

客户端创建目录

    /etc/ceph
    
从服务端`scp`以下文件至客户端/etc/ceph下

- /etc/ceph/ceph.client.admin.keyring
- /etc/ceph/ceph.conf

> 创建块设备(客户端执行)

    rbd create --pool ybpool --image yb-27 --image-format 2 --image-feature layering --size 100G

> 映射块设备

    rbd map ybpool/yb-27
    
配置自动映射

    echo "ybpool/yb-27 id=admin,keyring=/etc/ceph/ceph.client.admin.keyring" >> /etc/ceph/rbdmap
    
> 格式化块设备

     mkfs.ext4 -q /dev/rbd0
     
> 挂载使用

    mkdir -p /mnt/ceph-block-device
    mount /dev/rbd0 /mnt/ceph-block-device

> 查看挂载

    lsblk
 
> 修改fstab，设置开机挂载

    echo "/dev/rbd0 /mnt/ceph-block-device ext4 defaults,noatime,_netdev 0 0" >> /etc/fstab
    
