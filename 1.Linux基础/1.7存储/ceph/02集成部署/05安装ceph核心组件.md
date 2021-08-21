### 安装ceph组件

`ceph`版本为`14.2.16 nautilus`

> 1.创建`ceph`目录(deploy节点执行)

```shell
mkdir -p /etc/ceph
```

> 2.配置主机互信(deploy节点执行)

```shell
ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa
ssh-copy-id ceph01
ssh-copy-id ceph02
ssh-copy-id ceph03
```

> 3.安装`ceph`(所有节点执行)

```shell
yum install -y ceph ceph-deploy
```

> 4.初始化`mon`节点(deploy节点执行)

```shell
ceph-deploy new ceph01 ceph02 ceph03
```

> 5.初始化`mon`(deploy节点执行)

```shell
ceph-deploy mon create-initial
```

> 6.修改集群文件(deploy节点执行)

```shell
cd /etc/ceph/
echo "public_network=192.168.1.0/24" >> /etc/ceph/ceph.conf
ceph-deploy --overwrite-conf config push ceph01 ceph02 ceph03
```

> 7.配置admin节点

```shell
cd /etc/ceph/
ceph-deploy admin ceph01 ceph02 ceph03
```

> 8.查看集群状态

```shell
[root@ceph01 ~]# ceph -s
  cluster:
    id:     b1c2511e-a1a5-4d6d-a4be-0e7f0d6d4294
    health: HEALTH_WARN
            mon ceph03 is low on available space

  services:
    mon: 3 daemons, quorum ceph01,ceph02,ceph03 (age 31m)
    mgr: no daemons active
    OSD: 0 OSDs: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
```

> 9.安装命令补全

```shell
yum -y install bash-completion
```
