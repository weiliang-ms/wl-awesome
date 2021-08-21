## 池的常用配置

### PG配置

> 设置池的放置组数

```shell
ceph osd pool set {pool-name} pgp_num {pgp_num}
```

> 获取池的放置组数

```shell
ceph osd pool get {pool-name} pg_num
```

> 获取集群的PG统计信息

```shell
# ceph pg dump [--format {format}]
ceph pg dump -f json
```

### 将池与应用程序关联

池在使用之前需要与应用程序相关联。将与`cepfs`一起使用的池或由`RGW`自动创建的池将自动关联。
用于与`RBD`一起使用的池应该使用`RBD`工具进行初始化。

```shell
# ceph osd pool application enable {pool-name} {application-name}(cephfs, rbd, rgw)
[root@ceph01 ~]# ceph osd pool application enable ssd-demo-pool rbd
enabled application 'rbd' on pool 'ssd-demo-pool'
[root@ceph01 ~]# ceph osd pool application enable nvme-demo-pool cephfs
enabled application 'cephfs' on pool 'nvme-demo-pool'
```

### 池配额

您可以为每个池的最大字节数和/或最大对象数设置池配额。

```shell
# ceph osd pool set-quota {pool-name} [max_objects {obj-count}] [max_bytes {bytes}]
ceph osd pool set-quota data max_objects 10000
```

要删除配额，请将其值设置为0

```shell
ceph osd pool set-quota data max_objects 0
```

### 设置对象副本数

默认为`3`

```shell
ceph osd pool set {poolname} size {num-replicas}
```

### pg_autoscale_mode

放置组（PGs）是`Ceph`分发数据的内部实现细节。
过启用`pg autoscaling`，您可以允许集群提出建议或根据集群的使用方式自动调整`PGs`。

系统中的每个池都有一个`pg_autoscale_mode`属性，可以设置为`off`、`on`或`warn`：

- `off`：禁用此池的自动缩放。由管理员为每个池选择适当的`PG`数量。
- `on`：启用给定池的`PG`计数的自动调整。
- `warn`：当`PG`计数需要调整时发出健康警报（默认）

> 为指定池设置放置组数自动伸缩

```shell
# ceph osd pool set <pool-name> pg_autoscale_mode <mode>
    
[root@ceph01 ~]# ceph osd pool set ssd-demo-pool pg_autoscale_mode on
set pool 1 pg_autoscale_mode to on
```

> 设置集群内所有池放置组数自动伸缩

```shell
# ceph config set global osd_pool_default_pg_autoscale_mode <mode>
ceph config set global osd_pool_default_pg_autoscale_mode on
```

- 查看集群内放置组数伸缩策略

```shell
[root@ceph01 ~]# ceph osd pool autoscale-status
    POOL             SIZE TARGET SIZE RATE RAW CAPACITY  RATIO TARGET RATIO EFFECTIVE RATIO BIAS PG_NUM NEW PG_NUM AUTOSCALE
    nvme-demo-pool     7               3.0       11178G 0.0000                               1.0    256         32 warn
    ssd-demo-pool      7               3.0       15202G 0.0000                               1.0     32            on
```
- 创建`ddd-pool`，并查看集群内放置组数伸缩策略

```shell
[root@ceph01 ~]# ceph osd pool create ddd-pool 1 1
pool 'ddd-pool' created
[root@ceph01 ~]# ceph osd pool autoscale-status
POOL             SIZE TARGET SIZE RATE RAW CAPACITY  RATIO TARGET RATIO EFFECTIVE RATIO BIAS PG_NUM NEW PG_NUM AUTOSCALE
nvme-demo-pool     7               3.0       26380G 0.0000                               1.0    256         32 warn
ssd-demo-pool      7               3.0       15202G 0.0000                               1.0     32            on
ddd-pool           0               3.0       26380G 0.0000                               1.0      1         32 on
```
> 查看池伸缩建议

```shell
POOL             SIZE TARGET SIZE RATE RAW CAPACITY  RATIO TARGET RATIO EFFECTIVE RATIO BIAS PG_NUM NEW PG_NUM AUTOSCALE
nvme-demo-pool     7               3.0       26380G 0.0000                               1.0    256         32 warn
ssd-demo-pool      7               3.0       15202G 0.0000                               1.0     32            on
ddd-pool           0               3.0       26380G 0.0000                               1.0     32            on
```
- `SIZE`：存储在池中的数据量
- `TARGET SIZE`：管理员指定的他们希望最终存储在此池中的数据量
- `RATE`：池的乘数，用于确定消耗了多少原始存储容量。例如，3副本池的比率为3.0，而`k=4`，`m=2`擦除编码池的比率为1.5。
- `RAW CAPACITY`：负责存储此池(可能还有其他池)数据的`OSD`上的裸存储容量的总和。
- `RATIO`：当前池正在消耗的总容量的比率(即RATIO = size * rate / raw capacity)。
- `TARGET RATIO`：管理员指定的期望此池消耗的存储空间相对于设置了目标比率的其他池的比率。如果同时指定了目标大小字节和比率，则该比率优先
- `EFFECTIVE RATIO`：有效比率是通过两种方式调整后的目标比率：
    - 减去设置了目标大小的池预期使用的任何容量
    - 在设置了目标比率的池之间规范化目标比率，以便它们共同以空间的其余部分为目标。例如，4个池的目标收益率为1.0，其有效收益率为0.25。
      系统使用实际比率和有效比率中的较大者进行计算。
- `PG_NUM`：池的当前`PG`数
- `NEW PG_NUM`：池的`pgu NUM`期望值。它始终是2的幂，并且只有当期望值与当前值相差超过3倍时才会出现。
- `AUTOSCALE`：`pool_pg_autosacle`模式，可以是`on`、`off`或`warn`。

> 自动缩放

允许集群根据使用情况自动扩展`PGs`是最简单的方法。`Ceph`将查看整个系统的总可用存储和`PGs`的目标数量，查看每个池中存储了多少数据，并尝试相应地分配`PGs`。
系统采用的方法相对保守，仅在当前`pg`(pg_num)的数量比它认为应该的数量少3倍以上时才对池进行更改。

每个`OSD`的`pg`目标数基于`mon_target_pg_per_OSD`可配置（默认值：100），可通过以下方式进行调整:

```shell
ceph config set global mon_target_pg_per_OSD 100
```

### 指定池的期望大小

当第一次创建集群或池时，它将消耗集群总容量的一小部分，并且在系统看来似乎只需要少量的放置组。
但是，在大多数情况下，集群管理员都很清楚，随着时间的推移，哪些池将消耗大部分系统容量。
通过向`Ceph`提供此信息，可以从一开始就使用更合适数量的`pg`，从而防止`pg_num`的后续更改以及在进行这些调整时与移动数据相关的开销

池的目标大小可以通过两种方式指定：要么根据池的绝对大小（即字节），要么作为相对于设置了目标大小比的其他池的权重。

`ddd-pool`预计使用`1G`存储空间

```shell
ceph osd pool set ddd-pool target_size_bytes 1G
```

相对于设置了`target_size_ratio`的其他池，`mpool`预计将消耗1.0。
如果`mpool`是集群中唯一的池，这意味着预计将使用总容量的100%。
如果有第二个带有`target_size_ratio`1.0的池，那么两个池都希望使用50%的集群容量。

```shell
ceph osd pool set mypool target_size_ratio 1.0
```

### 池其他配置

查看可配置项

```shell
[root@ceph01 ~]# ceph osd pool -h
    
 General usage:
 ==============
usage: ceph [-h] [-c CEPHCONF] [-i INPUT_FILE] [-o OUTPUT_FILE]
            [--setuser SETUSER] [--setgroup SETGROUP] [--id CLIENT_ID]
            [--name CLIENT_NAME] [--cluster CLUSTER]
            [--admin-daemon ADMIN_SOCKET] [-s] [-w] [--watch-debug]
            [--watch-info] [--watch-sec] [--watch-warn] [--watch-error]
            [--watch-channel {cluster,audit,*}] [--version] [--verbose]
            [--concise] [-f {json,json-pretty,xml,xml-pretty,plain}]
            [--connect-timeout CLUSTER_TIMEOUT] [--block] [--period PERIOD]

Ceph administration tool

optional arguments:
  -h, --help            request mon help
  -c CEPHCONF, --conf CEPHCONF
                        ceph configuration file
  -i INPUT_FILE, --in-file INPUT_FILE
                        input file, or "-" for stdin
  -o OUTPUT_FILE, --out-file OUTPUT_FILE
                        output file, or "-" for stdout
  --setuser SETUSER     set user file permission
  --setgroup SETGROUP   set group file permission
  --id CLIENT_ID, --user CLIENT_ID
                        client id for authentication
  --name CLIENT_NAME, -n CLIENT_NAME
                        client name for authentication
  --cluster CLUSTER     cluster name
  --admin-daemon ADMIN_SOCKET
                        submit admin-socket commands ("help" for help
  -s, --status          show cluster status
  -w, --watch           watch live cluster changes
  --watch-debug         watch debug events
  --watch-info          watch info events
  --watch-sec           watch security events
  --watch-warn          watch warn events
  --watch-error         watch error events
  --watch-channel {cluster,audit,*}
                        which log channel to follow when using -w/--watch. One
                        of ['cluster', 'audit', '*']
  --version, -v         display version
  --verbose             make verbose
  --concise             make less verbose
  -f {json,json-pretty,xml,xml-pretty,plain}, --format {json,json-pretty,xml,xml-pretty,plain}
  --connect-timeout CLUSTER_TIMEOUT
                        set a timeout for connecting to the cluster
  --block               block until completion (scrub and deep-scrub only)
  --period PERIOD, -p PERIOD
                        polling period, default 1.0 second (for polling
                        commands only)

 Local commands:
 ===============

ping <mon.id>           Send simple presence/life test to a mon
                        <mon.id> may be 'mon.*' for all mons
daemon {type.id|path} <cmd>
                        Same as --admin-daemon, but auto-find admin socket
daemonperf {type.id | path} [stat-pats] [priority] [<interval>] [<count>]
daemonperf {type.id | path} list|ls [stat-pats] [priority]
                        Get selected perf stats from daemon/admin socket
                        Optional shell-glob comma-delim match string stat-pats
                        Optional selection priority (can abbreviate name):
                         critical, interesting, useful, noninteresting, debug
                        List shows a table of all available stats
                        Run <count> times (default forever),
                         once per <interval> seconds (default 1)


 Monitor commands:
 =================
osd pool application disable <poolname> <app> {--yes-i-really-mean-it}   disables use of an application <app> on pool <poolname>
osd pool application enable <poolname> <app> {--yes-i-really-mean-it}    enable use of an application <app> [cephfs,rbd,rgw] on pool <poolname>
osd pool application get {<poolname>} {<app>} {<key>}                    get value of key <key> of application <app> on pool <poolname>
osd pool application rm <poolname> <app> <key>                           removes application <app> metadata key <key> on pool <poolname>
osd pool application set <poolname> <app> <key> <value>                  sets application <app> metadata key <key> to <value> on pool <poolname>
osd pool autoscale-status                                                report on pool pg_num sizing recommendation and intent
osd pool cancel-force-backfill <poolname> [<poolname>...]                restore normal recovery priority of specified pool <who>
osd pool cancel-force-recovery <poolname> [<poolname>...]                restore normal recovery priority of specified pool <who>
osd pool create <poolname> <int[0-]> {<int[0-]>} {replicated|erasure}    create pool
 {<erasure_code_profile>} {<rule>} {<int>} {<int>} {<int[0-]>} {<int[0-
 ]>} {<float[0.0-1.0]>}
osd pool deep-scrub <poolname> [<poolname>...]                           initiate deep-scrub on pool <who>
osd pool force-backfill <poolname> [<poolname>...]                       force backfill of specified pool <who> first
osd pool force-recovery <poolname> [<poolname>...]                       force recovery of specified pool <who> first
osd pool get <poolname> size|min_size|pg_num|pgp_num|crush_rule|         get pool parameter <var>
 hashpspool|nodelete|nopgchange|nosizechange|write_fadvise_dontneed|
 noscrub|nodeep-scrub|hit_set_type|hit_set_period|hit_set_count|hit_set_
 fpp|use_gmt_hitset|target_max_objects|target_max_bytes|cache_target_
 dirty_ratio|cache_target_dirty_high_ratio|cache_target_full_ratio|
 cache_min_flush_age|cache_min_evict_age|erasure_code_profile|min_read_
 recency_for_promote|all|min_write_recency_for_promote|fast_read|hit_
 set_grade_decay_rate|hit_set_search_last_n|scrub_min_interval|scrub_
 max_interval|deep_scrub_interval|recovery_priority|recovery_op_
 priority|scrub_priority|compression_mode|compression_algorithm|
 compression_required_ratio|compression_max_blob_size|compression_min_
 blob_size|csum_type|csum_min_block|csum_max_block|allow_ec_overwrites|
 fingerprint_algorithm|pg_autoscale_mode|pg_autoscale_bias|pg_num_min|
 target_size_bytes|target_size_ratio
osd pool get-quota <poolname>                                            obtain object or byte limits for pool
osd pool ls {detail}                                                     list pools
osd pool mksnap <poolname> <snap>                                        make snapshot <snap> in <pool>
osd pool rename <poolname> <poolname>                                    rename <srcpool> to <destpool>
osd pool repair <poolname> [<poolname>...]                               initiate repair on pool <who>
osd pool rm <poolname> {<poolname>} {--yes-i-really-really-mean-it} {--  remove pool
 yes-i-really-really-mean-it-not-faking}
osd pool rmsnap <poolname> <snap>                                        remove snapshot <snap> from <pool>
osd pool scrub <poolname> [<poolname>...]                                initiate scrub on pool <who>
osd pool set <poolname> size|min_size|pg_num|pgp_num|pgp_num_actual|     set pool parameter <var> to <val>
 crush_rule|hashpspool|nodelete|nopgchange|nosizechange|write_fadvise_
 dontneed|noscrub|nodeep-scrub|hit_set_type|hit_set_period|hit_set_
 count|hit_set_fpp|use_gmt_hitset|target_max_bytes|target_max_objects|
 cache_target_dirty_ratio|cache_target_dirty_high_ratio|cache_target_
 full_ratio|cache_min_flush_age|cache_min_evict_age|min_read_recency_
 for_promote|min_write_recency_for_promote|fast_read|hit_set_grade_
 decay_rate|hit_set_search_last_n|scrub_min_interval|scrub_max_interval|
 deep_scrub_interval|recovery_priority|recovery_op_priority|scrub_
 priority|compression_mode|compression_algorithm|compression_required_
 ratio|compression_max_blob_size|compression_min_blob_size|csum_type|
 csum_min_block|csum_max_block|allow_ec_overwrites|fingerprint_
 algorithm|pg_autoscale_mode|pg_autoscale_bias|pg_num_min|target_size_
 bytes|target_size_ratio <val> {--yes-i-really-mean-it}
osd pool set-quota <poolname> max_objects|max_bytes <val>                set object or byte limit on pool
osd pool stats {<poolname>}                                              obtain stats from all pools, or from specified pool
```