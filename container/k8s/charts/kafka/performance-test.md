<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [kafka性能测试](#kafka%E6%80%A7%E8%83%BD%E6%B5%8B%E8%AF%95)
  - [环境说明](#%E7%8E%AF%E5%A2%83%E8%AF%B4%E6%98%8E)
  - [基于虚机部署写性能测试](#%E5%9F%BA%E4%BA%8E%E8%99%9A%E6%9C%BA%E9%83%A8%E7%BD%B2%E5%86%99%E6%80%A7%E8%83%BD%E6%B5%8B%E8%AF%95)
    - [磁盘性能](#%E7%A3%81%E7%9B%98%E6%80%A7%E8%83%BD)
    - [网络性能](#%E7%BD%91%E7%BB%9C%E6%80%A7%E8%83%BD)
    - [创建topic](#%E5%88%9B%E5%BB%BAtopic)
    - [10W级数据](#10w%E7%BA%A7%E6%95%B0%E6%8D%AE)
      - [3节点1分区1副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA1%E5%89%AF%E6%9C%AC)
      - [3节点1分区2副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC)
      - [3节点3分区2副本](#3%E8%8A%82%E7%82%B93%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC)
    - [100W级数据](#100w%E7%BA%A7%E6%95%B0%E6%8D%AE)
      - [3节点1分区1副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA1%E5%89%AF%E6%9C%AC-1)
      - [3节点1分区2副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-1)
      - [3节点3分区2副本](#3%E8%8A%82%E7%82%B93%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-1)
    - [1000W级数据](#1000w%E7%BA%A7%E6%95%B0%E6%8D%AE)
      - [3节点1分区1副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA1%E5%89%AF%E6%9C%AC-2)
      - [3节点3分区2副本](#3%E8%8A%82%E7%82%B93%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-2)
  - [基于k8s部署写性能测试](#%E5%9F%BA%E4%BA%8Ek8s%E9%83%A8%E7%BD%B2%E5%86%99%E6%80%A7%E8%83%BD%E6%B5%8B%E8%AF%95)
    - [创建topic](#%E5%88%9B%E5%BB%BAtopic-1)
    - [测试磁盘性能](#%E6%B5%8B%E8%AF%95%E7%A3%81%E7%9B%98%E6%80%A7%E8%83%BD)
      - [POD间网络性能](#pod%E9%97%B4%E7%BD%91%E7%BB%9C%E6%80%A7%E8%83%BD)
    - [10W级数据](#10w%E7%BA%A7%E6%95%B0%E6%8D%AE-1)
      - [3节点1分区1副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA1%E5%89%AF%E6%9C%AC-3)
      - [3节点1分区2副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-2)
      - [3节点3分区2副本](#3%E8%8A%82%E7%82%B93%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-3)
    - [100W级数据](#100w%E7%BA%A7%E6%95%B0%E6%8D%AE-1)
      - [3节点1分区1副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA1%E5%89%AF%E6%9C%AC-4)
      - [3节点1分区2副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-3)
      - [3节点3分区2副本](#3%E8%8A%82%E7%82%B93%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-4)
    - [1000W级数据](#1000w%E7%BA%A7%E6%95%B0%E6%8D%AE-1)
      - [3节点1分区1副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA1%E5%89%AF%E6%9C%AC-5)
      - [3节点3分区2副本](#3%E8%8A%82%E7%82%B93%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-5)
    - [1亿级数据](#1%E4%BA%BF%E7%BA%A7%E6%95%B0%E6%8D%AE)
      - [3节点1分区1副本](#3%E8%8A%82%E7%82%B91%E5%88%86%E5%8C%BA1%E5%89%AF%E6%9C%AC-6)
      - [3节点3分区2副本](#3%E8%8A%82%E7%82%B93%E5%88%86%E5%8C%BA2%E5%89%AF%E6%9C%AC-6)
  - [测试结果](#%E6%B5%8B%E8%AF%95%E7%BB%93%E6%9E%9C)
    - [裸机写](#%E8%A3%B8%E6%9C%BA%E5%86%99)
    - [容器写](#%E5%AE%B9%E5%99%A8%E5%86%99)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# kafka性能测试

## 环境说明

- `k8s version`: `v1.18.6`
- `k8s CNI`: `calico`

## 基于虚机部署写性能测试

- `--num-records` 总记录数
- `--record-size` 每条记录大小（单位:字节）
- `--throughput` 每秒写入记录数

- `kafka`集群节点
    - `192.168.1.90:9092`
    - `192.168.1.91:9092`
    - `192.168.1.92:9092`
- `zk`节点：`192.168.1.90:2181`
- `测试机`：192.168.1.69

### 磁盘性能

> kafka服务端写性能

    [root@localhost ~]# sync;time -p bash -c "(dd if=/dev/zero of=test.dd bs=1M count=20000)"
    20000+0 records in
    20000+0 records out
    20971520000 bytes (21 GB) copied, 51.3453 s, 408 MB/s
    real 51.35
    user 0.03
    sys 11.59

即写入速度为`408MB/s`

> kafka服务端读性能

    yum install -y hdparm
    [root@localhost ~]# hdparm -tT --direct /dev/sda
    
    /dev/sda:
     Timing O_DIRECT cached reads:   6302 MB in  2.00 seconds = 3156.59 MB/sec
     Timing O_DIRECT disk reads: 1628 MB in  3.00 seconds = 542.30 MB/sec
     
经过磁盘`cache`的磁盘读取为`3156.59 MB/sec`

未经过磁盘`cache`的磁盘读取为`542.30 MB/sec`

### 网络性能

> kafka服务端开启监听

    yum install -y qperf
    [root@localhost ~]# qperf
    
> 客户端测试

    yum install -y qperf
    [root@ceph01 local]# qperf -t 10 192.168.1.90 tcp_bw tcp_lat
    tcp_bw:
        bw  =  118 MB/sec
    tcp_lat:
        latency  =  69.4 us

即网络瓶颈为`118 MB/sec`，千兆级网卡

### 创建topic

> 创建`topic`

`1`分区`1`副本

    /usr/local/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.1.90:2181 --topic test_perf --replication-factor 1 --partitions 1
    
`1`分区`2`副本

    /usr/local/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.1.90:2181 --topic test_perf1 --replication-factor 2 --partitions 1

`3`分区`2`副本

    /usr/local/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.1.90:2181 --topic test_perf2 --replication-factor 2 --partitions 3
    
    
### 10W级数据

#### 3节点1分区1副本

> 测试`10W`写记录,每条记录`1000`字节，每次写入`2000`条记录

第一次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1999.080423 records/sec (1.91 MB/sec), 1.04 ms avg latency, 365.00 ms max latency, 0 ms 50th, 1 ms 95th, 3 ms 99th, 81 ms 99.9th.
   
第二次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1999.120387 records/sec (1.91 MB/sec), 0.59 ms avg latency, 330.00 ms max latency, 0 ms 50th, 1 ms 95th, 2 ms 99th, 21 ms 99.9th.
    
第三次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1998.800720 records/sec (1.91 MB/sec), 0.59 ms avg latency, 327.00 ms max latency, 0 ms 50th, 1 ms 95th, 2 ms 99th, 22 ms 99.9th.
    
第四次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1998.960541 records/sec (1.91 MB/sec), 0.59 ms avg latency, 331.00 ms max latency, 0 ms 50th, 1 ms 95th, 2 ms 99th, 25 ms 99.9th.
    
第五次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1999.120387 records/sec (1.91 MB/sec), 0.57 ms avg latency, 340.00 ms max latency, 0 ms 50th, 1 ms 95th, 2 ms 99th, 21 ms 99.9th.
    
本例中消费`10w`条消息为例总共消费了(100000/1024=97.65Mb)的数据，平均每秒消费数据大小为`1.91MB`，总共消费了`100000`条消息，平均每秒消费`1998`条消息，`95%`的消息写入平均`1ms`时延，
    
#### 3节点1分区2副本

> 测试`10W`写记录,每条记录`1000`字节，每次写入`2000`条记录

第一次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1998.800720 records/sec (1.91 MB/sec), 1.08 ms avg latency, 352.00 ms max latency, 1 ms 50th, 1 ms 95th, 3 ms 99th, 79 ms 99.9th.

第二次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1999.280259 records/sec (1.91 MB/sec), 0.66 ms avg latency, 299.00 ms max latency, 1 ms 50th, 1 ms 95th, 2 ms 99th, 24 ms 99.9th.

第三次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1998.800720 records/sec (1.91 MB/sec), 0.62 ms avg latency, 305.00 ms max latency, 0 ms 50th, 1 ms 95th, 2 ms 99th, 22 ms 99.9th.
    
第四次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1998.960541 records/sec (1.91 MB/sec), 0.63 ms avg latency, 316.00 ms max latency, 0 ms 50th, 1 ms 95th, 2 ms 99th, 26 ms 99.9th.
    
第五次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1999.000500 records/sec (1.91 MB/sec), 0.62 ms avg latency, 302.00 ms max latency, 0 ms 50th, 1 ms 95th, 2 ms 99th, 22 ms 99.9th.
    
本例中消费`10w`条消息为例总共消费了(100000/1024=97.65Mb)的数据，平均每秒消费数据大小为`1.91MB`，总共消费了`100000`条消息，平均每秒消费`1998`条消息，`95%`的消息写入平均`1ms`时延
    
#### 3节点3分区2副本

> 测试`10W`写记录,每条记录`1000`字节，每次写入`2000`条记录

第一次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1998.960541 records/sec (1.91 MB/sec), 0.86 ms avg latency, 297.00 ms max latency, 1 ms 50th, 1 ms 95th, 3 ms 99th, 74 ms 99.9th.

第二次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1999.160353 records/sec (1.91 MB/sec), 0.71 ms avg latency, 322.00 ms max latency, 1 ms 50th, 1 ms 95th, 2 ms 99th, 27 ms 99.9th.
    
第三次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1999.120387 records/sec (1.91 MB/sec), 0.77 ms avg latency, 325.00 ms max latency, 1 ms 50th, 1 ms 95th, 3 ms 99th, 35 ms 99.9th.
    
第四次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1998.800720 records/sec (1.91 MB/sec), 0.72 ms avg latency, 307.00 ms max latency, 1 ms 50th, 1 ms 95th, 3 ms 99th, 27 ms 99.9th.
    
第五次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    100000 records sent, 1998.880627 records/sec (1.91 MB/sec), 0.63 ms avg latency, 305.00 ms max latency, 1 ms 50th, 1 ms 95th, 2 ms 99th, 18 ms 99.9th.
    
本例中消费`10w`条消息为例总共消费了(100000/1024=97.65Mb)的数据，平均每秒消费数据大小为`1.91MB`，总共消费了`100000`条消息，平均每秒消费`1998`条消息，`95%`的消息写入平均`1ms`时延，
    
### 100W级数据

#### 3节点1分区1副本

> 测试`100W`写记录,每条记录`2000`字节，每次写入`5000`条记录

第一次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.500050 records/sec (9.54 MB/sec), 0.68 ms avg latency, 305.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 38 ms 99.9th.
   
第二次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.400072 records/sec (9.54 MB/sec), 0.68 ms avg latency, 305.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 40 ms 99.9th.
    
第三次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.400072 records/sec (9.54 MB/sec), 0.69 ms avg latency, 314.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 44 ms 99.9th.
    
第四次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.250112 records/sec (9.54 MB/sec), 0.73 ms avg latency, 299.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 69 ms 99.9th.
    
第五次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.475055 records/sec (9.54 MB/sec), 0.70 ms avg latency, 315.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 44 ms 99.9th.

#### 3节点1分区2副本

> 测试`100W`写记录,每条记录`2000`字节，每次写入`5000`条记录

第一次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.500050 records/sec (9.54 MB/sec), 0.86 ms avg latency, 299.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 38 ms 99.9th.
    
第二次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.450060 records/sec (9.54 MB/sec), 0.74 ms avg latency, 306.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 36 ms 99.9th.

第三次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.550040 records/sec (9.54 MB/sec), 0.86 ms avg latency, 324.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 52 ms 99.9th.
    
第四次

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.400072 records/sec (9.54 MB/sec), 0.76 ms avg latency, 313.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 40 ms 99.9th.
    
#### 3节点3分区2副本

> 测试`100W`写记录,每条记录`2000`字节，每次写入`5000`条记录

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf2 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    1000000 records sent, 4999.425066 records/sec (9.54 MB/sec), 0.85 ms avg latency, 347.00 ms max latency, 1 ms 50th, 1 ms 95th, 2 ms 99th, 41 ms 99.9th.
    
### 1000W级数据

#### 3节点1分区1副本

> 测试`1000W`写记录,每条记录`2000`字节，每次写入`5000`条记录

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf --num-records 10000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    10000000 records sent, 4999.950000 records/sec (9.54 MB/sec), 0.61 ms avg latency, 288.00 ms max latency, 1 ms 50th, 1 ms 95th, 1 ms 99th, 3 ms 99.9th.
    
#### 3节点3分区2副本

> 测试`1000W`写记录,每条记录`2000`字节，每次写入`10000`条记录

    [root@ceph01 local]# /usr/local/kafka/bin/kafka-producer-perf-test.sh --topic test_perf2 --num-records 10000000 --record-size 2000  --throughput 10000 --producer-props bootstrap.servers=192.168.1.90:9092,192.168.1.91:9092,192.168.1.92:9092
    ...
    10000000 records sent, 9999.830003 records/sec (19.07 MB/sec), 0.91 ms avg latency, 396.00 ms max latency, 1 ms 50th, 1 ms 95th, 2 ms 99th, 10 ms 99.9th.
        
## 基于k8s部署写性能测试

- `--num-records` 总记录数
- `--record-size` 每条记录大小（单位:字节）
- `--throughput` 每秒写入记录数

### 创建topic

> 连接`kafka-cli pod`

    kubectl -n test exec -it kafka-producer-c8c99865c-rgcx7 -- sh
    
> 创建`topic`

`1`分区`1`副本

    kafka-topics.sh --create --zookeeper zookeeper:2181 --topic test_perf --replication-factor 1 --partitions 1
    
`1`分区`2`副本

    kafka-topics.sh --create --zookeeper zookeeper:2181 --topic test_perf1 --replication-factor 2 --partitions 1

`3`分区`2`副本

    kafka-topics.sh --create --zookeeper zookeeper:2181 --topic test_perf2 --replication-factor 2 --partitions 3
    
`6`分区`2`副本

    kafka-topics.sh --create --zookeeper zookeeper:2181 --topic test_perf3 --replication-factor 2 --partitions 6

### 测试磁盘性能

> pod磁盘写性能

    [root@node3 ~]# kubectl -n test exec -it kafka-producer-c8c99865c-rgcx7 -- sh
    / # sync;time -p bash -c "(dd if=/dev/zero of=test.dd bs=1M count=20000)"
    20000+0 records in
    20000+0 records out
    real 15.66
    user 0.01
    sys 15.59

> 节点磁盘写性能

    [root@node3 ~]# sync;time -p bash -c "(dd if=/dev/zero of=test.dd bs=1M count=20000)"
    20000+0 records in
    20000+0 records out
    20971520000 bytes (21 GB) copied, 23.5524 s, 890 MB/s
    real 25.24
    user 0.01
    sys 19.84

#### POD间网络性能

> 创建服务端pod

    cat <<EOF > net-server.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: qperf-server
      labels:
        app: qperf-server
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: qperf-server
      template:
        metadata:
          labels:
            app: qperf-server
        spec:
          containers:
          - name: qperf-server
            image: xridge/qperf:0.4.11-r0
            command: ["/bin/sh","-c","while true;do sleep 1;done"]
    EOF
    
    kubectl apply -f net-server.yaml
    
    
开启监听

    kubectl exec -it qperf-server-5945979cf7-sqgkx qperf
    
> 创建客户端pod

    cat <<EOF > net-client.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: qperf-client
      labels:
        app: qperf-client
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: qperf-client
      template:
        metadata:
          labels:
            app: qperf-client
        spec:
          containers:
          - name: qperf-client
            image: xridge/qperf:0.4.11-r0
            command: ["/bin/sh","-c","while true;do sleep 1;done"]
    EOF
    
    kubectl apply -f net-client.yaml
    
    
开启监听

    kubectl exec -it qperf-server-5945979cf7-sqgkx qperf
    
测试

    [root@node3 ddd]# kubectl exec -it qperf-client-7cc4f59797-gz8tt -- qperf -t 10 10.233.92.56 tcp_bw tcp_lat
    tcp_bw:
        bw  =  883 MB/sec
    tcp_lat:
        latency  =  51.9 us
        
测试集群节点间网络传输

    [root@node3 ddd]# qperf -t 10 192.168.1.109 tcp_bw tcp_lat
    tcp_bw:
        bw  =  1.14 GB/sec
    tcp_lat:
        latency  =  40.3 us

### 10W级数据

#### 3节点1分区1副本

> 测试`10W`写记录,每条记录`1000`字节，每次写入`2000`条记录

第一次

    kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.200320 records/sec (1.91 MB/sec), 0.96 ms avg latency, 510.00 ms max latency, 1 ms 50th, 1 ms 95th, 21 ms 99th, 34 ms 99.9th
   
第二次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.200320 records/sec (1.91 MB/sec), 1.15 ms avg latency, 533.00 ms max latency, 1 ms 50th, 1 ms 95th, 29 ms 99th, 44 ms 99.9th.
    
第三次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.240289 records/sec (1.91 MB/sec), 0.99 ms avg latency, 489.00 ms max latency, 1 ms 50th, 1 ms 95th, 20 ms 99th, 34 ms 99.9th.
    
第四次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1998.880627 records/sec (1.91 MB/sec), 0.98 ms avg latency, 484.00 ms max latency, 1 ms 50th, 1 ms 95th, 23 ms 99th, 33 ms 99.9th.
    
第五次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.000500 records/sec (1.91 MB/sec), 1.05 ms avg latency, 518.00 ms max latency, 1 ms 50th, 1 ms 95th, 26 ms 99th, 39 ms 99.9th.
    
本例中消费`10w`条消息为例总共消费了(100000/1024=97.65Mb)的数据，平均每秒消费数据大小为`1.91MB`，总共消费了`100000`条消息，平均每秒消费`1998`条消息，`95%`的消息写入平均`1ms`时延，
    
#### 3节点1分区2副本

> 测试`10W`写记录,每条记录`1000`字节，每次写入`2000`条记录

第一次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.040461 records/sec (1.91 MB/sec), 1.68 ms avg latency, 502.00 ms max latency, 1 ms 50th, 4 ms 95th, 31 ms 99th, 45 ms 99.9th.

第二次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.120387 records/sec (1.91 MB/sec), 1.71 ms avg latency, 464.00 ms max latency, 1 ms 50th, 3 ms 95th, 31 ms 99th, 67 ms 99.9th.    
    
第三次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1998.920583 records/sec (1.91 MB/sec), 1.41 ms avg latency, 476.00 ms max latency, 1 ms 50th, 3 ms 95th, 20 ms 99th, 29 ms 99.9th.
    
第四次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1998.920583 records/sec (1.91 MB/sec), 1.39 ms avg latency, 466.00 ms max latency, 1 ms 50th, 3 ms 95th, 24 ms 99th, 48 ms 99.9th.
    
第五次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    100000 records sent, 1999.000500 records/sec (1.91 MB/sec), 1.55 ms avg latency, 453.00 ms max latency, 1 ms 50th, 3 ms 95th, 30 ms 99th, 48 ms 99.9th.
    
本例中消费`10w`条消息为例总共消费了(100000/1024=97.65Mb)的数据，平均每秒消费数据大小为`1.91MB`，总共消费了`100000`条消息，平均每秒消费`1998`条消息，`95%`的消息写入平均`3ms`时延，
    
#### 3节点3分区2副本


> 测试`10W`写记录,每条记录`1000`字节，每次写入`2000`条记录

第一次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.040461 records/sec (1.91 MB/sec), 2.14 ms avg latency, 491.00 ms max latency, 1 ms 50th, 2 ms 95th, 60 ms 99th, 141 ms 99.9th.
    
第二次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1998.880627 records/sec (1.91 MB/sec), 1.35 ms avg latency, 515.00 ms max latency, 1 ms 50th, 2 ms 95th, 29 ms 99th, 45 ms 99.9th.
    
第三次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1998.960541 records/sec (1.91 MB/sec), 1.42 ms avg latency, 512.00 ms max latency, 1 ms 50th, 2 ms 95th, 36 ms 99th, 50 ms 99.9th.

第四次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.040461 records/sec (1.91 MB/sec), 1.54 ms avg latency, 480.00 ms max latency, 1 ms 50th, 2 ms 95th, 32 ms 99th, 64 ms 99.9th.
    
第五次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000 --record-size 1000  --throughput 2000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    100000 records sent, 1999.040461 records/sec (1.91 MB/sec), 1.38 ms avg latency, 461.00 ms max latency, 1 ms 50th, 2 ms 95th, 30 ms 99th, 48 ms 99.9th.

本例中消费`10w`条消息为例总共消费了(100000/1024=97.65Mb)的数据，平均每秒消费数据大小为`1.91MB`，总共消费了`100000`条消息，平均每秒消费`1999`条消息，`95%`的消息写入平均`2ms`时延，

### 100W级数据

#### 3节点1分区1副本

> 测试`100W`写记录,每条记录`2000`字节，每次写入`5000`条记录

第一次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.300098 records/sec (9.54 MB/sec), 1.55 ms avg latency, 472.00 ms max latency, 1 ms 50th, 1 ms 95th, 14 ms 99th, 219 ms 99.9th.

第二次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.475055 records/sec (9.54 MB/sec), 1.16 ms avg latency, 450.00 ms max latency, 1 ms 50th, 1 ms 95th, 13 ms 99th, 99 ms 99.9th.
    
第三次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.300098 records/sec (9.54 MB/sec), 1.31 ms avg latency, 467.00 ms max latency, 1 ms 50th, 1 ms 95th, 16 ms 99th, 128 ms 99.9th.

第四次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.350084 records/sec (9.54 MB/sec), 1.30 ms avg latency, 469.00 ms max latency, 1 ms 50th, 1 ms 95th, 16 ms 99th, 125 ms 99.9th.
    
第五次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.325091 records/sec (9.54 MB/sec), 1.43 ms avg latency, 516.00 ms max latency, 1 ms 50th, 1 ms 95th, 16 ms 99th, 175 ms 99.9th.

本例中消费`100w`条消息为例总共消费了(1000000/1024=976.5Mb)的数据，平均每秒消费数据大小为`9.54MB`，总共消费了`1000000`条消息，平均每秒消费`4999`条消息，`95%`的消息写入平均`1ms`时延，


#### 3节点1分区2副本

> 测试`100W`写记录,每条记录`2000`字节，每次写入`5000`条记录

第一次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.400072 records/sec (9.54 MB/sec), 2.30 ms avg latency, 486.00 ms max latency, 1ms 50th, 7 ms 95th, 27 ms 99th, 201 ms 99.9th.

第二次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.450060 records/sec (9.54 MB/sec), 1.79 ms avg latency, 487.00 ms max latency, 1 ms 50th, 5 ms 95th, 25 ms 99th, 116 ms 99.9th.

第三次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.325091 records/sec (9.54 MB/sec), 2.08 ms avg latency, 450.00 ms max latency, 1 ms 50th, 7 ms 95th, 27 ms 99th, 138 ms 99.9th.

第四次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.225120 records/sec (9.54 MB/sec), 2.20 ms avg latency, 513.00 ms max latency, 1 ms 50th, 7 ms 95th, 27 ms 99th, 148 ms 99.9th.

第五次

    / # kafka-producer-perf-test.sh --topic test_perf1 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.450060 records/sec (9.54 MB/sec), 1.84 ms avg latency, 466.00 ms max latency, 1 ms 50th, 4 ms 95th, 24 ms 99th, 144 ms 99.9th.

本例中消费`100w`条消息为例总共消费了(1000000/1024=976.5Mb)的数据，平均每秒消费数据大小为`9.54MB`，总共消费了`1000000`条消息，平均每秒消费`4999`条消息，`95%`的消息写入平均`6ms`时延，


#### 3节点3分区2副本

> 测试`100W`写记录,每条记录`2000`字节，每次写入`5000`条记录

第一次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.250112 records/sec (9.54 MB/sec), 1.66 ms avg latency, 479.00 ms max latency, 1 ms 50th, 3 ms 95th, 20 ms 99th, 112 ms 99.9th.
    
第二次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.250112 records/sec (9.54 MB/sec), 1.42 ms avg latency, 479.00 ms max latency, 1 ms 50th, 2 ms 95th, 20 ms 99th, 95 ms 99.9th.

第三次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.425066 records/sec (9.54 MB/sec), 1.65 ms avg latency, 502.00 ms max latency, 1 ms 50th, 3 ms 95th, 20 ms 99th, 127 ms 99.9th.
  
第四次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.250112 records/sec (9.54 MB/sec), 1.55 ms avg latency, 537.00 ms max latency, 1 ms 50th, 2 ms 95th, 20 ms 99th, 130 ms 99.9th.
  
第五次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 1000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    1000000 records sent, 4999.375078 records/sec (9.54 MB/sec), 1.68 ms avg latency, 504.00 ms max latency, 1 ms 50th, 3 ms 95th, 20 ms 99th, 122 ms 99.9th.
    
本例中消费`100w`条消息为例总共消费了(1000000/1024=976.5Mb)的数据，平均每秒消费数据大小为`9.54MB`，总共消费了`1000000`条消息，平均每秒消费`4999`条消息，`95%`的消息写入平均`2.6ms`时延，

### 1000W级数据

#### 3节点1分区1副本
    
> 测试`1000W`写记录,每条记录`2000`字节，每次写入`5000`条记录

第一次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 10000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    10000000 records sent, 4999.942501 records/sec (9.54 MB/sec), 1.00 ms avg latency, 453.00 ms max latency, 1 ms 50th, 1 ms 95th, 11 ms 99th, 27 ms 99.9th.

第二次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 10000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    10000000 records sent, 4999.945001 records/sec (9.54 MB/sec), 1.00 ms avg latency, 535.00 ms max latency, 1 ms 50th, 1 ms 95th, 10 ms 99th, 25 ms 99.9t
    
第三次

    / # kafka-producer-perf-test.sh --topic test_perf --num-records 10000000 --record-size 2000  --throughput 5000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    10000000 records sent, 4999.945001 records/sec (9.54 MB/sec), 0.97 ms avg latency, 474.00 ms max latency, 1 ms 50th, 1 ms 95th, 10 ms 99th, 25 ms 99.9th.
    
#### 3节点3分区2副本

> 测试`1000W`写记录,每条记录`2000`字节，每次写入`10000`条记录

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 10000000 --record-size 2000  --throughput 10000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    10000000 records sent, 9999.720008 records/sec (19.07 MB/sec), 1.59 ms avg latency, 469.00 ms max latency, 1 ms 50th, 3 ms 95th, 18 ms 99th, 31 ms 99.9th.
    
> 测试`1000W`写记录,每条记录`2000`字节，每次写入`100000`条记录

第一次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 10000000 --record-size 2000  --throughput 100000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    10000000 records sent, 46716.965266 records/sec (89.11 MB/sec), 348.93 ms avg latency, 1178.00 ms max latency, 7 ms 50th, 1053 ms 95th, 1089 ms 99th, 1139 ms 99.9th.
  
第二次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 10000000 --record-size 2000  --throughput 100000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...  
    000000 records sent, 56427.995057 records/sec (107.63 MB/sec), 288.78 ms avg latency, 1000.00 ms max latency, 30 ms 50th, 864 ms 95th, 901 ms 99th, 947 ms 99.9th.  

第三次

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 10000000 --record-size 2000  --throughput 100000 --producer-props bootstrap.servers=kafka-pyegtd:9092
    ...
    10000000 records sent, 55682.697715 records/sec (106.21 MB/sec), 292.63 ms avg latency, 987.00 ms max latency, 23 ms 50th, 881 ms 95th, 915 ms 99th, 953 ms 99.9th.

### 1亿级数据

#### 3节点1分区1副本
    
> 测试`1亿`写记录,每条记录`2000`字节，每次写入`100万`条记录


    / # kafka-producer-perf-test.sh --topic test_perf --num-records 100000000 --record-size 2000  --throughput 1000000 --producer-props bootstrap.servers=k
    afka-pyegtd:9092
    ...
    100000000 records sent, 24660.395528 records/sec (47.04 MB/sec), 664.22 ms avg latency, 921.00 ms max latency, 665 ms 50th, 710 ms 95th, 730 ms 99th, 765 ms 99.9th.
    
#### 3节点3分区2副本

> 测试`1亿`写记录,每条记录`2000`字节，每次写入`100万`条记录

    / # kafka-producer-perf-test.sh --topic test_perf2 --num-records 100000000 --record-size 2000  --throughput 1000000 --producer-props bootstrap.servers=k
    afka-pyegtd:9092
    ...   
    100000000 records sent, 59408.105167 records/sec (113.31 MB/sec), 275.60 ms avg latency, 1061.00 ms max latency, 46 ms 50th, 823 ms 95th, 868 ms 99th, 915 ms 99.9th 

## 测试结果

### 裸机写

| 消息总数（万） | 单个消息大小（字节） | 每秒发送消息数 | 节点数 |分区数 | 副本数 | 95%的消息延迟(单位:ms) | 写速率（MB/sec） |
| :-----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | 
| 10 | 1000 | 2000 |3|1|1|1|1.91|
| 10 | 1000 | 2000 |3|1|2|1|1.91|
| 10 | 1000 | 2000 |3|3|2|1|1.91|
| 100 | 2000 | 5000 |3|1|1|1|9.54|
| 100 | 2000 | 5000 |3|1|2|1|9.54|
| 100 | 2000 | 5000 |3|3|2|1|9.54|
| 1000 | 2000 | 5000 |3|1|1|1|9.54|
| 1000 | 2000 | 10000 |3|3|2|1|19.07|
| 1000 | 2000 | 100000 |3|3|2|830|105.02|

### 容器写

| 消息总数（万） | 单个消息大小（字节） | 每秒发送消息数 | 节点数 |分区数 | 副本数 | 95%的消息延迟(单位:ms) | 写速率（MB/sec） |
| :-----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: | 
| 10 | 1000 | 2000 |3|1|1|1|1.91|
| 10 | 1000 | 2000 |3|1|2|3|1.91|
| 10 | 1000 | 2000 |3|3|2|2|1.91|
| 100 | 2000 | 5000 |3|1|1|1|9.54|
| 100 | 2000 | 5000 |3|1|2|6|9.54|
| 100 | 2000 | 5000 |3|3|2|2.6|9.54|
| 1000 | 2000 | 5000 |3|1|1|1|9.54|
| 1000 | 2000 | 10000 |3|3|2|3|19.07|
| 1000 | 2000 | 100000 |3|3|2|1051|90.08|
| 10000 | 2000 | 1000000 |3|1|1|710|47.04|
| 10000 | 2000 | 1000000 |3|3|2|823|113.31|

    