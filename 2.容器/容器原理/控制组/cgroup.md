# cgroups

## 查看cgroup版本

```shell
[root@node1 ~]# grep cgroup /proc/filesystems
nodev   cgroup
nodev   cgroup2
```

如果包含有`cgroup2`的就是安装了的

## 简介

`Cgroups`用来提供对一组进程以及将来子进程的资源限制，包含三个组件：

- 控制组: 一个`cgroups`包含一组进程，并可以在这个`cgroups`上增加`Linux subsystem`的各种参数配置，
    将一组进程和一组`subsystem`关联起来
- `subsystem` 子系统是一组资源控制模块
- 

> 可以通过`lssubsys -a`命令查看当前内核支持哪些`subsystem`

## 利用cgroup限制程序资源

> 安装`cgroup`管理工具

    yum install libcgroup libcgroup-tools -y
    
### 限制cpu

> 创建`cpu`的`cgroup`控制组，控制组名为`demo01`

    cgcreate -g cpu:/demo01
    
> 查看cpu控制组

    [root@localhost ~]# cd /sys/fs/cgroup/cpu/demo01
    [root@localhost demo01]# ls
    cgroup.clone_children  cgroup.procs  cpuacct.usage         cpu.cfs_period_us  cpu.rt_period_us   cpu.shares  notify_on_release
    cgroup.event_control   cpuacct.stat  cpuacct.usage_percpu  cpu.cfs_quota_us   cpu.rt_runtime_us  cpu.stat    tasks

- `cpu.cfs_period_us`: `cpu`分配的周期(微秒），默认为`100000`
- `cpu.cfs_quota_us`: 表示该`control group`限制占用的时间（微秒），默认为`-1`，表示不限制。

> 配置`demo1`控制组`cpu`参数

`cpu.cfs_quota_us`和`cpu.cfs_period_us`是控制`cpu`的两个属性，
可以通过设置它们的比值来设置某个组群的`cpu`使用率。在此，我们将`cpu`的使用率限制到`30%`。

    # 设置cpu分配的周期(微秒），即为默认值
    cgset -r cpu.cfs_period_us=100000 demo01

    # 如果设为30000，表示占用30000/10000=30%的CPU
    cgset -r cpu.cfs_quota_us=30000 demo01
    
> 创建测试程序，测试无限制情况下`cpu`占用率

创建死循环脚本

    cat > ~/demo.sh <<EOF
    # !/bin/bash
    while [ 1 == 1 ];do
        echo "----" > /dev/null
    done
    EOF
    
执行死循环脚本

    [root@localhost ~]# nohup sh ~/demo.sh &> /dev/null &
    [1] 15319
    
查看进程占用系统资源

    top - 23:38:34 up 20 min,  1 user,  load average: 0.76, 0.20, 0.11
    Tasks: 128 total,   2 running, 126 sleeping,   0 stopped,   0 zombie
    %Cpu(s): 19.7 us,  5.3 sy,  0.0 ni, 74.5 id,  0.0 wa,  0.0 hi,  0.6 si,  0.0 st
    KiB Mem :  3861280 total,  3284036 free,   203144 used,   374100 buff/cache
    KiB Swap:  2097148 total,  2097148 free,        0 used.  3425504 avail Mem
    
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
     15319 root      20   0  113288   1184   1012 R  99.7  0.0   0:43.61 sh
         9 root      20   0       0      0      0 S   1.0  0.0   0:01.43 rcu_sched
      1037 root      20   0  157828   6668   5120 S   0.3  0.2   0:01.83 sshd
      
`kill`该进程

    kill -9 15319
    
> 通过指定`cgroup`进行`cpu`配额限制

    [root@localhost ~]# nohup cgexec -g cpu:/demo1 sh ~/demo.sh &> /dev/null &
    [1] 16893
    
查看`cpu`占用情况

    top - 23:58:27 up 40 min,  2 users,  load average: 0.72, 0.28, 0.18
    Tasks: 132 total,   2 running, 130 sleeping,   0 stopped,   0 zombie
    %Cpu(s):  7.1 us,  0.7 sy,  0.0 ni, 92.2 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
    KiB Mem :  3861280 total,  3274444 free,   208332 used,   378504 buff/cache
    KiB Swap:  2097148 total,  2097148 free,        0 used.  3420156 avail Mem
    
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
     22745 root      20   0  113288   1184   1008 R  30.0  0.0   0:01.22 sh /root/demo.sh

