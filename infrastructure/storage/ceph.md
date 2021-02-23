<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [ceph-deploy部署N版](#ceph-deploy%E9%83%A8%E7%BD%B2n%E7%89%88)
- [ceph添加磁盘](#ceph%E6%B7%BB%E5%8A%A0%E7%A3%81%E7%9B%98)
- [crush pool](#crush-pool)
- [块设备（rdb）使用](#%E5%9D%97%E8%AE%BE%E5%A4%87rdb%E4%BD%BF%E7%94%A8)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 竞品对比

### 对比raid

`RAID`(Redundant Array of Independent Disks)即独立冗余磁盘阵列，是一种把多块独立的硬盘（物理硬盘）按不同的方式组合起来形成一个硬盘组（逻辑硬盘），让用户认为只有一个单个超大硬盘，从而提供比单个硬盘更高的存储性能和提供数据备份技术

- [RAID]()
    - 漫长的重建过程，而且在重建过程中，不能有第二块盘损坏，否则会引发更大的问题；
    
    - 备用盘增加[TCO](https://baike.baidu.com/item/tco/5979397?fr=aladdin) ，作为备用盘，当没有硬盘故障时，就会一直闲置的

    - 不能保证两块盘同时故障后，数据的可靠性

    - 在重建结束前，客户端无法获取到足够的`IO`资源

    - 无法避免网络、服务器硬件、操作系统、电源等故障

- [Ceph]()
    - 为了保证可靠性，采用了数据复制的方式，这意味着不再需要`RAID`，也就克服了`RAID`存在的诸多问题
    
    - `Ceph` 数据存储原则：一个`Pool` 有若干`PG`，每个`PG` 包含若干对象，一个对象只能存储在一个`PG`中，而`Ceph` 默认一个`PG` 包含三个`OSD`，每个`OSD`都可看做一块硬盘。
    因此，一个对象存储在`Ceph`中时，就被保存了三份。当一个磁盘故障时，还剩下2个`PG`，系统就会从另外两个`PG`中复制数据到其他磁盘上。这个是由`crush`算法决定

    - 磁盘复制属性值可以通过管理员进行调整

    - 磁盘存储上使用了加权机制，所以磁盘大小不一致也不会出现问题

### 对比SAN、NAS、DAS

- DAS

    `Direct Attached Storage`，即直连附加存储，第一代存储系统，通过`SCSI`总线扩展至一个外部的存储，磁带整列，作为服务器扩展的一部分

- NAS

    `Network Attached Storage`，即网络附加存储，通过网络协议如`NFS`远程获取后端文件服务器共享的存储空间，将文件存储单独分离出来
    
- SAN

    `Storage Area Network`，即存储区域网络，分为`IP-SAN`和`FC-SAN`，即通过`TCP/IP`协议和`FC`(Fiber Channel)光纤协议连接到存储服务器
    
- Ceph

    `Ceph`在一个统一的存储系统中同时提供了对象存储、块存储和文件存储，即`Ceph`是一个统一存储，能够将企业企业中的三种存储需求统一汇总到一个存储系统中，并提供分布式、横向扩展，高度可靠性的存储系统
    
**主要区别如下：**

- `DAS`直连存储服务器使用`SCSI`或`FC`协议连接到存储阵列、通过`SCSI`总线和`FC`光纤协议类型进行数据传输；
例如一块有空间大小的裸磁盘：`/dev/sdb`。`DAS`存储虽然组网简单、成本低廉但是可扩展性有限、无法多主机实现共享、目前已经很少使用

- `NAS`网络存储服务器使用`TCP`网络协议连接至文件共享存储、常见的有`NFS`、`CIFS`协议等；通过网络的方式映射存储中的一个目录到目标主机，如`/data`。
`NAS`网络存储使用简单，通过`IP`协议实现互相访问，多台主机可以同时共享同一个存储。但是`NAS`网络存储的性能有限，可靠性不是很高。

- `SAN`存储区域网络服务器使用一个存储区域网络`IP`或`FC`连接到存储阵列、常见的`SAN`协议类型有`IP-SAN`和`FC-SAN`。`SAN`存储区域网络的性能非常好、可扩展性强；但是成本特别高、尤其是`FC`存储网络：因为需要用到`HBA`卡、`FC`交换机和支持`FC`接口的存储



    | 存储结构/性能对比 | DAS | NAS | FC-SAN | IP-SAN | Ceph |
    | :----:| :----: | :----: | :----: | :----: | :----: |
    | 成本 | 低 | 较低 | 高 | 较高 | 高 |
    | 数据传输速度 | 快 | 慢 | 极快 | 较快 | 快 |
    | 扩展性 | 无扩展性 | 较低 | 易于扩展 | 最易扩展 | 易于扩展 |
    | 服务器访问存储方式 | 块 | 文件 | 块 | 块 | 对象、文件、块 |
    | 服务器系统性能开销 | 低 | 较低 | 低 | 较高 | 低 |
    | 安全性 | 高 | 低 | 高 | 低 | 高 |
    | 是否集中管理存储 | 否 | 是 | 是 | 是 | 否 |
    | 备份效率 | 低 | 较低 | 高 | 较高 | 高 |
    | 网络传输协议 | 无 | TCP/IP | FC | TCP/IP | 私有协议(TCP) |

### ceph-deploy部署N版

- 节点信息


    | 节点名称 | 节点IP | 节点属性 |
    | :----:| :----: | :----: |
    | ceph01 | 192.168.1.69 | admin,deploy,mon |
    | ceph02 | 192.168.1.70 | 单元格 |
    | ceph03 | 192.168.1.70 | 单元格 |
    
> 前置要求

- `yum`联网(可通过配置代理实现)
- `ceph`节点配置时钟同步

> 配置阿里云仓储（所有节点）

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

> 创建ceph目录(deploy节点)

    mkdir -p /etc/ceph
    
> 配置主机互信(deploy节点)

    ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa
    ssh-copy-id ceph01
    ssh-copy-id ceph02
    ssh-copy-id ceph03
    
> 安装`ceph`(所有节点)

    yum install -y ceph
    
> 初始化mon节点(deploy节点)

    ceph-deploy new ceph01 ceph02 ceph03
    
> 初始化`mon`(deploy节点)

     ceph-deploy mon create-initial
     
> 修改集群文件(deploy节点)

    cd /etc/ceph/
    echo "public_network=192.168.1.0/24" >> /etc/ceph/ceph.conf
    ceph-deploy --overwrite-conf config push ceph01 ceph02 ceph03
    
> 查看集群状态

    [root@ceph01 ~]# ceph -s
      cluster:
        id:     b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
        health: HEALTH_WARN
                mon ceph03 is low on available space
    
      services:
        mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 31m)
        mgr: no daemons active
        osd: 0 osds: 0 up, 0 in
    
      data:
        pools:   0 pools, 0 pgs
        objects: 0 objects, 0 B
        usage:   0 B used, 0 B / 0 B avail
        pgs:
    
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
    
### k8s对接cephfs

> 下载所需镜像

    quay.io/external_storage/cephfs-provisioner:latest
    
> 安装

    git clone https://github.com/kubernetes-retired/external-storage.git
    external-storage/ceph/cephfs/deploy/
    NAMESPACE=kube-system
    sed -r -i "s/namespace: [^ ]+/namespace: $NAMESPACE/g" ./rbac/*.yaml
    sed -i "/PROVISIONER_SECRET_NAMESPACE/{n;s/value:.*/value: $NAMESPACE/;}" rbac/deployment.yaml
    kubectl -n $NAMESPACE apply -f ./rbac
    
### 卸载

    ceph-deploy purge ceph01 ceph02 ceph03
    
    ceph-deploy purgedata ceph01 ceph02 ceph03
    
    ceph-deploy forgetkeys
    
    rm -rf /var/lib/ceph
    
    
## 参考文献

- [SAN和NAS之间的基本区别](https://www.cnblogs.com/cainiao-chuanqi/p/12204944.html)
    
