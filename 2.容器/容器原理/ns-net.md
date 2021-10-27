- [网络命名空间](#%E7%BD%91%E7%BB%9C%E5%91%BD%E5%90%8D%E7%A9%BA%E9%97%B4)
  - [概念](#%E6%A6%82%E5%BF%B5)
    - [veth-pair介绍](#veth-pair%E4%BB%8B%E7%BB%8D)
  - [不同网络命名空间之间联通方案](#%E4%B8%8D%E5%90%8C%E7%BD%91%E7%BB%9C%E5%91%BD%E5%90%8D%E7%A9%BA%E9%97%B4%E4%B9%8B%E9%97%B4%E8%81%94%E9%80%9A%E6%96%B9%E6%A1%88)
    - [直连](#%E7%9B%B4%E8%BF%9E)
    - [通过Bridge相连](#%E9%80%9A%E8%BF%87bridge%E7%9B%B8%E8%BF%9E)
    - [通过OVS相连](#%E9%80%9A%E8%BF%87ovs%E7%9B%B8%E8%BF%9E)
  - [docker网络浅析](#docker%E7%BD%91%E7%BB%9C%E6%B5%85%E6%9E%90)
    - [容器网络互通原理](#%E5%AE%B9%E5%99%A8%E7%BD%91%E7%BB%9C%E4%BA%92%E9%80%9A%E5%8E%9F%E7%90%86)
    - [网络隔离原理](#%E7%BD%91%E7%BB%9C%E9%9A%94%E7%A6%BB%E5%8E%9F%E7%90%86)
  - [参考文献](#%E5%8F%82%E8%80%83%E6%96%87%E7%8C%AE)

# 网络命名空间
## 概念

> 网络命名空间有什么能力？

隔离网络设备、协议栈、端口等

`Linux`中，网络命名空间可以被认为是隔离的拥有单独网络栈（网卡、路由转发表、`iptables`）的环境。网络命名空间经常用来隔离网络设备和服务，只有拥有同样网络命名空间的设备，才能看到彼此。

- 从逻辑上说，网络命名空间是网络栈的副本，有自己的网络设备、路由选择表、邻接表、`Netfilter`表、网络套接字、网络`procfs`条目、网络sysfs条目和其他网络资源。

- 从系统的角度来看，当通过`clone()`系统调用创建新进程时，传递标志`CLONE_NEWNET`将在新进程中创建一个全新的网络命名空间。

- 从用户的角度来看，我们只需使用工具`ip`（`package is iproute2`）来创建一个新的持久网络命名空间

### veth-pair介绍

> `veth-pair`是什么?

顾名思义，`veth-pair`就是一对的虚拟设备接口，和`tap/tun`设备不同的是，它都是成对出现的。
一端连着协议栈，一端彼此相连着。如下所示:

```shell
+-------------------------------------------------------------------+
|                                                                   |
|          +------------------------------------------------+       |
|          |             Newwork Protocol Stack             |       |
|          +------------------------------------------------+       |
|                 ↑               ↑               ↑                 |
|.................|...............|...............|.................|
|                 ↓               ↓               ↓                 |
|           +----------+    +-----------+   +-----------+           |
|           |  ens33   |    |   veth0   |   |   veth1   |           |
|           +----------+    +-----------+   +-----------+           |
|192.168.235.128  ↑               ↑               ↑                 |
|                 |               +---------------+                 |
|                 |            10.10.10.2     10.10.10.3            |
+-----------------|-------------------------------------------------+
                  ↓
            Physical Network
```

> `veth`设备的特点

- `veth`和其它的网络设备都一样，一端连接的是内核协议栈
- `veth`设备是成对出现的，另一端两个设备彼此相连
- 一个设备收到协议栈的数据发送请求后，会将数据发送到另一个设备上去

正因为有这个特性，它常常充当着一个桥梁，连接着各种虚拟网络设备，典型的例子如下：
- 两个`net namespace`之间的连接
- `Bridge、OVS`之间的连接
- `Docker`容器之间的连接

## 不同网络命名空间之间联通方案

`OVS`是第三方开源的虚拟交换机，功能比`Linux Bridge`要更强大

- `veth-pair`在虚拟网络中充当着桥梁的角色，连接多种网络设备构成复杂的网络。

- `veth-pair`三个网络联通方案：直接相连、通过`Bridge`相连和通过`OVS`相连

### 直连

直接相连是最简单的方式，如下图，一对`veth-pair`直接将两个`namespace`连接在一起

![](images/linuxswitch-veth.png)

> 创建测试用`net`命名空间

```bash
ip netns a ns0
ip netns a ns1
```

> 添加`veth0`和`veth1`设备，并配置`veth0 IP`地址，分别加入不同`net`命名空间

```bash
# 创建veth-pair对
ip link add veth0 type veth peer name veth1
# 分别加入不同命名空间
ip l s veth0 netns ns0
ip l s veth1 netns ns1
# 配置ip地址，并启用
ip netns exec ns0 ip a a 10.10.10.2/24 dev veth0
ip netns exec ns0 ip l s veth0 up
ip netns exec ns1 ip a a 10.10.10.3/24 dev veth1
ip netns exec ns1 ip l s veth1 up
```

> 互`ping`

```bash
[root@localhost ~]# ip netns exec ns0 ping -c 4 10.10.10.3
PING 10.10.10.3 (10.10.10.3) 56(84) bytes of data.
64 bytes from 10.10.10.3: icmp_seq=1 ttl=64 time=0.045 ms
64 bytes from 10.10.10.3: icmp_seq=2 ttl=64 time=0.090 ms
64 bytes from 10.10.10.3: icmp_seq=3 ttl=64 time=0.045 ms
64 bytes from 10.10.10.3: icmp_seq=4 ttl=64 time=0.106 ms

--- 10.10.10.3 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3030ms
rtt min/avg/max/mdev = 0.045/0.071/0.106/0.028 ms

[root@localhost ~]# ip netns exec ns1 ping -c 4 10.10.10.2
PING 10.10.10.2 (10.10.10.2) 56(84) bytes of data.
64 bytes from 10.10.10.2: icmp_seq=1 ttl=64 time=0.142 ms
64 bytes from 10.10.10.2: icmp_seq=2 ttl=64 time=0.118 ms
64 bytes from 10.10.10.2: icmp_seq=3 ttl=64 time=0.104 ms
64 bytes from 10.10.10.2: icmp_seq=4 ttl=64 time=0.054 ms

--- 10.10.10.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3009ms
rtt min/avg/max/mdev = 0.054/0.104/0.142/0.033 ms
```

> 清除net命名空间

```bash
ip netns del ns0
ip netns del ns1
```

### 通过Bridge相连

当必须连接两个以上的`net`命名空间(或`KVM`或`LXC`实例)时，应使用交换机。
`Linux`提供了著名的`Linux`网桥解决方案。

`Linux Bridge`相当于一台交换机，可以中转多个`namespace`的流量，
如下图，两对`veth-pair`分别将两个`namespace`连到`Bridge`上。

![](images/linuxswitch-linuxbridge-veth1.png)

> 创建`net`命名空间

```bash
# add the namespaces
ip netns add ns1
ip netns add ns2
ip netns add ns3
```

> 创建并启用网桥

```bash
# create the switch
yum install bridge-utils -y
BRIDGE=br-test
brctl addbr $BRIDGE
brctl stp   $BRIDGE off
ip link set dev $BRIDGE up
```

> 创建三对`veth-pair`

```bash
ip l a veth0 type veth peer name br-veth0
ip l a veth1 type veth peer name br-veth1
ip l a veth2 type veth peer name br-veth2
```

> 分别将三对`veth-pair`加入三个`net`命名空间和`br-test`

```bash
ip l s veth0 netns ns1
ip l s br-veth0 master br-test
ip l s br-veth0 up

ip l s veth1 netns ns2
ip l s br-veth1 master br-test
ip l s br-veth1 up

ip l s veth2 netns ns3
ip l s br-veth2 master br-test
ip l s br-veth2 up
```

> 配置三个`ns`中的`veth-pair`的`IP`并启用

```bash
ip netns exec ns1 ip a a 10.10.10.2/24 dev veth0
ip netns exec ns1 ip l s veth0 up

ip netns exec ns2 ip a a 10.10.10.3/24 dev veth1
ip netns exec ns2 ip l s veth1 up

ip netns exec ns3 ip a a 10.10.10.4/24 dev veth2
ip netns exec ns3 ip l s veth2 up
```

> 互`ping`

```bash
[root@localhost ~]# ip netns exec ns1 ping -c 1 10.10.10.3
PING 10.10.10.3 (10.10.10.3) 56(84) bytes of data.
64 bytes from 10.10.10.3: icmp_seq=1 ttl=64 time=0.103 ms

--- 10.10.10.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.103/0.103/0.103/0.000 ms

[root@localhost ~]# ip netns exec ns1 ping -c 1 10.10.10.4
PING 10.10.10.4 (10.10.10.4) 56(84) bytes of data.
64 bytes from 10.10.10.4: icmp_seq=1 ttl=64 time=0.118 ms

--- 10.10.10.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.118/0.118/0.118/0.000 ms

[root@localhost ~]# ip netns exec ns2 ping -c 1 10.10.10.2
PING 10.10.10.2 (10.10.10.2) 56(84) bytes of data.
64 bytes from 10.10.10.2: icmp_seq=1 ttl=64 time=0.044 ms

--- 10.10.10.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.044/0.044/0.044/0.000 ms
[root@localhost ~]# ip netns exec ns2 ping -c 1 10.10.10.4
PING 10.10.10.4 (10.10.10.4) 56(84) bytes of data.
64 bytes from 10.10.10.4: icmp_seq=1 ttl=64 time=0.064 ms

--- 10.10.10.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.064/0.064/0.064/0.000 ms

[root@localhost ~]# ip netns exec ns3 ping -c 1 10.10.10.2
PING 10.10.10.2 (10.10.10.2) 56(84) bytes of data.
64 bytes from 10.10.10.2: icmp_seq=1 ttl=64 time=0.042 ms

--- 10.10.10.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.042/0.042/0.042/0.000 ms
[root@localhost ~]# ip netns exec ns3 ping -c 1 10.10.10.3
PING 10.10.10.3 (10.10.10.3) 56(84) bytes of data.
64 bytes from 10.10.10.3: icmp_seq=1 ttl=64 time=0.096 ms

--- 10.10.10.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.096/0.096/0.096/0.000 ms
```

> 清理测试用例

```bash
ip netns del ns1
ip netns del ns2
ip netns del ns3
ip l s br-test down
brctl delbr br-test
```

### 通过OVS相连

`OVS`是第三方开源的`Bridge`，功能比`Linux Bridge`要更强大

`OVS`有两种方案实现多命名空间网络互通，一种方式为`veth-pair`方式，类似`Linux Bridge`实现

![](images/linuxswitch-ovs-veth.png)

另一种解决方案是使用`openvswitch`，并利用`openvswitch`的内部端口。
这避免了在所有其他解决方案中必须使用的`veth`对的使用

![](images/linuxswitch-ovs.png)

关于第二种方式实现

> 关闭`selinux`

```bash
setenforce 0
sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
```

> 安装`OVS`编译依赖

```bash
yum install -y python-six selinux-policy-devel gcc make \
python-devel openssl-devel kernel-devel graphviz kernel-debug-devel autoconf \
automake rpm-build redhat-rpm-config libtool wget net-tools
```

> 编译安装`OVS`

- [openvswitch-2.5.4.tar.gz](http://openvswitch.org/releases/openvswitch-2.5.4.tar.gz)

```bash
mkdir -p ~/rpmbuild/SOURCES
tar -zxvf openvswitch-2.5.4.tar.gz
cp openvswitch-2.5.4.tar.gz ~/rpmbuild/SOURCES/
ls /lib/modules/$(uname -r) -ln
rpmbuild -bb --without check openvswitch-2.5.4/rhel/openvswitch.spec
cd rpmbuild/RPMS/x86_64/
yum localinstall -y openvswitch-2.5.4-1.x86_64.rpm
systemctl enable openvswitch.service
systemctl start openvswitch.service
```

> 创建`net`命名空间

```bash
ip netns add ns1
ip netns add ns2
ip netns add ns3
```

> 创建`osv`虚拟交换机

```bash
ovs-vsctl add-br ovs-br0
```

> 创建`ovs port`

```bash
#### PORT 1
# create an internal ovs port
ovs-vsctl add-port ovs-br0 tap1 -- set Interface tap1 type=internal
# attach it to namespace
ip link set tap1 netns ns1
# set the ports to up
ip netns exec ns1 ip link set dev tap1 up
#
#### PORT 2
# create an internal ovs port
ovs-vsctl add-port ovs-br0 tap2 -- set Interface tap2 type=internal
# attach it to namespace
ip link set tap2 netns ns2
# set the ports to up
ip netns exec ns2 ip link set dev tap2 up

#### PORT 3
# create an internal ovs port
ovs-vsctl add-port ovs-br0 tap3 -- set Interface tap3 type=internal
# attach it to namespace
ip link set tap3 netns ns3
# set the ports to up
ip netns exec ns3 ip link set dev tap3 up
```

> 配置ip并启用

```bash
ip netns exec ns1 ip a a 10.10.10.2/24 dev tap1
ip netns exec ns1 ip l s tap1 up

ip netns exec ns2 ip a a 10.10.10.3/24 dev tap2
ip netns exec ns2 ip l s tap2 up

ip netns exec ns3 ip a a 10.10.10.4/24 dev tap3
ip netns exec ns3 ip l s tap3 up
```

> 分别将三对`veth-pair`加入三个`net`命名空间和`br-test`

```bash
ip l s veth0 netns ns1
ip l s br-veth0 master br-test
ip l s br-veth0 up

ip l s veth1 netns ns2
ip l s br-veth1 master br-test
ip l s br-veth1 up

ip l s veth2 netns ns3
ip l s br-veth2 master br-test
ip l s br-veth2 up
```

> 互`ping`

```bash
[root@localhost ~]# ip netns exec ns1 ping -c 1 10.10.10.3
PING 10.10.10.3 (10.10.10.3) 56(84) bytes of data.
64 bytes from 10.10.10.3: icmp_seq=1 ttl=64 time=0.103 ms

--- 10.10.10.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.103/0.103/0.103/0.000 ms

[root@localhost ~]# ip netns exec ns1 ping -c 1 10.10.10.4
PING 10.10.10.4 (10.10.10.4) 56(84) bytes of data.
64 bytes from 10.10.10.4: icmp_seq=1 ttl=64 time=0.118 ms

--- 10.10.10.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.118/0.118/0.118/0.000 ms

[root@localhost ~]# ip netns exec ns2 ping -c 1 10.10.10.2
PING 10.10.10.2 (10.10.10.2) 56(84) bytes of data.
64 bytes from 10.10.10.2: icmp_seq=1 ttl=64 time=0.044 ms

--- 10.10.10.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.044/0.044/0.044/0.000 ms
[root@localhost ~]# ip netns exec ns2 ping -c 1 10.10.10.4
PING 10.10.10.4 (10.10.10.4) 56(84) bytes of data.
64 bytes from 10.10.10.4: icmp_seq=1 ttl=64 time=0.064 ms

--- 10.10.10.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.064/0.064/0.064/0.000 ms

[root@localhost ~]# ip netns exec ns3 ping -c 1 10.10.10.2
PING 10.10.10.2 (10.10.10.2) 56(84) bytes of data.
64 bytes from 10.10.10.2: icmp_seq=1 ttl=64 time=0.042 ms

--- 10.10.10.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.042/0.042/0.042/0.000 ms
[root@localhost ~]# ip netns exec ns3 ping -c 1 10.10.10.3
PING 10.10.10.3 (10.10.10.3) 56(84) bytes of data.
64 bytes from 10.10.10.3: icmp_seq=1 ttl=64 time=0.096 ms

--- 10.10.10.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.096/0.096/0.096/0.000 ms
```

> 清除测试用例

```bash
ip netns del ns1
ip netns del ns2
ip netns del ns3
ip l s ovs-br0 down
ovs-vsctl del-br ovs-br0
```
## docker网络浅析
### 容器网络互通原理

> 启动测试容器

```bash
docker run -itd --name test1 busybox
docker run -itd --name test2 busybox
```

> 查看容器`ip`地址

```bash
[root@localhost ~]# docker exec test1 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
4: eth0@if5: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue
    link/ether 02:42:ac:50:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.80.0.2/24 brd 172.80.0.255 scope global eth0
       valid_lft forever preferred_lft forever
[root@localhost ~]# docker exec test1 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
4: eth0@if5: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue
    link/ether 02:42:ac:50:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.80.0.2/24 brd 172.80.0.255 scope global eth0
       valid_lft forever preferred_lft forever
```

> 互`Ping`

```bash
[root@localhost ~]# docker exec test2 ping -c 2 172.80.0.2
PING 172.80.0.2 (172.80.0.2): 56 data bytes
64 bytes from 172.80.0.2: seq=0 ttl=64 time=0.080 ms
64 bytes from 172.80.0.2: seq=1 ttl=64 time=0.086 ms

--- 172.80.0.2 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.080/0.083/0.086 ms
[root@localhost ~]# docker exec test1 ping -c 2 172.80.0.3
PING 172.80.0.3 (172.80.0.3): 56 data bytes
64 bytes from 172.80.0.3: seq=0 ttl=64 time=0.055 ms
64 bytes from 172.80.0.3: seq=1 ttl=64 time=0.153 ms

--- 172.80.0.3 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.055/0.104/0.153 ms
```

此时两个容器互通

> `ping`内网其他主机

```bash
[root@localhost ~]# docker exec test1 ping -c 2 192.168.2.78
PING 192.168.2.78 (192.168.2.78): 56 data bytes
64 bytes from 192.168.2.78: seq=0 ttl=127 time=3.494 ms
64 bytes from 192.168.2.78: seq=1 ttl=127 time=3.007 ms

--- 192.168.2.78 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 3.007/3.250/3.494 ms
[root@localhost ~]# docker exec test2 ping -c 2 192.168.2.78
PING 192.168.2.78 (192.168.2.78): 56 data bytes
64 bytes from 192.168.2.78: seq=0 ttl=127 time=3.301 ms
64 bytes from 192.168.2.78: seq=1 ttl=127 time=3.442 ms

--- 192.168.2.78 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 3.301/3.371/3.442 ms
```

> 连通原理解析

其实原理也是类似于上一节所说。实际上就是新建了一对`veth`，将网络打通了。
- 1、容器里能访问外网原理：是因为有一对`veth`,一端连着容器，一端连着主机的`docker0`，
这样容器就能共用主机的网络了，当容器访问外网时，就会通过`NAT`进行地址转换，实际是通过`iptables`来实现的。
- 2、容器间互通原理：每个容器创建时会生成一对`veth`,一端连着容器，一端连着`docker0`网络，这样两个容器都连着`docker0`，他们就可以互相通信了。
`docker0`相当于上述的`Linux Bridge`

如图所示：

![](images/docker0-br.png)

> 清理测试用例

```bash
docker rm -f test1
docker rm -f test2
```

### 网络隔离原理

> 创建测试网络

```bash
docker network create net-1
docker network create net-2
```

> 启动容器

```bash
docker run -itd --name test1 --network=net-1 busybox
docker run -itd --name test2 --network=net-2 busybox
```

> 查看`IP`

```bash
[root@localhost ~]# docker exec test1 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
10: eth0@if11: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue
    link/ether 02:42:ac:50:01:02 brd ff:ff:ff:ff:ff:ff
    inet 172.80.1.2/24 brd 172.80.1.255 scope global eth0
       valid_lft forever preferred_lft forever
[root@localhost ~]# docker exec test2 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
12: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue
    link/ether 02:42:ac:50:02:02 brd ff:ff:ff:ff:ff:ff
    inet 172.80.2.2/24 brd 172.80.2.255 scope global eth0
       valid_lft forever preferred_lft forever
```

> 互`Ping`

```bash
[root@localhost ~]# docker exec test1 ping -c 2 -i 1 172.80.2.2
^C
[root@localhost ~]# docker exec test1 ping -c 2 -W 1 172.80.2.2
PING 172.80.2.2 (172.80.2.2): 56 data bytes

--- 172.80.2.2 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
[root@localhost ~]# docker exec test2 ping -c 2 -W 1 172.80.1.2
PING 172.80.1.2 (172.80.1.2): 56 data bytes

--- 172.80.1.2 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
```

由于归属不同网桥，网络不通

> `Ping`外部主机

```bash
[root@localhost ~]# docker exec test2 ping -c 2 -W 1 192.168.2.78
PING 192.168.2.78 (192.168.2.78): 56 data bytes
64 bytes from 192.168.2.78: seq=0 ttl=127 time=3.282 ms
64 bytes from 192.168.2.78: seq=1 ttl=127 time=2.960 ms

--- 192.168.2.78 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 2.960/3.121/3.282 ms
[root@localhost ~]# docker exec test1 ping -c 2 -W 1 192.168.2.78
PING 192.168.2.78 (192.168.2.78): 56 data bytes
64 bytes from 192.168.2.78: seq=0 ttl=127 time=3.984 ms
64 bytes from 192.168.2.78: seq=1 ttl=127 time=3.429 ms

--- 192.168.2.78 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 3.429/3.706/3.984 ms
```

由此可见，通过不同网桥实现了网络隔离

> 清理测试用例

```bash
docker rm -f test1
docker rm -f test2
```

关于`docker`网络具体实现，这里不做过多讨论。

## 参考文献

- [Linux Switching – Interconnecting Namespaces](http://www.opencloudblog.com/?p=66)
- [Linux网络命名空间](https://www.jianshu.com/p/369e50201bce)
- [linux中的网络命名空间的使用](https://blog.csdn.net/guotianqing/article/details/82356096)
- [LINUX 内核网络设备——VETH 设备和 NETWORK NAMESPACE 初步](http://blog.nsfocus.net/linux-veth-network-namespace/)
- [Linux 虚拟网络设备 veth-pair 详解，看这一篇就够了](https://www.cnblogs.com/bakari/p/10613710.html)
- [为什么docker容器之间能互通？为什么容器里能访问外网？](https://blog.csdn.net/wangmiaoyan/article/details/104656127)
- [模拟 Docker网桥连接外网](https://blog.csdn.net/newbei5862/article/details/105004047)