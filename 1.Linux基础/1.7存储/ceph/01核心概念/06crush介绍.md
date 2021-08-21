### `CRUSH`算法介绍

`Ceph`客户端和`ceph osd`守护进程都使用`CRUSH`算法来有效地计算对象的位置信息，而不是依赖于一个中心查找表。
与以前的方法相比，`CRUSH`提供了更好的数据管理机制，可以实现大规模的数据管理。
`CRUSH`使用智能数据复制来确保弹性，这更适合于超大规模存储。

> 集群映射

`Ceph`依赖于`Ceph`客户端和`ceph osd`守护进程了解集群拓扑，其中包括5个映射，统称为“集群映射”：

- `Monitor`映射: 包含集群`fsid`、每个监视器的位置、名称、地址和端口、映射创建的时间，以及它最后一次修改时间。
  要查看监视器映射，执行`ceph mon dump`。

```shell
[root@ceph01 ~]# ceph mon dump
dumped monmap epoch 2
epoch 2
fsid b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
last_changed 2021-02-22 14:36:08.199609
created 2021-02-22 14:27:26.357269
min_mon_release 14 (nautilus)
0: [v2:192.168.1.69:3300/0,v1:192.168.1.69:6789/0] mon.ceph01
1: [v2:192.168.1.70:3300/0,v1:192.168.1.70:6789/0] mon.ceph02
2: [v2:192.168.1.71:3300/0,v1:192.168.1.71:6789/0] mon.ceph03
```

- `OSD映射`:包含集群的`fsid`，映射创建和最后修改的时间，池的列表，副本大小，`PG`号，`OSD`的列表和状态(如up, in)。
  执行`ceph osd dump`命令，查看`OSD`映射

```shell
[root@ceph01 ~]# ceph osd dump
epoch 1
fsid b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
created 2021-02-22 14:27:48.482130
modified 2021-02-22 14:27:48.482130
flags sortbitwise,recovery_deletes,purged_snapdirs,pglog_hardlimit
crush_version 1
full_ratio 0.95
backfillfull_ratio 0.9
nearfull_ratio 0.85
require_min_compat_client jewel
min_compat_client jewel
require_OSD_release nautilus
max_OSD 0
```

- `PG Map`：包含`PG`版本、它的时间戳、最后一个`OSD Map epoch`、完整比率，以及每个放置组的详细信息，例如`PG ID`、`Up Set`、`Acting Set`、`PG`的状态（例如active+clean），以及每个池的数据使用统计信息
- `CRUSH Map`:包含一个存储设备列表，故障域层次结构(例如，设备、主机、机架、行、房间等)，以及存储数据时遍历层次结构的规则。执行`ceph osd getcrushmap -o {filename}`;然后，通过执行`crushtool -d {comp-crushmap-filename} -o {decomp-crushmap-filename}`来反编译它。
  使用cat查看反编译后的映射。
- `MDS Map`:包含当前`MDS Map`的`epoch`、`Map`创建的时间和最后一次修改的时间。它还包含存储元数据的池、元数据服务器的列表，以及哪些元数据服务器已经启动和运行.

每个映射维护其操作状态更改的迭代历史。`Ceph`监视器维护集群映射的主副本，包括集群成员、状态、变更和`Ceph`存储集群的总体运行状况

### crush class

> 说明

从`luminous`版本`ceph`新增了一个功能`crush class`，这个功能又可以称为磁盘智能分组。因为这个功能就是根据磁盘类型自动的进行属性的关联，然后进行分类。无需手动修改`crushmap`，极大的减少了人为的操作。

`ceph`中的每个`OSD`设备都可以选择一个`class`类型与之关联，默认情况下，在创建`OSD`的时候会自动识别设备类型，然后设置该设备为相应的类。通常有三种`class`类型：`hdd`，`ssd`，`nvme`。


> 查看集群`OSD crush tree`(ceph01节点执行)

```shell
[root@ceph01 ~]# ceph osd crush tree --show-shadow
ID CLASS WEIGHT   TYPE NAME
-2   ssd 25.76233 root default~ssd
-4   ssd  9.75183     host ceph01~ssd
 0   ssd  0.87329         OSD.0
 1   ssd  0.87329         OSD.1
 2   ssd  0.87329         OSD.2
 3   ssd  0.87329         OSD.3
 4   ssd  0.87329         OSD.4
 5   ssd  0.87329         OSD.5
 6   ssd  0.87329         OSD.6
 7   ssd  0.90970         OSD.7
 8   ssd  0.90970         OSD.8
 9   ssd  0.90970         OSD.9
10   ssd  0.90970         OSD.10
-6   ssd  8.00525     host ceph02~ssd
11   ssd  0.87329         OSD.11
12   ssd  0.87329         OSD.12
13   ssd  0.87329         OSD.13
14   ssd  0.87329         OSD.14
15   ssd  0.87329         OSD.15
16   ssd  0.90970         OSD.16
17   ssd  0.90970         OSD.17
18   ssd  0.90970         OSD.18
19   ssd  0.90970         OSD.19
-8   ssd  8.00525     host ceph03~ssd
20   ssd  0.87329         OSD.20
21   ssd  0.87329         OSD.21
22   ssd  0.87329         OSD.22
23   ssd  0.87329         OSD.23
24   ssd  0.87329         OSD.24
25   ssd  0.90970         OSD.25
26   ssd  0.90970         OSD.26
27   ssd  0.90970         OSD.27
28   ssd  0.90970         OSD.28
```

> 修改`nvme`类型`class`

```shell
ceph osd crush rm-device-class 7
ceph osd crush set-device-class nvme OSD.7
ceph osd crush rm-device-class 8
ceph osd crush set-device-class nvme OSD.8
ceph osd crush rm-device-class 9
ceph osd crush set-device-class nvme OSD.9
ceph osd crush rm-device-class 10
ceph osd crush set-device-class nvme OSD.10

ceph osd crush rm-device-class 16
ceph osd crush set-device-class nvme OSD.16
ceph osd crush rm-device-class 17
ceph osd crush set-device-class nvme OSD.17
ceph osd crush rm-device-class 18
ceph osd crush set-device-class nvme OSD.18
ceph osd crush rm-device-class 19
ceph osd crush set-device-class nvme OSD.19

ceph osd crush rm-device-class 25
ceph osd crush set-device-class nvme OSD.25
ceph osd crush rm-device-class 26
ceph osd crush set-device-class nvme OSD.26
ceph osd crush rm-device-class 27
ceph osd crush set-device-class nvme OSD.27
ceph osd crush rm-device-class 28
ceph osd crush set-device-class nvme OSD.28
```


> 查看集群`OSD crush tree`

```shell
[root@ceph01 ~]# ceph osd crush tree --show-shadow
ID  CLASS WEIGHT   TYPE NAME
-12  nvme 10.91638 root default~nvme
-9  nvme  3.63879     host ceph01~nvme
7  nvme  0.90970         OSD.7
8  nvme  0.90970         OSD.8
9  nvme  0.90970         OSD.9
10  nvme  0.90970         OSD.10
-10  nvme  3.63879     host ceph02~nvme
16  nvme  0.90970         OSD.16
17  nvme  0.90970         OSD.17
18  nvme  0.90970         OSD.18
19  nvme  0.90970         OSD.19
-11  nvme  3.63879     host ceph03~nvme
25  nvme  0.90970         OSD.25
26  nvme  0.90970         OSD.26
27  nvme  0.90970         OSD.27
28  nvme  0.90970         OSD.28
-2   ssd 14.84595 root default~ssd
-4   ssd  6.11304     host ceph01~ssd
0   ssd  0.87329         OSD.0
1   ssd  0.87329         OSD.1
2   ssd  0.87329         OSD.2
3   ssd  0.87329         OSD.3
4   ssd  0.87329         OSD.4
5   ssd  0.87329         OSD.5
6   ssd  0.87329         OSD.6
-6   ssd  4.36646     host ceph02~ssd
11   ssd  0.87329         OSD.11
12   ssd  0.87329         OSD.12
13   ssd  0.87329         OSD.13
14   ssd  0.87329         OSD.14
15   ssd  0.87329         OSD.15
-8   ssd  4.36646     host ceph03~ssd
20   ssd  0.87329         OSD.20
21   ssd  0.87329         OSD.21
22   ssd  0.87329         OSD.22
23   ssd  0.87329         OSD.23
24   ssd  0.87329         OSD.24
```

### crush pool使用
> 创建crush rule

```shell
# ceph osd crush rule create-replicated <rule-name> <root> <failure-domain> <class>
# 创建`class` 为`SSD`的rule
ceph osd crush rule create-replicated SSD_rule default host ssd
```

> 创建资源池

```shell
#ceph osd pool create {pool_name} {pg_num} [{pgp_num}]
ceph osd pool create ssd-pool 256 256
```

> 查看`ssd-pool`crush rule

```shell
[root@ceph01 ~]# ceph osd pool get ssd-pool crush_rule
crush_rule: replicated_rule
```
> 设置`ssd-pool`crush rule为`SSD_rule`

```shell
#ceph osd pool set <pool-name> crush_rule <rule-name>
ceph osd pool set ssd-pool crush_rule SSD_rule
```

> 查看`ssd-pool`crush rule

```shell
[root@ceph01 ~]# ceph osd pool get ssd-pool crush_rule
crush_rule: SSD_rule
```

> 设置`ssd-pool`配额

```shell
#osd pool set-quota <poolname> max_objects|max_bytes <val>
```

> 设置最大对象数10

```shell
ceph osd pool set-quota ssd-pool max_objects 10
```

设置存储大小为1G

```shell
ceph osd pool set-quota ssd-pool max_bytes 1G
```

> 扩容`ssd-pool`配额

```shell
#osd pool set-quota <poolname> max_objects|max_bytes <val>
```

> 设置最大对象数20

```shell
ceph osd pool set-quota ssd-pool max_objects 20
```

> 设置存储大小为2G

```shell
ceph osd pool set-quota ssd-pool max_bytes 2G
```

> 修改`ssd-pool`为`ssd-demo-pool`

```shell
ceph osd pool rename ssd-pool ssd-demo-pool
```

**最佳实践：创建不同类型存储池（基于HDD、SSD，提供不同场景使用）**