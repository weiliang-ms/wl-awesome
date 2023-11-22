# FIO测试磁盘性能

## 安装FIO

`CentOS7`

```shell
$ sudo yum install epel-release -y
$ sudo yum install fio -y
```

## 读性能测试

测试参数

- `-direct=1`: 绕过机器自带的buffer，使结果更真实
- `-iodepth`: 队列深度为1
- `-bs=16k`: 单次io的块文件大小为16k
- `-size=10G`: 每个线程读写的文件总大小
- `-numjobs=10`: 线程数为10
- `-name`: 创建的文件名称
- `-group_reporting`: 多个任务整合统计信息
- `-rw`参数: 当指定了混合读写时，可以指定`rwmixread`或者`rwmixwrite`的值，代表`read`或者`write`所占的百分比，
如果指定了两个并且相加不等于100，后指定的值会覆盖先指定的值
    - `read`: 顺序读
    - `write`: 顺序写
    - `rw，readwrite`: 顺序混合读写
    - `randwrite`: 随机写
    - `randread`: 随机读
    - `randrw`: 随机混合读写
    
### 测试SSD同步IO顺序读

````shell
$ fio -filename=/dev/sdd -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=10G -numjobs=10 -group_reporting -name=read-psync
read-psync: (g=0): rw=read, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 6 (f=6): [_(1),R(3),_(2),R(3),_(1)][100.0%][r=321MiB/s,w=0KiB/s][r=20.6k,w=0 IOPS][eta 00m:00s]
read-psync: (groupid=0, jobs=10): err= 0: pid=2478973: Thu Mar 10 11:43:35 2022
   read: IOPS=20.9k, BW=326MiB/s (342MB/s)(100GiB/314243msec)
    clat (usec): min=60, max=9522, avg=477.90, stdev=165.94
     lat (usec): min=60, max=9522, avg=478.05, stdev=165.94
    clat percentiles (usec):
     |  1.00th=[  215],  5.00th=[  277], 10.00th=[  314], 20.00th=[  363],
     | 30.00th=[  400], 40.00th=[  433], 50.00th=[  461], 60.00th=[  494],
     | 70.00th=[  529], 80.00th=[  578], 90.00th=[  652], 95.00th=[  717],
     | 99.00th=[  898], 99.50th=[  996], 99.90th=[ 2180], 99.95th=[ 3326],
     | 99.99th=[ 3752]
   bw (  KiB/s): min=27168, max=43654, per=10.01%, avg=33385.73, stdev=1076.11, samples=6273
   iops        : min= 1698, max= 2728, avg=2086.59, stdev=67.26, samples=6273
  lat (usec)   : 100=0.01%, 250=2.81%, 500=58.83%, 750=34.68%, 1000=3.18%
  lat (msec)   : 2=0.38%, 4=0.10%, 10=0.01%
  cpu          : usr=0.63%, sys=2.01%, ctx=6553669, majf=0, minf=1097
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=6553600,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=326MiB/s (342MB/s), 326MiB/s-326MiB/s (342MB/s-342MB/s), io=100GiB (107GB), run=314243-314243msec

Disk stats (read/write):
  sdd: ios=6552419/0, merge=0/0, ticks=3080157/0, in_queue=3080157, util=100.00%
````

### 测试nvme同步IO顺序读

````shell
$ fio -filename=/dev/nvme0n1 -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=10G -numjobs=10 -group_reporting -name=read-psync
read-psync: (g=0): rw=read, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [R(10)][100.0%][r=2824MiB/s,w=0KiB/s][r=181k,w=0 IOPS][eta 00m:00s]
read-psync: (groupid=0, jobs=10): err= 0: pid=2482480: Thu Mar 10 11:46:05 2022
   read: IOPS=175k, BW=2737MiB/s (2870MB/s)(100GiB/37413msec)
    clat (usec): min=13, max=9453, avg=56.59, stdev=34.78
     lat (usec): min=13, max=9453, avg=56.65, stdev=34.78
    clat percentiles (usec):
     |  1.00th=[   43],  5.00th=[   45], 10.00th=[   53], 20.00th=[   55],
     | 30.00th=[   55], 40.00th=[   55], 50.00th=[   56], 60.00th=[   56],
     | 70.00th=[   56], 80.00th=[   56], 90.00th=[   58], 95.00th=[   66],
     | 99.00th=[   78], 99.50th=[  186], 99.90th=[  379], 99.95th=[  469],
     | 99.99th=[ 1156]
   bw (  KiB/s): min=58112, max=290752, per=10.00%, avg=280168.34, stdev=43530.84, samples=740
   iops        : min= 3632, max=18172, avg=17510.48, stdev=2720.67, samples=740
  lat (usec)   : 20=0.04%, 50=7.22%, 100=91.88%, 250=0.57%, 500=0.26%
  lat (usec)   : 750=0.03%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=0.01%, 10=0.01%
  cpu          : usr=1.82%, sys=6.93%, ctx=6553613, majf=0, minf=495
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=6553600,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=2737MiB/s (2870MB/s), 2737MiB/s-2737MiB/s (2870MB/s-2870MB/s), io=100GiB (107GB), run=37413-37413msec

Disk stats (read/write):
  nvme0n1: ios=6550969/0, merge=0/0, ticks=352122/0, in_queue=352122, util=99.79%
````

### 测试SSD同步IO随机读

````shell
$ fio -filename=/dev/sdd -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=10G -numjobs=10 -group_reporting -name=randread-psync
randread-psync: (g=0): rw=randread, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [r(10)][100.0%][r=331MiB/s,w=0KiB/s][r=21.2k,w=0 IOPS][eta 00m:00s]
randread-psync: (groupid=0, jobs=10): err= 0: pid=2499967: Thu Mar 10 13:53:49 2022
   read: IOPS=21.2k, BW=331MiB/s (347MB/s)(100GiB/309571msec)
    clat (usec): min=84, max=4617, avg=470.57, stdev=133.23
     lat (usec): min=84, max=4617, avg=470.72, stdev=133.23
    clat percentiles (usec):
     |  1.00th=[  221],  5.00th=[  281], 10.00th=[  314], 20.00th=[  359],
     | 30.00th=[  396], 40.00th=[  429], 50.00th=[  457], 60.00th=[  490],
     | 70.00th=[  529], 80.00th=[  570], 90.00th=[  644], 95.00th=[  701],
     | 99.00th=[  840], 99.50th=[  898], 99.90th=[ 1045], 99.95th=[ 1123],
     | 99.99th=[ 2212]
   bw (  KiB/s): min=31425, max=34976, per=10.00%, avg=33881.65, stdev=305.23, samples=6180
   iops        : min= 1964, max= 2186, avg=2117.57, stdev=19.09, samples=6180
  lat (usec)   : 100=0.01%, 250=2.50%, 500=60.42%, 750=34.21%, 1000=2.72%
  lat (msec)   : 2=0.15%, 4=0.01%, 10=0.01%
  cpu          : usr=0.72%, sys=2.13%, ctx=6553627, majf=0, minf=3316
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=6553600,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=331MiB/s (347MB/s), 331MiB/s-331MiB/s (347MB/s-347MB/s), io=100GiB (107GB), run=309571-309571msec

Disk stats (read/write):
  sdd: ios=6551962/0, merge=0/0, ticks=3030207/0, in_queue=3030207, util=100.00%
````

### 测试nvme同步IO随机读

````shell
$ fio -filename=/dev/nvme0n1 -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=10G -numjobs=10 -group_reporting -name=randread-psync
randread-psync: (g=0): rw=randread, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 9 (f=9): [r(2),_(1),r(7)][100.0%][r=2824MiB/s,w=0KiB/s][r=181k,w=0 IOPS][eta 00m:00s]
randread-psync: (groupid=0, jobs=10): err= 0: pid=2503509: Thu Mar 10 13:56:25 2022
   read: IOPS=180k, BW=2816MiB/s (2953MB/s)(100GiB/36360msec)
    clat (usec): min=15, max=4327, avg=54.67, stdev=22.23
     lat (usec): min=15, max=4327, avg=54.72, stdev=22.23
    clat percentiles (usec):
     |  1.00th=[   26],  5.00th=[   29], 10.00th=[   31], 20.00th=[   37],
     | 30.00th=[   44], 40.00th=[   51], 50.00th=[   56], 60.00th=[   60],
     | 70.00th=[   65], 80.00th=[   69], 90.00th=[   75], 95.00th=[   79],
     | 99.00th=[   87], 99.50th=[  172], 99.90th=[  247], 99.95th=[  277],
     | 99.99th=[  334]
   bw (  KiB/s): min=276832, max=299872, per=10.02%, avg=289088.71, stdev=4781.66, samples=719
   iops        : min=17300, max=18742, avg=18068.03, stdev=298.86, samples=719
  lat (usec)   : 20=0.10%, 50=39.17%, 100=59.84%, 250=0.80%, 500=0.09%
  lat (usec)   : 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=0.01%, 10=0.01%
  cpu          : usr=2.10%, sys=7.29%, ctx=6553584, majf=0, minf=1848
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=6553600,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=2816MiB/s (2953MB/s), 2816MiB/s-2816MiB/s (2953MB/s-2953MB/s), io=100GiB (107GB), run=36360-36360msec

Disk stats (read/write):
  nvme0n1: ios=6529198/0, merge=0/0, ticks=338937/0, in_queue=338937, util=99.77%
````

### 测试SSD异步IO顺序读

```shell
$ fio -filename=/dev/sdd -direct=1 -iodepth 1 -thread -rw=read -ioengine=libaio -bs=16k -size=10G -numjobs=10 -group_reporting -name=read-libaio
read-libaio: (g=0): rw=read, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 6 (f=6): [_(1),R(1),_(2),R(3),_(1),R(2)][100.0%][r=307MiB/s,w=0KiB/s][r=19.7k,w=0 IOPS][eta 00m:00s]
read-libaio: (groupid=0, jobs=10): err= 0: pid=2506303: Thu Mar 10 14:06:40 2022
   read: IOPS=20.9k, BW=326MiB/s (342MB/s)(100GiB/314303msec)
    slat (usec): min=3, max=2619, avg= 7.35, stdev= 2.07
    clat (usec): min=4, max=10358, avg=469.94, stdev=159.00
     lat (usec): min=70, max=10365, avg=477.54, stdev=159.02
    clat percentiles (usec):
     |  1.00th=[  208],  5.00th=[  269], 10.00th=[  306], 20.00th=[  355],
     | 30.00th=[  392], 40.00th=[  424], 50.00th=[  453], 60.00th=[  486],
     | 70.00th=[  523], 80.00th=[  570], 90.00th=[  644], 95.00th=[  709],
     | 99.00th=[  889], 99.50th=[  979], 99.90th=[ 1729], 99.95th=[ 3032],
     | 99.99th=[ 3425]
   bw (  KiB/s): min=25824, max=43136, per=10.01%, avg=33392.29, stdev=1077.51, samples=6272
   iops        : min= 1614, max= 2696, avg=2086.98, stdev=67.34, samples=6272
  lat (usec)   : 10=0.01%, 50=0.01%, 100=0.01%, 250=3.27%, 500=60.55%
  lat (usec)   : 750=32.85%, 1000=2.88%
  lat (msec)   : 2=0.35%, 4=0.09%, 10=0.01%, 20=0.01%
  cpu          : usr=0.87%, sys=2.83%, ctx=6553659, majf=0, minf=1405
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=6553600,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=326MiB/s (342MB/s), 326MiB/s-326MiB/s (342MB/s-342MB/s), io=100GiB (107GB), run=314303-314303msec

Disk stats (read/write):
  sdd: ios=6551604/0, merge=0/0, ticks=3065528/0, in_queue=3065528, util=100.00%
```

### 测试nvme异步IO顺序读

```shell
$ fio -filename=/dev/nvme0n1 -direct=1 -iodepth 1 -thread -rw=read -ioengine=libaio -bs=16k -size=10G -numjobs=10 -group_reporting -name=read-libaio
read-libaio: (g=0): rw=read, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [R(10)][100.0%][r=2821MiB/s,w=0KiB/s][r=181k,w=0 IOPS][eta 00m:00s]
read-libaio: (groupid=0, jobs=10): err= 0: pid=2509684: Thu Mar 10 14:08:55 2022
   read: IOPS=175k, BW=2732MiB/s (2865MB/s)(100GiB/37482msec)
    slat (usec): min=2, max=1123, avg= 7.27, stdev= 2.06
    clat (nsec): min=337, max=8036.3k, avg=48376.49, stdev=34033.02
     lat (usec): min=20, max=8044, avg=55.88, stdev=34.01
    clat percentiles (usec):
     |  1.00th=[   33],  5.00th=[   37], 10.00th=[   42], 20.00th=[   45],
     | 30.00th=[   46], 40.00th=[   47], 50.00th=[   47], 60.00th=[   48],
     | 70.00th=[   48], 80.00th=[   49], 90.00th=[   51], 95.00th=[   56],
     | 99.00th=[   67], 99.50th=[  184], 99.90th=[  375], 99.95th=[  469],
     | 99.99th=[  988]
   bw (  KiB/s): min=55712, max=296928, per=10.00%, avg=279700.92, stdev=44654.77, samples=740
   iops        : min= 3482, max=18558, avg=17481.26, stdev=2790.91, samples=740
  lat (nsec)   : 500=0.01%, 750=0.01%, 1000=0.01%
  lat (usec)   : 2=0.01%, 4=0.01%, 10=0.01%, 20=0.02%, 50=87.14%
  lat (usec)   : 100=11.98%, 250=0.57%, 500=0.25%, 750=0.03%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=0.01%, 10=0.01%
  cpu          : usr=6.27%, sys=21.85%, ctx=6553521, majf=0, minf=902
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=6553600,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=2732MiB/s (2865MB/s), 2732MiB/s-2732MiB/s (2865MB/s-2865MB/s), io=100GiB (107GB), run=37482-37482msec

Disk stats (read/write):
  nvme0n1: ios=6540277/0, merge=0/0, ticks=308215/0, in_queue=308215, util=99.85%
```

### 测试ssd异步IO随机读

```shell
$ fio -filename=/dev/sdd -direct=1 -iodepth 1 -thread -rw=randread -ioengine=libaio -bs=16k -size=10G -numjobs=10 -group_reporting -name=randread-libaio
randread-libaio: (g=0): rw=randread, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [r(10)][100.0%][r=331MiB/s,w=0KiB/s][r=21.2k,w=0 IOPS][eta 00m:00s]
randread-libaio: (groupid=0, jobs=10): err= 0: pid=2511004: Thu Mar 10 14:16:03 2022
   read: IOPS=21.2k, BW=331MiB/s (347MB/s)(100GiB/309613msec)
    slat (usec): min=3, max=542, avg= 7.51, stdev= 1.52
    clat (usec): min=4, max=3575, avg=462.73, stdev=131.70
     lat (usec): min=90, max=3582, avg=470.49, stdev=131.69
    clat percentiles (usec):
     |  1.00th=[  215],  5.00th=[  273], 10.00th=[  310], 20.00th=[  355],
     | 30.00th=[  388], 40.00th=[  420], 50.00th=[  449], 60.00th=[  482],
     | 70.00th=[  519], 80.00th=[  562], 90.00th=[  635], 95.00th=[  693],
     | 99.00th=[  832], 99.50th=[  889], 99.90th=[ 1029], 99.95th=[ 1106],
     | 99.99th=[ 2024]
   bw (  KiB/s): min=32768, max=34944, per=10.00%, avg=33869.37, stdev=298.65, samples=6187
   iops        : min= 2048, max= 2184, avg=2116.80, stdev=18.67, samples=6187
  lat (usec)   : 10=0.01%, 100=0.01%, 250=2.99%, 500=62.18%, 750=32.28%
  lat (usec)   : 1000=2.41%
  lat (msec)   : 2=0.13%, 4=0.01%
  cpu          : usr=1.00%, sys=2.90%, ctx=6553667, majf=0, minf=4037
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=6553600,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=331MiB/s (347MB/s), 331MiB/s-331MiB/s (347MB/s-347MB/s), io=100GiB (107GB), run=309613-309613msec

Disk stats (read/write):
  sdd: ios=6549769/0, merge=0/0, ticks=3016849/0, in_queue=3016849, util=100.00%
```

### 测试nvme异步IO随机读

```shell
$ fio -filename=/dev/nvme0n1 -direct=1 -iodepth 1 -thread -rw=randread -ioengine=libaio -bs=16k -size=10G -numjobs=10 -group_reporting -name=randread-libaio
randread-libaio: (g=0): rw=randread, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [r(10)][100.0%][r=2824MiB/s,w=0KiB/s][r=181k,w=0 IOPS][eta 00m:00s]
randread-libaio: (groupid=0, jobs=10): err= 0: pid=2513716: Thu Mar 10 14:18:07 2022
   read: IOPS=180k, BW=2809MiB/s (2946MB/s)(100GiB/36450msec)
    slat (nsec): min=1789, max=773692, avg=7108.12, stdev=2120.98
    clat (nsec): min=1761, max=3667.7k, avg=46282.29, stdev=17098.06
     lat (usec): min=18, max=3674, avg=53.63, stdev=17.19
    clat percentiles (usec):
     |  1.00th=[   30],  5.00th=[   32], 10.00th=[   34], 20.00th=[   37],
     | 30.00th=[   41], 40.00th=[   44], 50.00th=[   46], 60.00th=[   48],
     | 70.00th=[   50], 80.00th=[   53], 90.00th=[   58], 95.00th=[   61],
     | 99.00th=[   72], 99.50th=[  165], 99.90th=[  239], 99.95th=[  269],
     | 99.99th=[  322]
   bw (  KiB/s): min=270400, max=307264, per=10.05%, avg=288971.55, stdev=7424.98, samples=719
   iops        : min=16900, max=19204, avg=18060.71, stdev=464.07, samples=719
  lat (usec)   : 2=0.01%, 4=0.01%, 10=0.01%, 20=0.12%, 50=70.04%
  lat (usec)   : 100=28.97%, 250=0.80%, 500=0.08%, 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=0.01%
  cpu          : usr=7.22%, sys=22.66%, ctx=6553641, majf=0, minf=3533
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=6553600,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=2809MiB/s (2946MB/s), 2809MiB/s-2809MiB/s (2946MB/s-2946MB/s), io=100GiB (107GB), run=36450-36450msec

Disk stats (read/write):
  nvme0n1: ios=6551495/0, merge=0/0, ticks=292982/0, in_queue=292982, util=99.81%
```

## 写性能测试

### 测试SSD同步IO顺序写

```shell
$ fio -filename=/dev/sdd -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=10G -numjobs=10 -group_reporting -name=write-psync
write-psync: (g=0): rw=write, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [W(10)][100.0%][r=0KiB/s,w=355MiB/s][r=0,w=22.7k IOPS][eta 00m:00s]
write-psync: (groupid=0, jobs=10): err= 0: pid=2515721: Thu Mar 10 14:27:00 2022
  write: IOPS=19.9k, BW=311MiB/s (326MB/s)(100GiB/329391msec)
    clat (usec): min=61, max=9638, avg=501.22, stdev=212.02
     lat (usec): min=61, max=9639, avg=501.55, stdev=212.03
    clat percentiles (usec):
     |  1.00th=[  416],  5.00th=[  420], 10.00th=[  424], 20.00th=[  429],
     | 30.00th=[  433], 40.00th=[  437], 50.00th=[  441], 60.00th=[  449],
     | 70.00th=[  469], 80.00th=[  498], 90.00th=[  586], 95.00th=[  701],
     | 99.00th=[ 1647], 99.50th=[ 2073], 99.90th=[ 2442], 99.95th=[ 2540],
     | 99.99th=[ 2704]
   bw (  KiB/s): min= 8128, max=36928, per=10.00%, avg=31827.13, stdev=7781.26, samples=6580
   iops        : min=  508, max= 2308, avg=1989.18, stdev=486.33, samples=6580
  lat (usec)   : 100=0.01%, 250=0.01%, 500=80.42%, 750=15.06%, 1000=1.46%
  lat (msec)   : 2=2.44%, 4=0.62%, 10=0.01%
  cpu          : usr=0.65%, sys=1.57%, ctx=6553628, majf=0, minf=1139
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,6553600,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=311MiB/s (326MB/s), 311MiB/s-311MiB/s (326MB/s-326MB/s), io=100GiB (107GB), run=329391-329391msec

Disk stats (read/write):
  sdd: ios=63/6553444, merge=0/6, ticks=24/3236457, in_queue=3236481, util=100.00%
```

### 测试nvme同步IO顺序写

```shell
$ fio -filename=/dev/nvme0n1 -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=10G -numjobs=10 -group_reporting -name=write-psync
write-psync: (g=0): rw=write, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [W(10)][99.0%][r=0KiB/s,w=947MiB/s][r=0,w=60.6k IOPS][eta 00m:01s]
write-psync: (groupid=0, jobs=10): err= 0: pid=2519053: Thu Mar 10 14:29:58 2022
  write: IOPS=63.1k, BW=986MiB/s (1034MB/s)(100GiB/103852msec)
    clat (usec): min=15, max=9196, avg=157.13, stdev=258.89
     lat (usec): min=15, max=9197, avg=157.34, stdev=258.89
    clat percentiles (usec):
     |  1.00th=[   20],  5.00th=[   23], 10.00th=[   26], 20.00th=[   36],
     | 30.00th=[   47], 40.00th=[   54], 50.00th=[   65], 60.00th=[   84],
     | 70.00th=[  108], 80.00th=[  194], 90.00th=[  375], 95.00th=[  603],
     | 99.00th=[ 1418], 99.50th=[ 1614], 99.90th=[ 2073], 99.95th=[ 2212],
     | 99.99th=[ 2507]
   bw (  KiB/s): min=82368, max=145216, per=10.01%, avg=101047.33, stdev=5684.79, samples=2064
   iops        : min= 5148, max= 9076, avg=6315.44, stdev=355.30, samples=2064
  lat (usec)   : 20=1.46%, 50=32.09%, 100=34.76%, 250=15.61%, 500=9.62%
  lat (usec)   : 750=2.71%, 1000=1.14%
  lat (msec)   : 2=2.48%, 4=0.13%, 10=0.01%
  cpu          : usr=1.09%, sys=3.35%, ctx=6562452, majf=0, minf=823
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,6553600,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=986MiB/s (1034MB/s), 986MiB/s-986MiB/s (1034MB/s-1034MB/s), io=100GiB (107GB), run=103852-103852msec

Disk stats (read/write):
  nvme0n1: ios=245/6541085, merge=0/0, ticks=157/1000997, in_queue=1001155, util=99.96%
```

### 测试SSD同步IO随机写

```shell
$ fio -filename=/dev/sdd -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=10G -numjobs=10 -group_reporting -name=write-psync
write-psync: (g=0): rw=randwrite, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [w(10)][100.0%][r=0KiB/s,w=356MiB/s][r=0,w=22.8k IOPS][eta 00m:00s]
write-psync: (groupid=0, jobs=10): err= 0: pid=2522025: Thu Mar 10 14:39:03 2022
  write: IOPS=22.7k, BW=355MiB/s (372MB/s)(100GiB/288631msec)
    clat (usec): min=60, max=8399, avg=438.76, stdev=20.16
     lat (usec): min=60, max=8407, avg=439.07, stdev=20.14
    clat percentiles (usec):
     |  1.00th=[  416],  5.00th=[  420], 10.00th=[  424], 20.00th=[  429],
     | 30.00th=[  429], 40.00th=[  433], 50.00th=[  433], 60.00th=[  437],
     | 70.00th=[  441], 80.00th=[  449], 90.00th=[  465], 95.00th=[  478],
     | 99.00th=[  506], 99.50th=[  519], 99.90th=[  545], 99.95th=[  562],
     | 99.99th=[  734]
   bw (  KiB/s): min=34976, max=36608, per=10.00%, avg=36325.79, stdev=87.39, samples=5770
   iops        : min= 2186, max= 2288, avg=2270.34, stdev= 5.48, samples=5770
  lat (usec)   : 100=0.01%, 250=0.01%, 500=98.64%, 750=1.35%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=0.01%, 10=0.01%
  cpu          : usr=0.80%, sys=1.76%, ctx=6553633, majf=0, minf=3271
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,6553600,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=355MiB/s (372MB/s), 355MiB/s-355MiB/s (372MB/s-372MB/s), io=100GiB (107GB), run=288631-288631msec

Disk stats (read/write):
  sdd: ios=44/6548035, merge=0/0, ticks=9/2824794, in_queue=2824804, util=100.00%
```

### 测试nvme同步IO随机写

```shell
$ fio -filename=/dev/nvme0n1 -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=10G -numjobs=10 -group_reporting -name=write-psync
write-psync: (g=0): rw=randwrite, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 6 (f=6): [_(3),w(2),_(1),w(4)][96.4%][r=0KiB/s,w=822MiB/s][r=0,w=52.6k IOPS][eta 00m:04s]
write-psync: (groupid=0, jobs=10): err= 0: pid=2526067: Thu Mar 10 14:44:16 2022
  write: IOPS=60.9k, BW=952MiB/s (998MB/s)(100GiB/107559msec)
    clat (usec): min=15, max=10229, avg=161.93, stdev=272.05
     lat (usec): min=15, max=10229, avg=162.16, stdev=272.04
    clat percentiles (usec):
     |  1.00th=[   20],  5.00th=[   23], 10.00th=[   26], 20.00th=[   35],
     | 30.00th=[   41], 40.00th=[   50], 50.00th=[   60], 60.00th=[   77],
     | 70.00th=[  121], 80.00th=[  210], 90.00th=[  383], 95.00th=[  644],
     | 99.00th=[ 1532], 99.50th=[ 1680], 99.90th=[ 1909], 99.95th=[ 1991],
     | 99.99th=[ 2311]
   bw (  KiB/s): min=78048, max=154432, per=10.03%, avg=97769.93, stdev=6426.45, samples=2130
   iops        : min= 4878, max= 9652, avg=6110.60, stdev=401.66, samples=2130
  lat (usec)   : 20=1.19%, 50=39.37%, 100=26.03%, 250=16.47%, 500=10.09%
  lat (usec)   : 750=2.67%, 1000=1.25%
  lat (msec)   : 2=2.88%, 4=0.05%, 10=0.01%, 20=0.01%
  cpu          : usr=1.32%, sys=3.55%, ctx=6563150, majf=0, minf=3012
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,6553600,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=952MiB/s (998MB/s), 952MiB/s-952MiB/s (998MB/s-998MB/s), io=100GiB (107GB), run=107559-107559msec

Disk stats (read/write):
  nvme0n1: ios=241/6546547, merge=0/0, ticks=147/1029794, in_queue=1029942, util=99.96%
```

### 测试SSD异步IO顺序写

```shell
$ fio -filename=/dev/sdd -direct=1 -iodepth 1 -thread -rw=write -ioengine=libaio -bs=16k -size=10G -numjobs=10 -group_reporting -name=write-libaio
write-libaio: (g=0): rw=write, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [W(10)][100.0%][r=0KiB/s,w=314MiB/s][r=0,w=20.1k IOPS][eta 00m:00s]
write-libaio: (groupid=0, jobs=10): err= 0: pid=2529768: Thu Mar 10 14:56:52 2022
  write: IOPS=15.5k, BW=242MiB/s (254MB/s)(100GiB/423340msec)
    slat (usec): min=3, max=2551, avg= 7.50, stdev= 1.82
    clat (usec): min=5, max=8927, avg=636.82, stdev=227.55
     lat (usec): min=70, max=8936, avg=644.57, stdev=227.59
    clat percentiles (usec):
     |  1.00th=[  420],  5.00th=[  424], 10.00th=[  433], 20.00th=[  461],
     | 30.00th=[  494], 40.00th=[  529], 50.00th=[  578], 60.00th=[  619],
     | 70.00th=[  685], 80.00th=[  766], 90.00th=[  889], 95.00th=[ 1090],
     | 99.00th=[ 1500], 99.50th=[ 1778], 99.90th=[ 1926], 99.95th=[ 1975],
     | 99.99th=[ 2114]
   bw (  KiB/s): min= 9184, max=36096, per=10.00%, avg=24761.53, stdev=6527.12, samples=8460
   iops        : min=  574, max= 2256, avg=1547.57, stdev=407.94, samples=8460
  lat (usec)   : 10=0.01%, 20=0.01%, 100=0.01%, 250=0.01%, 500=31.86%
  lat (usec)   : 750=46.36%, 1000=15.10%
  lat (msec)   : 2=6.63%, 4=0.04%, 10=0.01%
  cpu          : usr=0.71%, sys=2.04%, ctx=6553666, majf=0, minf=1640
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,6553600,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=242MiB/s (254MB/s), 242MiB/s-242MiB/s (254MB/s-254MB/s), io=100GiB (107GB), run=423340-423340msec

Disk stats (read/write):
  sdd: ios=44/6549584, merge=0/0, ticks=7/4157028, in_queue=4157035, util=100.00%
```

### 测试nvme异步IO顺序写

```shell
$ fio -filename=/dev/nvme0n1 -direct=1 -iodepth 1 -thread -rw=write -ioengine=libaio -bs=16k -size=10G -numjobs=10 -group_reporting -name=write-libaio
write-libaio: (g=0): rw=write, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 1 (f=1): [_(7),W(1),_(2)][100.0%][r=0KiB/s,w=993MiB/s][r=0,w=63.6k IOPS][eta 00m:00s]
write-libaio: (groupid=0, jobs=10): err= 0: pid=2545331: Thu Mar 10 15:23:04 2022
  write: IOPS=65.6k, BW=1025MiB/s (1075MB/s)(100GiB/99928msec)
    slat (usec): min=2, max=3568, avg= 7.60, stdev= 2.75
    clat (nsec): min=1064, max=4164.8k, avg=142621.15, stdev=246778.68
     lat (usec): min=17, max=4181, avg=150.48, stdev=246.78
    clat percentiles (usec):
     |  1.00th=[   23],  5.00th=[   24], 10.00th=[   26], 20.00th=[   34],
     | 30.00th=[   40], 40.00th=[   44], 50.00th=[   53], 60.00th=[   76],
     | 70.00th=[   91], 80.00th=[  165], 90.00th=[  338], 95.00th=[  553],
     | 99.00th=[ 1401], 99.50th=[ 1549], 99.90th=[ 2008], 99.95th=[ 2147],
     | 99.99th=[ 2442]
   bw (  KiB/s): min=80672, max=169984, per=10.02%, avg=105117.57, stdev=7407.14, samples=1985
   iops        : min= 5042, max=10624, avg=6569.82, stdev=462.95, samples=1985
  lat (usec)   : 2=0.01%, 4=0.01%, 10=0.01%, 20=0.08%, 50=48.17%
  lat (usec)   : 100=23.86%, 250=13.66%, 500=8.50%, 750=2.27%, 1000=0.98%
  lat (msec)   : 2=2.36%, 4=0.10%, 10=0.01%
  cpu          : usr=2.74%, sys=8.02%, ctx=6553242, majf=0, minf=1418
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,6553600,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=1025MiB/s (1075MB/s), 1025MiB/s-1025MiB/s (1075MB/s-1075MB/s), io=100GiB (107GB), run=99928-99928msec

Disk stats (read/write):
  nvme0n1: ios=275/6552345, merge=0/0, ticks=139/927571, in_queue=927710, util=99.97%
```

### 测试ssd异步IO随机写

```shell
$ fio -filename=/dev/sdd -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=libaio -bs=16k -size=10G -numjobs=10 -group_reporting -name=randwrite-libaio
randwrite-libaio: (g=0): rw=randwrite, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 10 (f=10): [w(10)][100.0%][r=0KiB/s,w=353MiB/s][r=0,w=22.6k IOPS][eta 00m:00s]
randwrite-libaio: (groupid=0, jobs=10): err= 0: pid=2539595: Thu Mar 10 15:14:43 2022
  write: IOPS=22.5k, BW=352MiB/s (369MB/s)(100GiB/291188msec)
    slat (usec): min=3, max=900, avg= 7.57, stdev= 1.52
    clat (nsec): min=1118, max=5448.2k, avg=434643.81, stdev=22855.59
     lat (usec): min=73, max=5475, avg=442.47, stdev=22.79
    clat percentiles (usec):
     |  1.00th=[  412],  5.00th=[  420], 10.00th=[  420], 20.00th=[  424],
     | 30.00th=[  424], 40.00th=[  424], 50.00th=[  429], 60.00th=[  429],
     | 70.00th=[  433], 80.00th=[  445], 90.00th=[  461], 95.00th=[  478],
     | 99.00th=[  510], 99.50th=[  523], 99.90th=[  553], 99.95th=[  570],
     | 99.99th=[  742]
   bw (  KiB/s): min=34272, max=36512, per=10.00%, avg=36006.78, stdev=440.66, samples=5820
   iops        : min= 2142, max= 2282, avg=2250.40, stdev=27.54, samples=5820
  lat (usec)   : 2=0.01%, 10=0.01%, 50=0.01%, 100=0.01%, 250=0.01%
  lat (usec)   : 500=98.44%, 750=1.54%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=0.01%, 10=0.01%
  cpu          : usr=1.14%, sys=2.97%, ctx=6553689, majf=0, minf=3687
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,6553600,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=352MiB/s (369MB/s), 352MiB/s-352MiB/s (369MB/s-369MB/s), io=100GiB (107GB), run=291188-291188msec

Disk stats (read/write):
  sdd: ios=44/6552504, merge=0/0, ticks=9/2833727, in_queue=2833736, util=100.00%
```

### 测试nvme异步IO随机写

```shell
$ fio -filename=/dev/nvme0n1 -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=libaio -bs=16k -size=10G -numjobs=10 -group_reporting -name=randwrite-libaio
randwrite-libaio: (g=0): rw=randwrite, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=1
...
fio-3.7
Starting 10 threads
Jobs: 2 (f=2): [w(1),_(3),w(1),_(5)][100.0%][r=0KiB/s,w=806MiB/s][r=0,w=51.6k IOPS][eta 00m:00s]
randwrite-libaio: (groupid=0, jobs=10): err= 0: pid=2542591: Thu Mar 10 15:17:41 2022
  write: IOPS=61.3k, BW=958MiB/s (1004MB/s)(100GiB/106941msec)
    slat (usec): min=2, max=694, avg= 7.88, stdev= 2.70
    clat (nsec): min=1037, max=4542.5k, avg=152531.51, stdev=267263.01
     lat (usec): min=20, max=4550, avg=160.68, stdev=267.14
    clat percentiles (usec):
     |  1.00th=[   23],  5.00th=[   24], 10.00th=[   25], 20.00th=[   31],
     | 30.00th=[   37], 40.00th=[   42], 50.00th=[   49], 60.00th=[   69],
     | 70.00th=[  104], 80.00th=[  192], 90.00th=[  367], 95.00th=[  635],
     | 99.00th=[ 1500], 99.50th=[ 1647], 99.90th=[ 1876], 99.95th=[ 1975],
     | 99.99th=[ 2311]
   bw (  KiB/s): min=77600, max=127050, per=10.02%, avg=98241.55, stdev=6793.82, samples=2124
   iops        : min= 4850, max= 7940, avg=6140.07, stdev=424.60, samples=2124
  lat (usec)   : 2=0.01%, 4=0.01%, 10=0.01%, 20=0.10%, 50=51.11%
  lat (usec)   : 100=18.12%, 250=14.82%, 500=9.20%, 750=2.50%, 1000=1.24%
  lat (msec)   : 2=2.84%, 4=0.04%, 10=0.01%
  cpu          : usr=2.96%, sys=8.03%, ctx=6551453, majf=0, minf=3756
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=0,6553600,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=958MiB/s (1004MB/s), 958MiB/s-958MiB/s (1004MB/s-1004MB/s), io=100GiB (107GB), run=106941-106941msec

Disk stats (read/write):
  nvme0n1: ios=329/6551301, merge=0/0, ticks=122/989652, in_queue=989775, util=99.97%
```

- [fio 使用总结](https://blog.csdn.net/kjh2007abc/article/details/85001107)