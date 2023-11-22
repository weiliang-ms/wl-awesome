## MTU对网络影响排查

**MTU位于数据链路层**

大部分网络设备MTU都是1500。如果本机的MTU比网关的MTU大，大的数据包就会被拆开来传送，这样会产生很多数据包碎片，增加丢包率，降低网络速度。
把本机的MTU设成比网关的MTU小或相同，就可以减少丢包

案例，A点和B点之间网络状况良好（延时小，丢包率低），但是当A点和B点之间配置了×××通道以后，丢包率一下变的很高。
在排除了两边硬件防火墙有问题之后，确定可能为`MTU`的原因。

`MTU`代表最大传输单元，一般以太网上默认为`1500`字节。再配置了`×××`之后，`AB`两点要频繁进行封装，加密，解封，解密的操作，
这时如果在A点和B点之间的某个路由器的MTU值小于1500，这样就需要对包进行重新分片再传输，
如果再加上网络拥塞的话，网络性能势必受到影响。

判断是否存在这样的问题，其实很简单，用ping命令即可:

```shell
ping 192.168.100.2 -f -l 1500
```

> -f表示不重新分片，-l表示传输包的大小

如果存在上面提到的问题，那么就会返回这样的提示`Packets needs to be fragmented but DF set`. 
逐渐减小-l后面的值，直到有`reply`为止。


centos7查看本机mtu：

```shell
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:96:f1:99 brd ff:ff:ff:ff:ff:ff
    inet 192.168.109.163/24 brd 192.168.109.255 scope global noprefixroute dynamic ens33
       valid_lft 1757sec preferred_lft 1757sec
    inet6 fe80::2af5:fa72:cbfd:4a21/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

centos7修改本机mtu：

```shell
$ echo "MTU=1450" >> /etc/sysconfig/network-scripts/ifcfg-ens33
$ systemctl restart network
```