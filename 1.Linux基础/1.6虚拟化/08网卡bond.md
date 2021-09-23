### 配置网卡Bond模式

> 网卡1配置

```shell
tee /etc/sysconfig/network-scripts/ifcfg-eno1 <<EOF
BOOTPROTO=none
DEVICE=eno1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
USERCTL=no
NMCONTROLLED=no
EOF
```

> 网卡2配置

```shell
tee /etc/sysconfig/network-scripts/ifcfg-ens4f0 <<EOF
BOOTPROTO=none
DEVICE=ens4f0
ONBOOT=yes
MASTER=bond0
SLAVE=yes
USERCTL=no
NMCONTROLLED=no
EOF
```

> bond0配置

```shell
tee /etc/sysconfig/network-scripts/ifcfg-bond0 <<EOF
DEVICE=bond0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.1.2
PREFIX=24
GATEWAY=192.168.1.254
BONDING_OPTS="mode=1 miimon=100"
EOF
```

> 重启网络

```shell
systemctl restart network
```