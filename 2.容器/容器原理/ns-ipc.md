## ipc命名空间

### 概述

> 主要能力

提供进程间通信的隔离能力

### ipc命名空间隔离性验证

> 获取当前进程`ID`

```bash
[root@localhost ~]# echo $$
49265
```

在这里为了方面解释，我们定义进程`ID`为`49265`的进程名称为`PID-A`

> 查看当前进程命名空间信息

```bash
[root@localhost ~]# ls -l /proc/$$/ns
total 0
lrwxrwxrwx 1 root root 0 Jul 14 07:27 cgroup -> cgroup:[4026531835]
lrwxrwxrwx 1 root root 0 Jul 14 07:27 ipc -> ipc:[4026531839]
lrwxrwxrwx 1 root root 0 Jul 14 07:27 mnt -> mnt:[4026531840]
lrwxrwxrwx 1 root root 0 Jul 14 07:27 net -> net:[4026531992]
lrwxrwxrwx 1 root root 0 Jul 14 07:27 pid -> pid:[4026531836]
lrwxrwxrwx 1 root root 0 Jul 14 07:27 pid_for_children -> pid:[4026531836]
lrwxrwxrwx 1 root root 0 Jul 14 07:27 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Jul 14 07:27 uts -> uts:[4026531838]
```

> 查看`PID-A`进程`ipc`信息

```bash
[root@localhost ~]# ipcs

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00000000 2          gdm        777        16384      1          dest
0x00000000 5          gdm        777        7372800    2          dest

------ Semaphore Arrays --------
key        semid      owner      perms      nsems
```

> 使用`unshare`隔离`ipc namespace`

```bash
unshare --ipc /bin/bash
```

查看进程`ID`，发现已变更

```bash
[root@localhost ~]# echo $$
62293
```

在这里为了方面解释，我们定义进程`ID`为`62293`的进程名称为`PID-B`

查看两个进程关系，显然`PID-A`与`PID-B`为父子关系的两个进程

```bash
[root@localhost ~]# ps -ef|grep 62293
root      62293  49265  0 07:33 pts/0    00:00:00 /bin/bash
root      62430  62293  0 07:33 pts/0    00:00:00 ps -ef
root      62431  62293  0 07:33 pts/0    00:00:00 grep --color=auto 62293
```

> 查看`PID-B`进程的`ipc`信息

```bash
[root@localhost ~]# ipcs

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status

------ Semaphore Arrays --------
key        semid      owner      perms      nsems
```

显然与`PID-A`进程不一致

> 测试: `PID-B`创建一个消息队列，是否`PID-A`中可以看到

```bash
[root@localhost ~]# ipcmk --queue
Message queue id: 0
[root@localhost ~]# ipcs

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages
0x6c54b6c4 0          root       644        0            0

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status

------ Semaphore Arrays --------
key        semid      owner      perms      nsems
```

新开一个`ssh`链接（会产生新的进程），查看是否可以看到`PID-B`中消息队列

```bash
[root@localhost ~]# echo $$
49857
[root@localhost ~]# ipcs  -q

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages
```

显然无法查看，隔离验证成功！

> 查看`PID-B`进程命名空间信息

```bash
[root@localhost ~]# ls -l /proc/62293/ns
total 0
lrwxrwxrwx 1 root root 0 Jul 14 07:47 cgroup -> cgroup:[4026531835]
lrwxrwxrwx 1 root root 0 Jul 14 07:47 ipc -> ipc:[4026532765]
lrwxrwxrwx 1 root root 0 Jul 14 07:47 mnt -> mnt:[4026531840]
lrwxrwxrwx 1 root root 0 Jul 14 07:47 net -> net:[4026531992]
lrwxrwxrwx 1 root root 0 Jul 14 07:47 pid -> pid:[4026531836]
lrwxrwxrwx 1 root root 0 Jul 14 07:47 pid_for_children -> pid:[4026531836]
lrwxrwxrwx 1 root root 0 Jul 14 07:47 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Jul 14 07:47 uts -> uts:[4026531838]
```

对比`PID-A`，发现二者区别仅为`ipc`不同

### IPC实现方式

> `Linux`进程通信方式

- 信号量
- 共享内存
- 消息队列
- 管道
- 信号
- 套接字通信

其中`信号量`，`共享内存`，`消息队列`基于内核的`IPC命名空间`实现

```bash
[root@localhost ~]# ipcs

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages
0x84300480 0          root       644        0            0
0xba58165a 1          root       644        0            0
0xb5be9e2a 2          root       644        0            0

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00000000 2          gdm        777        16384      1          dest
0x00000000 5          gdm        777        7372800    2          dest

------ Semaphore Arrays --------
key        semid      owner      perms      nsems
```

## 参考文档

- [Docker基础: Linux内核命名空间之（2） ipc namespace](https://liumiaocn.blog.csdn.net/article/details/52549356)