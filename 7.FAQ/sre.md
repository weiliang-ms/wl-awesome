> 1.linux启动顺序

启动第一步－－加载 BIOS

    当你打开计算机电源，计算机会首先加载 BIOS 信息，BIOS 信息是如此的重要，以至于计
    算机必须在最开始就找到它。这是因为 BIOS 中包含了 CPU 的相关信息、设备启动顺序信
    息、硬盘信息、内存信息、时钟信息、PnP 特性等等。在此之后，计算机心里就有谱了，
    知道应该去读取哪个硬件设备了。
    
启动第二步－－读取 MBR

    众所周知，硬盘上第 0 磁道第一个扇区被称为 MBR，也就是 Master Boot Record，即主
    引导记录，它的大小是 512 字节，别看地方不大，可里面却存放了预启动信息、分区表信
    息。
    系统找到 BIOS 所指定的硬盘的 MBR 后，就会将其复制到 0x7c00 地址所在的物理内存中。
    其实被复制到物理内存的内容就是 Boot Loader，而具体到你的电脑，那就是 lilo 或者 grub
    了。
    
启动第三步－－Boot Loader

    Boot Loader 就是在操作系统内核运行之前运行的一段小程序。通过这段小程序，我们可
    以初始化硬件设备、建立内存空间的映射图，从而将系统的软硬件环境带到一个合适的状态，
    以便为最终调用操作系统内核做好一切准备。
    Boot Loader 有若干种，其中 Grub、Lilo 和 spfdisk 是常见的 Loader。
    我们以 Grub 为例来讲解吧，毕竟用 lilo 和 spfdisk 的人并不多。
    
    系统读取内存中的 grub 配置信息（一般为 menu.lst 或 grub.lst），并依照此配置信息来
    启动不同的操作系统。
    
启动第四步－－加载内核

    根据 grub 设定的内核映像所在路径，系统读取内核映像，并进行解压缩操作。此时，屏幕
    一般会输出“Uncompressing Linux”的提示。当解压缩内核完成后，屏幕输出“OK,
    booting the kernel”。
    系统将解压后的内核放置在内存之中，并调用 start_kernel()函数来启动一系列的初始化函
    数并初始化各种设备，完成 Linux 核心环境的建立。至此，Linux 内核已经建立起来了，基
    于 Linux 的程序应该可以正常运行了。
    
启动第五步－－用户层 init 依据 inittab 文件来设定运行等级

    内核被加载后，第一个运行的程序便是/sbin/init，该文件会读取/etc/inittab 文件，并依据
    此文件来进行初始化工作。
    其实/etc/inittab 文件最主要的作用就是设定 Linux 的运行等级，其设定形式是“：
    id:5:initdefault:”，这就表明 Linux 需要运行在等级 5 上。Linux 的运行等级设定如下：
    0：关机
    1：单用户模式
    2：无网络支持的多用户模式
    3：有网络支持的多用户模式
    
    4：保留，未使用
    5：有网络支持有 X-Window 支持的多用户模式
    6：重新引导系统，即重启
    
启动第六步－－init 进程执行 rc.sysinit

    在设定了运行等级后，Linux 系统执行的第一个用户层文件就是/etc/rc.d/rc.sysinit 脚本程
    序，它做的工作非常多，包括设定 PATH、设定网络配置（/etc/sysconfig/network）、启
    动 swap 分区、设定/proc 等等。如果你有兴趣，可以到/etc/rc.d 中查看一下 rc.sysinit 文
    件。
    
启动第七步－－启动内核模块

    具体是依据/etc/modules.conf 文件或/etc/modules.d 目录下的文件来装载内核模块。
    
启动第八步－－执行不同运行级别的脚本程序

    根据运行级别的不同，系统会运行 rc0.d 到 rc6.d 中的相应的脚本程序，来完成相应的初始
    化工作和启动相应的服务。
    
启动第九步－－执行/etc/rc.d/rc.local

    你如果打开了此文件，里面有一句话，读过之后，你就会对此命令的作用一目了然
    rc.local 就是在一切初始化工作后，Linux 留给用户进行个性化的地方。你可以把你想设置
    和启动的东西放到这里。
    
启动第十步－－执行/bin/login 程序，进入登录状态

> Linux 常见的系统日志文件

- `/var/log/messages`: 内核及公共消息日志
- `/var/log/cron`: 计划任务日志
- `/var/log/dmesg`: 系统引导日志
- `/var/log/maillog`: 邮件系统日志
- `/var/log/secure`: 记录与访问限制相关日志
    
> 3.讲一下 Keepalived 的工作原理

    在一个虚拟路由器中，只有作为 MASTER 的 VRRP 路由器会一直发送 VRRP 通告信息，
    BACKUP 不会抢占 MASTER，除非它的优先级更高。
    当 MASTER 不可用时(BACKUP收不到通告信息)多台 BACKUP 中优先级最高的这台会被抢占为
     MASTER。这种抢占是非常快速的(<1s)，以保证服务的连续性由于安全性考虑，
     VRRP 包使用了加密协议进行加密。BACKUP 不会发送通告信息，只会接收通告信息。
     
> 4.OSI协议

    物理层：EIA/TIA-232, EIA/TIA-499, V.35, V.24, RJ45, Ethernet, 802.3, 802.5, FDDI, NRZI, NRZ, B8ZS
    数据链路层：Frame Relay, HDLC, PPP, IEEE 802.3/802.2, FDDI, ATM, IEEE 802.5/802.2
    网络层：IP，IPX，AppleTalk DDP
    传输层：TCP，UDP，SPX
    会话层：RPC,SQL,NFS,NetBIOS,names,AppleTalk,ASP,DECnet,SCP
    表示层:TIFF,GIF,JPEG,PICT,ASCII,EBCDIC,encryption,MPEG,MIDI,HTML
    应用层：FTP,WWW,Telnet,NFS,SMTP,Gateway,SNMP
    
> 5.文件系统只读及恢复

    
> 6.raid

- 主要性能排序


    冗余从好到坏：raid 1  raid 10  raid 5  raid 0
    性能从好到坏：raid 0  raid 10  raid 5  raid 1
    成本从低到高：raid 0  raid 5   raid 1  raid 10


    