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

    mkdir -p /etc/ceph
    
从服务端`scp`以下文件至客户端/etc/ceph下

- /etc/ceph/ceph.client.admin.keyring
- /etc/ceph/ceph.conf

    
    scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} ip:/etc/ceph/
    
> 创建块设备(客户端执行)

    rbd create --pool ybpool --image yb-27 --image-format 2 --image-feature layering --size 100G

> 映射块设备

    rbd map ybpool/yb-27
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
    
> 配置开机自启动

    vim /etc/init.d/rbdmap
    
    #!/bin/bash
    #chkconfig: 2345 80 60
    #description: start/stop rbdmap
    ### BEGIN INIT INFO
    # Provides:          rbdmap
    # Required-Start:    $network
    # Required-Stop:     $network
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: Ceph RBD Mapping
    # Description:       Ceph RBD Mapping
    ### END INIT INFO
    
    DESC="RBD Mapping"
    RBDMAPFILE="/etc/ceph/rbdmap"
    
    . /lib/lsb/init-functions
    #. /etc/redhat-lsb/lsb_log_message，加入此行后不正长
    do_map() {
        if [ ! -f "$RBDMAPFILE" ]; then
            echo "$DESC : No $RBDMAPFILE found."
            exit 0
        fi
    
        echo "Starting $DESC"
        # Read /etc/rbdtab to create non-existant mapping
        newrbd=
        RET=0
        while read DEV PARAMS; do
            case "$DEV" in
              ""|\#*)
                continue
                ;;
              */*)
                ;;
              *)
                DEV=rbd/$DEV
                ;;
            esac
            OIFS=$IFS
            IFS=','
            for PARAM in ${PARAMS[@]}; do
                CMDPARAMS="$CMDPARAMS --$(echo $PARAM | tr '=' ' ')"
            done
            IFS=$OIFS
            if [ ! -b /dev/rbd/$DEV ]; then
                echo $DEV
                rbd map $DEV $CMDPARAMS
                [ $? -ne "0" ] && RET=1
                newrbd="yes"
            fi
        done < $RBDMAPFILE
        echo $RET
    
        # Mount new rbd
        if [ "$newrbd" ]; then
                    echo "Mounting all filesystems"
            mount -a
            echo $?
        fi
    }
    
    do_unmap() {
        echo "Stopping $DESC"
        RET=0
        # Unmap all rbd device
        for DEV in /dev/rbd[0-9]*; do
            echo $DEV
            # Umount before unmap
            MNTDEP=$(findmnt --mtab --source $DEV --output TARGET | sed 1,1d | sort -r)
            for MNT in $MNTDEP; do
                umount $MNT || sleep 1 && umount -l $DEV
            done
            rbd unmap $DEV
            [ $? -ne "0" ] && RET=1
        done
        echo $RET
    }
    
    
    case "$1" in
      start)
        do_map
        ;;
    
      stop)
        do_unmap
        ;;
    
      reload)
        do_map
        ;;
    
      status)
        rbd showmapped
        ;;
    
      *)
        echo "Usage: rbdmap {start|stop|reload|status}"
        exit 1
        ;;
    esac
    
    exit 0


赋权
    
    yum install redhat-lsb -y
    chmod +x /etc/init.d/rbdmap
    service rbdmap start 
    chkconfig rbdmap on
    
