# 容器基础

## 容器与虚拟化

> 传统虚拟化-虚拟机

![](images/vm-virtaul.png)

实质：一套物理资源、多套`Guest`操作系统、系统级隔离

> 容器虚拟化

![](images/container-virtaul.png)

实质：一套物理资源、一套内核、进程级隔离

> 两者对比

![](images/vm-vs-container.png)

> 容器的本质

一个视图被隔离、资源受限的进程，容器里`PID=1`的进程就是应用本身

### 初识hypervisor

TODO

## 容器核心技术

基于`5.4.108-1.el7.elrepo.x86_64`内核

### 命名空间概念

> 什么是命名空间？

`namespace`是`Linux`内核用来隔离内核资源的实现方式

> 命名空间实质

进程视图隔离

> 常用命名空间（进程视图隔离内容）

- [USER命名空间](ns-user.md)
- [UTS命名空间](ns-uts.md)
- [IPC命名空间](ns-ipc.md)

通过这七个选项我们能在创建新的进程时设置新进程应该在哪些资源上与宿主机器进行隔离。
因此容器只能感知内部的进程，而对宿主机和其他容器一无所知。

### 命名空间管理

> 查看当前命名空间

    [root@localhost user]# lsns
            NS TYPE  NPROCS    PID USER   COMMAND
    4026531836 pid      258      1 root   /usr/lib/systemd/systemd --switched-root --system --deserialize 22
    4026531837 user     289      1 root   /usr/lib/systemd/systemd --switched-root --system --deserialize 22
    4026531838 uts      276      1 root   /usr/lib/systemd/systemd --switched-root --system --deserialize 22
    4026531839 ipc      258      1 root   /usr/lib/systemd/systemd --switched-root --system --deserialize 22
    4026531840 mnt      248      1 root   /usr/lib/systemd/systemd --switched-root --system --deserialize 22
    4026531856 mnt        1     28 root   kdevtmpfs
    4026531956 net      282      1 root   /usr/lib/systemd/systemd --switched-root --system --deserialize 22
    4026532512 net        1    747 rtkit  /usr/libexec/rtkit-daemon
    4026532583 mnt        1    747 rtkit  /usr/libexec/rtkit-daemon
    4026532584 mnt        2    773 root   /usr/sbin/NetworkManager --no-daemon
    4026532585 mnt        1    778 root   /usr/libexec/bluetooth/bluetoothd
    4026532586 mnt        1    788 chrony /usr/sbin/chronyd
    4026532587 mnt        1  17813 root   /usr/local/bin/etcd
    4026532588 uts        1  17813 root   /usr/local/bin/etcd
    4026532589 ipc        1  17813 root   /usr/local/bin/etcd
    4026532590 pid        1  17813 root   /usr/local/bin/etcd
    ...
    
> 命名空间限制

- `/proc/sys/user/max_user_namespaces`: 15511
- `/proc/sys/user/max_uts_namespaces`: 15511
- `/proc/sys/user/max_pid_namespaces`: 15511
- `/proc/sys/user/max_net_namespaces`: 15511 
- `/proc/sys/user/max_mnt_namespaces`: 15511
- `/proc/sys/user/max_ipc_namespaces`: 15511
- `/proc/sys/user/max_inotify_watches`: 8192  
- `/proc/sys/user/max_inotify_instances`: 524288
- `/proc/sys/user/max_cgroup_namespaces`: 15511

## 参考文献

