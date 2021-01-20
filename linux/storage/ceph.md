<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [ceph-deploy部署N版](#ceph-deploy%E9%83%A8%E7%BD%B2n%E7%89%88)
- [ceph添加磁盘](#ceph%E6%B7%BB%E5%8A%A0%E7%A3%81%E7%9B%98)
- [crush pool](#crush-pool)
- [块设备（rdb）使用](#%E5%9D%97%E8%AE%BE%E5%A4%87rdb%E4%BD%BF%E7%94%A8)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### ceph-deploy部署N版

> 配置阿里云仓储

    cat > /etc/yum.repos.d/ceph.repo <<EOF
    [Ceph]
    name=Ceph \$basearch
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/\$basearch
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    
    [Ceph-noarch]
    name=Ceph noarch
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/noarch
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    
    [Ceph-source]
    name=Ceph SRPMS
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/SRPMS
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    EOF

> 创建ceph目录

    mkdir -p /etc/ceph/cluster
    
> 初始化mon节点

    cd /etc/ceph/cluster
    cephadm bootstrap --mon-ip 192.168.1.3 --skip-pull
    
> 进入ceph指令

    cephadm shell
    ceph -v 
    
![](images/cephadm-shell.png)

推出shell

    exit
    
> 安装ceph-cli

    cephadm add-repo --release octopus
    sed -i "s#download.ceph.com#mirrors.aliyun.com/ceph#g" /etc/yum.repos.d/ceph.repo
    cephadm install ceph-common
    
> 分发公钥至其他节点

    ceph cephadm get-pub-key > ~/ceph.pub
    ssh-copy-id -f -i ~/ceph.pub root@node4
    ssh-copy-id -f -i ~/ceph.pub root@node5
 
    
> 添加新节点至集群

    ceph orch host add node4
    ceph orch host add node5
    
> 设置public_work

    ceph config set mon public_network 192.168.1.0/24
    
> 设置三个节点Mon

    ceph orch apply mon 3
    ceph orch apply mon 192.168.174.108,192.168.174.109,192.168.174.110
    
> 安装命令补全

    yum -y install bash-completion
    
> 安装dashboard

1.安装

    yum install -y ceph-mgr-dashboard
    
2.禁用 SSL

    ceph config set mgr mgr/dashboard/ssl false

3.配置 host 和 port

    ceph config set mgr mgr/dashboard/server_addr $IP
    ceph config set mgr mgr/dashboard/server_port $PORT
    
4.启用 Dashboard

    ceph mgr module enable dashboard
    
5.用户、密码、权限

    # 创建用户
    #ceph dashboard ac-user-create <username> <password> administrator
    ceph dashboard ac-user-create admin Ceph-12345 administrator
    
6.查看 Dashboard 地址
  
    ceph mgr services
    
x.使变更的配置生效
    
    ceph mgr module disable dashboard
    ceph mgr module enable dashboard
    
xx.配置访问前缀
   
    ceph config set mgr mgr/dashboard/url_prefix /ceph-ui

### ceph添加磁盘

> 列出节点`node3`磁盘信息

    ceph-deploy disk list node3
    
输出如下

    ...
    [ceph_deploy.conf][DEBUG ] found configuration file at: /root/.cephdeploy.conf
    [ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list node3
    [ceph_deploy.cli][INFO  ] ceph-deploy options:
    [ceph_deploy.cli][INFO  ]  username                      : None
    [ceph_deploy.cli][INFO  ]  verbose                       : False
    [ceph_deploy.cli][INFO  ]  debug                         : False
    [ceph_deploy.cli][INFO  ]  overwrite_conf                : False
    [ceph_deploy.cli][INFO  ]  subcommand                    : list
    [ceph_deploy.cli][INFO  ]  quiet                         : False
    [ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f747adb66c8>
    [ceph_deploy.cli][INFO  ]  cluster                       : ceph
    [ceph_deploy.cli][INFO  ]  host                          : ['node3']
    [ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7f747b00a938>
    [ceph_deploy.cli][INFO  ]  ceph_conf                     : None
    [ceph_deploy.cli][INFO  ]  default_release               : False
    [node3][DEBUG ] connected to host: node3
    [node3][DEBUG ] detect platform information from remote host
    [node3][DEBUG ] detect machine type
    [node3][DEBUG ] find the location of an executable
    [node3][INFO  ] Running command: fdisk -l
    [node3][INFO  ] Disk /dev/nvme1n1: 2000.4 GB, 2000398934016 bytes, 3907029168 sectors
    [node3][INFO  ] Disk /dev/nvme0n1: 2000.4 GB, 2000398934016 bytes, 3907029168 sectors
    [node3][INFO  ] Disk /dev/nvme2n1: 2000.4 GB, 2000398934016 bytes, 3907029168 sectors
    [node3][INFO  ] Disk /dev/nvme3n1: 2000.4 GB, 2000398934016 bytes, 3907029168 sectors
    [node3][INFO  ] Disk /dev/mapper/centos00-root: 1998.0 GB, 1998036402176 bytes, 3902414848 sectors
    [node3][INFO  ] Disk /dev/sdf: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdg: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdb: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sde: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdk: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sda: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdd: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdh: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdj: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdc: 960.2 GB, 960197124096 bytes, 1875385008 sectors
    [node3][INFO  ] Disk /dev/sdi: 480.1 GB, 480103981056 bytes, 937703088 sectors
    ...
 
> 查看磁盘挂载

    lsblk
    
输出如下

    NAME              MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sdf                 8:80   0 894.3G  0 disk
    nvme0n1           259:1    0   1.8T  0 disk
    ├─nvme0n1p3       259:6    0   1.8T  0 part
    │ └─centos00-root 253:0    0   1.8T  0 lvm  /
    ├─nvme0n1p1       259:4    0   200M  0 part /boot/efi
    └─nvme0n1p2       259:5    0     2G  0 part /boot
    sdd                 8:48   0 894.3G  0 disk
    nvme3n1           259:3    0   1.8T  0 disk
    sdb                 8:16   0 894.3G  0 disk
    sdk                 8:160  0 894.3G  0 disk
    sdi                 8:128  0 447.1G  0 disk
    nvme2n1           259:2    0   1.8T  0 disk
    sr0                11:0    1   4.2G  0 rom
    sdg                 8:96   0 894.3G  0 disk
    sde                 8:64   0 894.3G  0 disk
    sdc                 8:32   0 894.3G  0 disk
    nvme1n1           259:0    0   1.8T  0 disk
    sda                 8:0    0 894.3G  0 disk
    sdj                 8:144  0 894.3G  0 disk
    sdh                 8:112  0 894.3G  0 disk
    
磁盘类型说明

    sda-sdk 为ssd类型，sda先不加入集群
    nvme0n1、nvme1n1、nvme2n1、nvme3n1为nvme类型
    系统盘：nvme0n1
   
    
> 擦净节点ssd类型磁盘

    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy disk zap node3 /dev/sd$i
    done
    
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy disk zap node4 /dev/sd$i
    done
    
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy disk zap node5 /dev/sd$i
    done
    
> 创建ssd类型OSD节点
 
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy osd create --data /dev/sd$i node3
    done
    
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy osd create --data /dev/sd$i node4
    done
        
    cd /etc/ceph/cluster
    for i in {b..k};do
    ceph-deploy osd create --data /dev/sd$i node5
    done
    
> 擦净节点nvme类型磁盘

    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy disk zap node3 /dev/nvme${i}n1
    done
    
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy disk zap node4 /dev/nvme${i}n1
    done
    
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy disk zap node5 /dev/nvme${i}n1
    done
    
> 创建nvme类型OSD节点
 
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy osd create --data /dev/nvme${i}n1 node3
    done
    
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy osd create --data /dev/nvme${i}n1 node4
    done
        
    cd /etc/ceph/cluster
    for i in {1..3};do
    ceph-deploy osd create --data /dev/nvme${i}n1 node5
    done
    
> 查看集群osd crush tree

    cd /etc/ceph/cluster
    ceph osd crush tree --show-shadow
    
回显如下

    ID CLASS WEIGHT   TYPE NAME
    -2   ssd 41.26323 root default~ssd
    -4   ssd 13.75441     host node3~ssd
     0   ssd  0.87329         osd.0
     1   ssd  0.87329         osd.1
     2   ssd  0.87329         osd.2
     3   ssd  0.87329         osd.3
     4   ssd  0.87329         osd.4
     5   ssd  0.87329         osd.5
     6   ssd  0.87329         osd.6
     7   ssd  0.43660         osd.7
     8   ssd  0.87329         osd.8
     9   ssd  0.87329         osd.9
    30   ssd  1.81940         osd.30
    31   ssd  1.81940         osd.31
    32   ssd  1.81940         osd.32
    -6   ssd 13.75441     host node4~ssd
    10   ssd  0.43660         osd.10
    11   ssd  0.87329         osd.11
    12   ssd  0.87329         osd.12
    13   ssd  0.87329         osd.13
    14   ssd  0.87329         osd.14
    15   ssd  0.87329         osd.15
    16   ssd  0.87329         osd.16
    17   ssd  0.87329         osd.17
    18   ssd  0.87329         osd.18
    19   ssd  0.87329         osd.19
    33   ssd  1.81940         osd.33
    34   ssd  1.81940         osd.34
    35   ssd  1.81940         osd.35
    -8   ssd 13.75441     host node5~ssd
    20   ssd  0.43660         osd.20
    21   ssd  0.87329         osd.21
    22   ssd  0.87329         osd.22
    23   ssd  0.87329         osd.23
    24   ssd  0.87329         osd.24
    25   ssd  0.87329         osd.25
    26   ssd  0.87329         osd.26
    27   ssd  0.87329         osd.27
    28   ssd  0.87329         osd.28
    29   ssd  0.87329         osd.29
    36   ssd  1.81940         osd.36
    37   ssd  1.81940         osd.37
    38   ssd  1.81940         osd.38
    -1       41.26323 root default
    -3       13.75441     host node3
     0   ssd  0.87329         osd.0
     1   ssd  0.87329         osd.1
     2   ssd  0.87329         osd.2
     3   ssd  0.87329         osd.3
     4   ssd  0.87329         osd.4
     5   ssd  0.87329         osd.5
     6   ssd  0.87329         osd.6
     7   ssd  0.43660         osd.7
     8   ssd  0.87329         osd.8
     9   ssd  0.87329         osd.9
    30   ssd  1.81940         osd.30
    31   ssd  1.81940         osd.31
    32   ssd  1.81940         osd.32
    -5       13.75441     host node4
    10   ssd  0.43660         osd.10
    11   ssd  0.87329         osd.11
    12   ssd  0.87329         osd.12
    13   ssd  0.87329         osd.13
    14   ssd  0.87329         osd.14
    15   ssd  0.87329         osd.15
    16   ssd  0.87329         osd.16
    17   ssd  0.87329         osd.17
    18   ssd  0.87329         osd.18
    19   ssd  0.87329         osd.19
    33   ssd  1.81940         osd.33
    34   ssd  1.81940         osd.34
    35   ssd  1.81940         osd.35
    -7       13.75441     host node5
    20   ssd  0.43660         osd.20
    21   ssd  0.87329         osd.21
    22   ssd  0.87329         osd.22
    23   ssd  0.87329         osd.23
    24   ssd  0.87329         osd.24
    25   ssd  0.87329         osd.25
    26   ssd  0.87329         osd.26
    27   ssd  0.87329         osd.27
    28   ssd  0.87329         osd.28
    29   ssd  0.87329         osd.29
    36   ssd  1.81940         osd.36
    37   ssd  1.81940         osd.37
    38   ssd  1.81940         osd.38

> 修改nvme类型class

    ceph osd crush rm-device-class 30
    ceph osd crush set-device-class nvme osd.30
    ceph osd crush rm-device-class 31
    ceph osd crush set-device-class nvme osd.31
    ceph osd crush rm-device-class 32
    ceph osd crush set-device-class nvme osd.32
    
    ceph osd crush rm-device-class 33
    ceph osd crush set-device-class nvme osd.33
    ceph osd crush rm-device-class 34
    ceph osd crush set-device-class nvme osd.34
    ceph osd crush rm-device-class 35
    ceph osd crush set-device-class nvme osd.35
    
    ceph osd crush rm-device-class 36
    ceph osd crush set-device-class nvme osd.36
    ceph osd crush rm-device-class 37
    ceph osd crush set-device-class nvme osd.37
    ceph osd crush rm-device-class 38
    ceph osd crush set-device-class nvme osd.38
    
查看集群osd crush tree

    cd /etc/ceph/cluster
    ceph osd crush tree --show-shadow

回显

    ID  CLASS WEIGHT   TYPE NAME
    -12  nvme 16.37457 root default~nvme
     -9  nvme  5.45819     host node3~nvme
     30  nvme  1.81940         osd.30
     31  nvme  1.81940         osd.31
     32  nvme  1.81940         osd.32
    -10  nvme  5.45819     host node4~nvme
     33  nvme  1.81940         osd.33
     34  nvme  1.81940         osd.34
     35  nvme  1.81940         osd.35
    -11  nvme  5.45819     host node5~nvme
     36  nvme  1.81940         osd.36
     37  nvme  1.81940         osd.37
     38  nvme  1.81940         osd.38
     -2   ssd 24.88866 root default~ssd
     -4   ssd  8.29622     host node3~ssd
      0   ssd  0.87329         osd.0
      1   ssd  0.87329         osd.1
      2   ssd  0.87329         osd.2
      3   ssd  0.87329         osd.3
      4   ssd  0.87329         osd.4
      5   ssd  0.87329         osd.5
      6   ssd  0.87329         osd.6
      7   ssd  0.43660         osd.7
      8   ssd  0.87329         osd.8
      9   ssd  0.87329         osd.9
     -6   ssd  8.29622     host node4~ssd
     10   ssd  0.43660         osd.10
     11   ssd  0.87329         osd.11
     12   ssd  0.87329         osd.12
     13   ssd  0.87329         osd.13
     14   ssd  0.87329         osd.14
     15   ssd  0.87329         osd.15
     16   ssd  0.87329         osd.16
     17   ssd  0.87329         osd.17
     18   ssd  0.87329         osd.18
     19   ssd  0.87329         osd.19
     -8   ssd  8.29622     host node5~ssd
     20   ssd  0.43660         osd.20
     21   ssd  0.87329         osd.21
     22   ssd  0.87329         osd.22
     23   ssd  0.87329         osd.23
     24   ssd  0.87329         osd.24
     25   ssd  0.87329         osd.25
     26   ssd  0.87329         osd.26
     27   ssd  0.87329         osd.27
     28   ssd  0.87329         osd.28
     29   ssd  0.87329         osd.29
     -1       41.26323 root default
     -3       13.75441     host node3
     30  nvme  1.81940         osd.30
     31  nvme  1.81940         osd.31
     32  nvme  1.81940         osd.32
      0   ssd  0.87329         osd.0
      1   ssd  0.87329         osd.1
      2   ssd  0.87329         osd.2
      3   ssd  0.87329         osd.3
      4   ssd  0.87329         osd.4
      5   ssd  0.87329         osd.5
      6   ssd  0.87329         osd.6
      7   ssd  0.43660         osd.7
      8   ssd  0.87329         osd.8
      9   ssd  0.87329         osd.9
     -5       13.75441     host node4
     33  nvme  1.81940         osd.33
     34  nvme  1.81940         osd.34
     35  nvme  1.81940         osd.35
     10   ssd  0.43660         osd.10
     11   ssd  0.87329         osd.11
     12   ssd  0.87329         osd.12
     13   ssd  0.87329         osd.13
     14   ssd  0.87329         osd.14
     15   ssd  0.87329         osd.15
     16   ssd  0.87329         osd.16
     17   ssd  0.87329         osd.17
     18   ssd  0.87329         osd.18
     19   ssd  0.87329         osd.19
     -7       13.75441     host node5
     36  nvme  1.81940         osd.36
     37  nvme  1.81940         osd.37
     38  nvme  1.81940         osd.38
     20   ssd  0.43660         osd.20
     21   ssd  0.87329         osd.21
     22   ssd  0.87329         osd.22
     23   ssd  0.87329         osd.23
     24   ssd  0.87329         osd.24
     25   ssd  0.87329         osd.25
     26   ssd  0.87329         osd.26
     27   ssd  0.87329         osd.27
     28   ssd  0.87329         osd.28
     29   ssd  0.87329         osd.29


> 添加节点`/dev/sda`磁盘
 
    cd /etc/ceph/cluster
    ceph-deploy osd create --data /dev/sda node3
    
    cd /etc/ceph/cluster
    ceph-deploy osd create --data /dev/sda node4
        
    cd /etc/ceph/cluster
    ceph-deploy osd create --data /dev/sda node5
    
擦净节点`/dev/sda`磁盘

    cd /etc/ceph/cluster
    ceph-deploy disk zap node3 /dev/sda
    
    cd /etc/ceph/cluster
    ceph-deploy disk zap node4 /dev/sda
    
    cd /etc/ceph/cluster
    ceph-deploy disk zap node5 /dev/sda
    
查看集群osd crush tree

    cd /etc/ceph/cluster
    ceph osd crush tree --show-shadow
    
    
回显

     -9  nvme  5.45819     host node3~nvme
     30  nvme  1.81940         osd.30
     31  nvme  1.81940         osd.31
     32  nvme  1.81940         osd.32
    -10  nvme  5.45819     host node4~nvme
     33  nvme  1.81940         osd.33
     34  nvme  1.81940         osd.34
     35  nvme  1.81940         osd.35
    -11  nvme  5.45819     host node5~nvme
     36  nvme  1.81940         osd.36
     37  nvme  1.81940         osd.37
     38  nvme  1.81940         osd.38
     -2   ssd 27.50853 root default~ssd
     -4   ssd  9.16951     host node3~ssd
      0   ssd  0.87329         osd.0
      1   ssd  0.87329         osd.1
      2   ssd  0.87329         osd.2
      3   ssd  0.87329         osd.3
      4   ssd  0.87329         osd.4
      5   ssd  0.87329         osd.5
      6   ssd  0.87329         osd.6
      7   ssd  0.43660         osd.7
      8   ssd  0.87329         osd.8
      9   ssd  0.87329         osd.9
     39   ssd  0.87329         osd.39
     -6   ssd  9.16951     host node4~ssd
     10   ssd  0.43660         osd.10
     11   ssd  0.87329         osd.11
     12   ssd  0.87329         osd.12
     13   ssd  0.87329         osd.13
     14   ssd  0.87329         osd.14
     15   ssd  0.87329         osd.15
     16   ssd  0.87329         osd.16
     17   ssd  0.87329         osd.17
     18   ssd  0.87329         osd.18
     19   ssd  0.87329         osd.19
     40   ssd  0.87329         osd.40
     -8   ssd  9.16951     host node5~ssd
     20   ssd  0.43660         osd.20
     21   ssd  0.87329         osd.21
     22   ssd  0.87329         osd.22
     23   ssd  0.87329         osd.23
     24   ssd  0.87329         osd.24
     25   ssd  0.87329         osd.25
     26   ssd  0.87329         osd.26
     27   ssd  0.87329         osd.27
     28   ssd  0.87329         osd.28
     29   ssd  0.87329         osd.29
     41   ssd  0.87329         osd.41
     -1       43.88310 root default
     -3       14.62770     host node3
     30  nvme  1.81940         osd.30
     31  nvme  1.81940         osd.31
     32  nvme  1.81940         osd.32
      0   ssd  0.87329         osd.0
      1   ssd  0.87329         osd.1
      2   ssd  0.87329         osd.2
      3   ssd  0.87329         osd.3
      4   ssd  0.87329         osd.4
      5   ssd  0.87329         osd.5
      6   ssd  0.87329         osd.6
      7   ssd  0.43660         osd.7
      8   ssd  0.87329         osd.8
      9   ssd  0.87329         osd.9
     39   ssd  0.87329         osd.39
     -5       14.62770     host node4
     33  nvme  1.81940         osd.33
     34  nvme  1.81940         osd.34
     35  nvme  1.81940         osd.35
     10   ssd  0.43660         osd.10
     11   ssd  0.87329         osd.11
     12   ssd  0.87329         osd.12
     13   ssd  0.87329         osd.13
     14   ssd  0.87329         osd.14
     15   ssd  0.87329         osd.15
     16   ssd  0.87329         osd.16
     17   ssd  0.87329         osd.17
     18   ssd  0.87329         osd.18
     19   ssd  0.87329         osd.19
     40   ssd  0.87329         osd.40
     -7       14.62770     host node5
     36  nvme  1.81940         osd.36
     37  nvme  1.81940         osd.37
     38  nvme  1.81940         osd.38
     20   ssd  0.43660         osd.20
     21   ssd  0.87329         osd.21
     22   ssd  0.87329         osd.22
     23   ssd  0.87329         osd.23
     24   ssd  0.87329         osd.24
     25   ssd  0.87329         osd.25
     26   ssd  0.87329         osd.26
     27   ssd  0.87329         osd.27
     28   ssd  0.87329         osd.28
     29   ssd  0.87329         osd.29
     41   ssd  0.87329         osd.41
     
### crush pool

> 创建crush rule

    #ceph osd crush rule create-replicated <rule-name> <root> <failure-domain> <class>

创建`class` 为`ssd`的rule

    ceph osd crush rule create-replicated ssd_rule default host ssd
    
创建`class` 为`nvme`的rule

    ceph osd crush rule create-replicated nvme_rule default host nvme
    
> 创建资源池

    #ceph osd pool create {pool_name} {pg_num} [{pgp_num}]
    ceph osd pool create container-pool 250 250
    
> 查看`container-pool`crush rule

    ceph osd pool get container-pool crush_rule
    
回显

    crush_rule: replicated_rule

> 设置`container-pool`crush rule为`ssd_rule`

    #ceph osd pool set <pool-name> crush_rule <rule-name>
    ceph osd pool set container-pool crush_rule ssd_rule

查看`container-pool`crush rule

    ceph osd pool get container-pool crush_rule
    
回显
 
    crush_rule: ssd_rule
    
> 设置`container-pool`配额

    #osd pool set-quota <poolname> max_objects|max_bytes <val>

设置最大对象数10

    ceph osd pool set-quota container-pool max_objects 10
    
设置存储大小为2G

    ceph osd pool set-quota container-pool max_bytes 2G
    
> 扩容`container-pool`配额

    #osd pool set-quota <poolname> max_objects|max_bytes <val>
    
设置最大对象数10W

    ceph osd pool set-quota container-pool max_objects 100000
    
设置存储大小为2T

    ceph osd pool set-quota container-pool max_bytes 2T
    
> 修改`container-pool`为`harbor-pool`

     ceph osd pool rename container-pool harbor-pool
     
### 块设备（rdb）使用
    
**ceph客户端**

> 配置yum

    cat > /etc/yum.repos.d/ceph.repo <<EOF
    [Ceph]
    name=Ceph \$basearch
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/\$basearch
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    
    [Ceph-noarch]
    name=Ceph noarch
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/noarch
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    
    [Ceph-source]
    name=Ceph SRPMS
    baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/SRPMS
    enabled=1
    gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
    EOF

> 安装客户端

    yum install -y epel-release
    yum install -y ceph-common
    
> 拷贝配置文件

客户端创建配置目录

    mkdir -p /etc/ceph
    
客户端创建挂载目录

    mkdir -p /ceph
    chmod 777 /ceph
    
从服务端`scp`以下文件至客户端/etc/ceph下

- /etc/ceph/ceph.client.admin.keyring
- /etc/ceph/ceph.conf


    scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} ip:/etc/ceph/
    
> 创建块设备(客户端执行)

    rbd create --pool harbor-pool --image harbor-img --image-format 2 --image-feature layering --size 2048G

> 映射块设备

    rbd map harbor-pool/harbor-img
    echo "harbor-pool/harbor-img id=admin,keyring=/etc/ceph/ceph.client.admin.keyring" >> /etc/ceph/rbdmap
    
> 格式化块设备

     mkfs.ext4 -q /dev/rbd0
     
> 挂载使用

    mount /dev/rbd0 /ceph

> 查看挂载

    lsblk
 
> 修改fstab，设置开机挂载

    echo "/dev/rbd0 /ceph ext4 defaults,noatime,_netdev 0 0" >> /etc/fstab
    
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
    
