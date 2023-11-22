# CPU负载相关

## 排查所用工具集

- `top`: 系统自带
- `ps`: 系统自带
- `pstack`：`Linux` 命令。可以查看某个进程的当前线程栈运行情况。
- `jstack`：`Java`提供的命令。可以查看某个进程的当前线程栈运行情况。根据这个命令的输出可以定位某个进程的所有线程的当前运行状态、运行代码，以及是否死锁等等。

> 安装工具

通用进程排查工具

    yum install gdb strace -y

排查`java`程序安装以下工具

    yum install -y java-1.8.0-openjdk-devel.x86_64

## CPU高负载排查过程

一个应用占用`CPU`很高，除了确实是计算密集型应用之外，通常原因都是出现了死循环。`CPU`负载过高解决问题过程

> 使用`top`命令定位异常进程（cpu使用率>100%），获取`pid`

    top - 00:32:54 up  1:14,  2 users,  load average: 0.93, 0.79, 0.50
    Tasks: 132 total,   2 running, 130 sleeping,   0 stopped,   0 zombie
    %Cpu(s): 23.8 us,  1.4 sy,  0.0 ni, 74.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
    KiB Mem :  3861280 total,  3273408 free,   209176 used,   378696 buff/cache
    KiB Swap:  2097148 total,  2097148 free,        0 used.  3419296 avail Mem
    
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
     64455 root      20   0  113288   1184   1008 R 100.0  0.0   0:04.44 sh
    
### 非java程序排查步骤

> 追踪该进程

    strace -o output.txt -T -tt -e trace=all -p 64455
    
### java程序排查步骤

> 查找该进程下的所有线程资源占用情况

    [root@localhost ~]# ps -mp 64455 -o THREAD,tid,time
    USER     %CPU PRI SCNT WCHAN  USER SYSTEM    TID     TIME
    root      100   -    - -         -      -      - 00:39:36
    root      100  19    - -         -      -  64455 00:39:36

> 获取异常线程16进制值

    [root@localhost ~]# printf "%x\n" 64455
    fbc7
    
> 查看堆栈，获取线程调用信息

    jstack <进程id> | grep <线程id 16进制> -C5 --color

## 参考文档

- [服务器CPU负载过高，如何定位问题](https://www.jianshu.com/p/45c6bcb85934)