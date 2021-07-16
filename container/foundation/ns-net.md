# 网络命名空间
## 概念

> 网络命名空间有什么能力？

隔离网络设备、协议栈、端口等

`Linux`中，网络命名空间可以被认为是隔离的拥有单独网络栈（网卡、路由转发表、`iptables`）的环境。网络命名空间经常用来隔离网络设备和服务，只有拥有同样网络命名空间的设备，才能看到彼此。

- 从逻辑上说，网络命名空间是网络栈的副本，有自己的网络设备、路由选择表、邻接表、`Netfilter`表、网络套接字、网络`procfs`条目、网络sysfs条目和其他网络资源。

- 从系统的角度来看，当通过`clone()`系统调用创建新进程时，传递标志`CLONE_NEWNET`将在新进程中创建一个全新的网络命名空间。

- 从用户的角度来看，我们只需使用工具`ip`（`package is iproute2`）来创建一个新的持久网络命名空间

## 演示

### 创建网络命名空间

> 创建网络命名空间`netns-A`

```shell
ip netns add netns-A
```

> 查看网络命名空间列表

```shell
[root@localhost ~]# ip netns list
netns-A
```

### 添加虚拟网卡

> 列出网卡

```shell
[root@localhost ~]# ip link list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 00:0c:29:e0:67:e1 brd ff:ff:ff:ff:ff:ff
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:b2:75:38:cc brd ff:ff:ff:ff:ff:ff
6: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 16:ac:db:22:b8:31 brd ff:ff:ff:ff:ff:ff
7: kube-ipvs0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
    link/ether 2a:02:24:5b:ce:7d brd ff:ff:ff:ff:ff:ff
8: nodelocaldns: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
    link/ether 42:f9:5c:4f:55:39 brd ff:ff:ff:ff:ff:ff
9: tunl0@NONE: <NOARP,UP,LOWER_UP> mtu 1440 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
12: calia27565657ce@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1440 qdisc noqueue state UP mode DEFAULT group default
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff link-netnsid 0
13: calie25456b0dfb@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1440 qdisc noqueue state UP mode DEFAULT group default
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff link-netnsid 1
14: caliee117e69d4e@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1440 qdisc noqueue state UP mode DEFAULT group default
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff link-netnsid 2
```

> 创建新的虚拟网卡

- 同时创建`veth0`和`veth1`两个虚拟网卡
- 此时这两个网卡还都属于`default`或`global`命名空间，和物理网卡一样

```shell
ip link add veth0 type veth peer name veth1
```

> 关于`veth`虚拟网卡介绍

`veth`都是成对出现的，就像一个管道的两端，从这个管道的一端的`veth`进去的数据会从另一端的`veth`再出来。
也就是说，可以使用`veth`接口把一个网络命名空间连接到外部`default`命名空间或者`global`命名空间，
而物理网卡就存在这些命名空间里

- 在不同的`namespace`之间进行通信可以使用`veth`设备对来进行数据的转发

> 把虚拟网卡`veth1`转移到命名空间`netns-A`中
```shell
ip link set veth1 netns netns-A
```

> 查看`netns-A`下网卡信息

```shell
[root@localhost ~]# ip netns exec netns-A ip link list
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
15: veth1@if16: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ae:a8:42:5c:a7:f7 brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

> 配置`netns-A`中的虚拟网卡`veth1`

```shell
# 配置ip地址
ip netns exec netns-A ip addr add 10.0.0.2/24 dev veth1
# 开启
ip netns exec netns-A ip link set veth1 up
ip netns exec netns-A ip link set lo up
```

> 查看`netns-A`中的虚拟网卡`veth1`状态

```shell
[root@localhost ~]# ip netns exec netns-A ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
15: veth1@if16: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state LOWERLAYERDOWN group default qlen 1000
    link/ether ae:a8:42:5c:a7:f7 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.0.2/24 scope global veth1
       valid_lft forever preferred_lft forever
```

> 配置`netns-A`中的虚拟网卡`veth1`路由

```shell
ip netns exec netns-A ip route add default via 10.0.0.2
ip netns exec netns-A ip route show
```

> 配置虚拟网卡`veth0`

```shell
ip addr add 10.0.0.1/24 dev veth0
ip link set veth0 up
```

### 配置转发与伪装

> 配置转发

- `net.ipv4.ip_forward = 1`解释如下：

`Linux`系统的`IP`转发的意思是: 当`Linux`主机存在多个网卡的时候，允许一个网卡的数据包转发到另外一张网卡
在`linux`系统中默认禁止`IP`转发功能。

```shell
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p
```

> 配置nat转换

```shell
# 
iptables -t nat -A POSTROUTING -s 10.0.0.0/255.255.255.0 -o ens33 -j MASQUERADE

#允许veth0和ens33之间的转发
iptables -A FORWARD -i ens33 -o veth0 -j ACCEPT
iptables -A FORWARD -o ens33 -i veth0 -j ACCEPT
```

## 参考文献

- [Linux网络命名空间](https://www.jianshu.com/p/369e50201bce)
- [linux中的网络命名空间的使用](https://blog.csdn.net/guotianqing/article/details/82356096)
- [LINUX 内核网络设备——VETH 设备和 NETWORK NAMESPACE 初步](http://blog.nsfocus.net/linux-veth-network-namespace/)
- [Linux 虚拟网络设备 veth-pair 详解，看这一篇就够了](https://www.cnblogs.com/bakari/p/10613710.html)
- [为什么docker容器之间能互通？为什么容器里能访问外网？](https://blog.csdn.net/wangmiaoyan/article/details/104656127)