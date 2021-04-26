# 容器安全

基于`Docker 19.03.8`

## 主机安全配置

### 为docker挂载单独存储目录

- 描述


默认安装情况下，所有`Docker`容器及数据、元数据存储于`/var/lib/docker`下

- 审计方式


`Docker`依赖于`/var/lib/docker`作为默认数据目录，该目录存储所有相关文件，包括镜像文件。
该目录可能会被恶意的写满，导致`Docker`、甚至主机可能无法使用。因此，建议为`Docker`存储目录配置独立挂载点（最好为独立数据盘）

- 修复建议

> `docker`宿主机增加数据盘`/dev/sdb`

```shell script
[root@localhost ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0   30G  0 disk
sr0              11:0    1  4.4G  0 rom
```

> 格式化数据盘

```shell script
[root@localhost ~]# mkfs.ext4 /dev/sdb
mke2fs 1.42.9 (28-Dec-2013)
/dev/sdb is entire device, not just one partition!
Proceed anyway? (y,n) y
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
1966080 inodes, 7864320 blocks
393216 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2155872256
240 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done
```

> 配置`/dev/sdb`挂载点为`/var/lib/docker`

**该步骤建议安装`docker`之后进行**

```shell script
echo "/dev/sdb /var/lib/docker ext4 defaults 0 0" >> /etc/fstab
```

> 重启主机测试是否生效

```shell script
[root@localhost ~]# reboot
[root@localhost ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   19G  0 part
  ├─centos-root 253:0    0   17G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0   30G  0 disk /var/lib/docker
sr0              11:0    1  4.4G  0 rom
[root@localhost ~]# docker images
REPOSITORY                         TAG       IMAGE ID       CREATED        SIZE
harbor.wl.com/public/alpine   latest    d6e46aa2470d   6 months ago   5.57MB
```

### 容器宿主机加固

- 分析

容器在`Linux`主机上运行，容器宿主机可以运行一个或多个容器。
加强主机以缓解主机安全配置错误是非常重要的

- 审计方式

确保遵守主机的安全规范。询问系统管理员当前主机系统符合哪个安全标准。确保主机系统实际符合主机制定的安全规范

- 修复建议

参考`Linux`主机安全加固规范。

### 更新Docker到最新版本

- 描述

`Docker`软件频繁发布更新，旧版本可能存在安全漏洞

- 审计

查看[release](https://github.com/moby/moby/releases) 与本地版本比较

```shell script
docker version
```

- 风险评估

不要盲目升级`docker`版本，评估升级是否会对现有系统产生影响，充分测试其兼容性（如与`k8s kubeadm`兼容性）

- 修复建议

```shell script
#安装一些必要的系统工具
yum -y install yum-utils device-mapper-persistent-data lvm2

#添加软件源信息
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#更新 yum 缓存
yum makecache fast

#安装docker-ce
yum -y install docker-ce
# 或更新
yum -y update docker-ce
```

### 只有受信任的用户才能控制Docker守护进程

- 描述

`Docker`守护进程需要`root`权限。对于添加到`Docker`组的用户，
为其提供了完整的`root`访问权限。

- 隐患分析

`Docker`允许在宿主机和访客容器之间共享目录，而不会限制容器的访问权限。
这意味着可以启动容器并将主机上的`/`目录映射到容器。
容器将能够不受任何限制地更改您的主机文件系统。 简而言之，这意味着您只需作为`Docker`组的成员即可获得较高的权限，然后在主机上启动具有映射`/`目录的容器。

- 审计方式

```shell script
[root@localhost ~]# yum install glibc-common -y -q
[root@localhost ~]# getent group docker
docker:x:994:
```

- 结果判定

查看`审计`步骤中的返回值是否含有非信任用户

- 修复建议

从`docker`组中删除任何不受信任的用户。另外，请勿在主机上创建敏感目录到容器卷的映射

## docker守护进程配置

### 不适用不安全的镜像仓库

- 描述

`Docker`在默认情况下，私有仓库被认为是安全的

- 隐患分析

一个安全的镜像仓库建议使用`TLS`。 在`/etc/docker/certs.d/<registry-name>/`目录下，将镜像仓库的`CA`证书副本放置在`Docker`主机上。
不安全的镜像仓库是没有有效的镜像仓库证书或不使用`TLS`的镜像仓库。不应该在生产环境中使用任何不安全的镜像仓库。
不安全的镜像仓库中的镜像可能会被篡改，从而导致生产系统可能受到损害。
此外，如果镜像仓库被标记为不安全，则`docker pull`，`docker push`和`docker push`命令并不能发现，
那样用户可能无限期地使用不安全的镜像仓库而不会发现。

- 审计方式

```shell script
[root@localhost ~]# cat /etc/docker/daemon.json |grep insecure-registries
     "insecure-registries":["gcr.azk8s.cn","dockerhub.azk8s.cn","quay.azk8s.cn","5twf62k1.mirror.aliyuncs.com","registry.docker-cn.com","registry-1.docker.io"],
```

- 修复建议

使用`ssl`签名的镜像仓库（如配置`ssl`证书的`harbor`）

### 不使用aufs存储驱动程序

- 描述

`aufs`存储驱动程序是较旧的存储驱动程序。 它基于`Linux`内核补丁集，不太可能合并到主版本`Linux`内核中。 
`aufs`驱动会导致一些严重的内核崩溃。`aufs`在`Docker`中只是保留了历史遗留支持,现在主要使用`overlay2`和`devicemapper`。
而且最重要的是，在许多使用最新`Linux`内核的发行版中，`aufs`不再被支持

- 审计方式

```shell script
[root@node105 ~]# docker info |grep  "Storage Driver:"
 Storage Driver: overlay2
```

- 修复建议

默认安装情况下存储驱动为`overlay2`，避免使用`aufs`作为存储驱动

### Docker守护进程配置TLS身份认证

- 描述

可以让`Docker`守护进程监听特定的`IP`和端口以及除默认`Unix`套接字以外的任何其他`Unix`套接字。
配置`TLS`身份验证以限制通过`IP`和端口访问`Docker`守护进程。

- 隐患分析

默认情况下，`Docker`守护程序绑定到非联网的`Unix`套接字，并以`root`权限运行。
如果将默认的`Docker`守护程序更改为绑定到`TCP`端口或任何其他`Unix`套接字，那么任何有权访问该端口或套接字的人都可以完全访问`Docker`守护程序，进而可以访问主机系统。
因此，不应该将`Docker`守护程序绑定到另一个`IP`/端口或`Unix`套接字。
如果必须通过网络套接字暴露`Docker`守护程序，请为守护程序配置`TLS`身份验证

- 审计方法

```shell script
[root@localhost ~]# systemctl status docker|grep /usr/bin/dockerd
           ├─1061 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
```

- 修复建议

生产环境下避免开启`tcp`监听，若避免不了，执行以下操作。

> 生成`CA`私钥和公共密钥

```shell script
mkdir -p /root/docker
cd /root/docker
openssl genrsa -aes256 -out ca-key.pem 4096
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
```

> 创建一个服务端密钥和证书签名请求(`CSR`)

`192.168.235.128`为当前主机`IP`地址

```shell script
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=192.168.235.128" -sha256 -new -key server-key.pem -out server.csr
```

> 用`CA`来签署公共密钥

```shell script
echo subjectAltName = DNS:192.168.235.128,IP:192.168.235.128 >> extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf
```

> 生成`key`

```shell script
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -extfile extfile.cnf
```

> 创建客户端密钥和证书签名请求

```shell script
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
```

> 修改`extfile.cnf`

```shell script
echo extendedKeyUsage = clientAuth > extfile-client.cnf
```

> 生成签名私钥

```shell script
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out cert.pem -extfile extfile-client.cnf
```

> 将`Docker`服务停止，然后修改`docker`服务文件

停服务

```shell script
systemctl stop docker
```

编辑配置文件

```shell script
vi /etc/systemd/system/docker.service
```

替换`ExecStart=/usr/bin/dockerd`为以下

```shell script
ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/root/docker/ca.pem --tlscert=/root/docker/server-cert.pem --tlskey=/root/docker/server-key.pem -H unix:///var/run/docker.sock -H tcp://192.168.235.128:2375
```

重启

```shell script
systemctl daemon-reload
systemctl start docker
```

> 测试`tls`

```shell script
docker --tlsverify --tlscacert=/root/docker/ca.pem --tlscert=/root/docker/cert.pem --tlskey=/root/docker/key.pem -H=192.168.235.128:2375 version
```

### 配置合适的ulimit

- 描述

> 什么是`ulimit`

`ulimit`主要是用来限制进程对资源的使用情况的，它支持各种类型的限制，常用的有：
  
- 内核文件的大小限制
- 进程数据块的大小限制
- `Shell`进程创建文件大小限制
- 可加锁内存大小限制
- 常驻内存集的大小限制
- 打开文件句柄数限制
- 分配堆栈的最大大小限制
- `CPU`占用时间限制用户最大可用的进程数限制
- `Shell`进程所能使用的最大虚拟内存限制

- 隐患分析

`ulimit`提供对`shell`可用资源的控制。设置系统资源控制可以防止资源耗尽带来的问题，如`fork`炸弹。
有时候合法的用户和进程也可能过度使用系统资源，导致系统资源耗尽。
为`Docker`守护程序设置默认`ulimit`将强制执行所有容器的`ulimit`。
不需要单独为每个容器设置`ulimit`。 但默认的`ulimit`可能在容器运行时被覆盖。
因此，要控制系统资源，需要自定义默认的`ulimit`

- 审计

确保含有`--default-ulimit`参数

```shell script
[root@localhost ~]# ps -ef|grep dockerd
root      65353      1  0 03:02 ?        00:00:00 /usr/bin/dockerd --tlsverify --tlscacert=/root/docker/ca.pem --tlscert=/root/docker/server-cert.pem --tlskey=/root/docker/server-key.pem -H unix:///var/run/docker.sock -H tcp://192.168.235.128:2375
```

- 修复建议

> 调整参数`LimitNOFILE`、`LimitNPROC`

```shell script
sed -i "s#LimitNOFILE=infinity#LimitNOFILE=20480:40960#g" /etc/systemd/system/docker.service
sed -i "s#LimitNPROC=infinity#LimitNPROC=1024:2048#g" /etc/systemd/system/docker.service
```

> 重启
  
```shell script
systemctl daemon-reload
systemctl restart docker
```

> 启动一个容器测试

```shell script
[root@localhost ~]# docker run -idt --name ddd harbor.wl.com/public/alpine sh
15eebdabbb8bd59366348ae95a89d79100370b9c9381b070fdfbb0119b516400
```

> 查看容器`PID`

```shell script
[root@localhost ~]# ps -ef|grep 15eebdabbb8bd59366348ae95a89d79100370b9c9381b070fdfbb0119b516400|grep -v grep|awk '{print $2}'
80060
```

> 查看`limit`

```shell script
[root@localhost ~]# cat /proc/80060/limits
Limit                     Soft Limit           Hard Limit           Units
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             unlimited            unlimited            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        unlimited            unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             1024                 2048                 processes
Max open files            20480                40960                files
Max locked memory         65536                65536                bytes
Max address space         unlimited            unlimited            bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       3795                 3795                 signals
Max msgqueue size         819200               819200               bytes
Max nice priority         0                    0
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us
```

### 启用用户命名空间

- 描述

在`Docker`守护程序中启用用户命名空间支持，可对用户进行重新映射。该建议对镜像中没有指定用户是有帮助的。如果在容器镜像中已经
定义了非`root`运行，可跳过此建议。

- 隐患分析

`Docker`守护程序中对`Linux`内核用户命名空间支持为`Docker`主机系统提供了额外的安全性。
它允许容器具有独特的用户和组`ID`，这些用户和组`ID`在主机系统所使用的传统用户和组范围之外。
例如，`root`用户希望有容器内的管理权限，可映射到主机系统上的非`root`的`UID`上

- 审计

如果容器进程以`root`身份运行，则不符合安全要求

```shell script
[root@localhost ~]# ps -ef|grep 15eebdabbb8b
root      80060  73608  0 04:03 ?        00:00:00 containerd-shim -namespace moby -workdir /var/lib/docker/containerd/daemon/io.containerd.runtime.v1.linux/moby/15eebdabbb8bd59366348ae95a89d79100370b9c9381b070fdfbb0119b516400 -address /var/run/docker/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runc -systemd-cgroup
root     111259   1482  0 07:08 pts/0    00:00:00 grep --color=auto 15eebdabbb8b
```

- 修复建议

> 修改系统参数

```shell script
sed -i "/user.max_user_namespaces/d" /etc/sysctl.conf
echo "user.max_user_namespaces=15000" >> /etc/sysctl.conf
sysctl -p
```

> 编辑配置文件

```shell script
vi /etc/systemd/system/docker.service
```

`ExecStart=/usr/bin/dockerd`添加参数`--userns-remap=default`

> 重载服务

```shell script
systemctl daemon-reload
systemctl restart docker
```

> 启动一个容器

```shell script
[root@localhost ~]# docker run -idt --name ccc alpine
```

> 查看容器内进程用户

```shell script
[root@localhost ~]# ps -p $(docker inspect --format='{{.State.Pid}}' $(docker ps |grep ccc|awk '{print $1}')) -o pid,user
   PID USER
  2535 100000
```

### 使用默认cgroup

- 描述

查看`--cgroup-parent`选项允许设置用于所有容器的默认`cgroup parent`。 如果没有特定用例,则该设置应保留默认值。

- 隐患分析

系统管理员可定义容器应运行的`cgroup`。 若系统管理员没有明确定义`cgroup`，容器也会在`docker cgroup`下运行。
应该监测和确认使用情况。通过加到与默认不同的`cgroup`，导致不合理地共享资源，从而可能会主机资源耗尽

- 审计方式

```shell script
ps -ef|grep dockerd
```

确保`--cgroup-parent`参数未设置或设置为适当的非默认`cgroup`

- 修复建议

如无特殊需求，默认值即可

### 设置容器的默认空间大小

- 描述

在某些情况下，可能需要大于`10G`（容器默认存储大小）的容器空间。需要仔细选择空间的大小

- 隐患分析

守护进程重启时可以增加容器空间的大小。用户可以通过设置默认容器空间值来进行扩大，但不允许缩小。
设立该值的时候需要谨慎，防止设置不当带来空间耗尽的情况

- 审计方式

```shell script
ps -ef|grep dockerd
```

执行上述命令，它不应显示任何`--storage-opt dm.basesize`参数

- 修复建议

如无特殊需求，默认值即可

### 启用docker客户端命令的授权

- 描述

使用本机`Docker`授权插件或第三方授权机制与`Docker`守护程序来管理对`Docker`客户端命令的访问。

- 隐患分析

`Docker`默认是没有对客户端命令进行授权管理的功能。
任何有权访问`Docker`守护程序的用户都可以运行任何`Docker`客户端命令。
对于使用`Docker`远程`API`来调用守护进程的调用者也是如此。
如果需要细粒度的访问控制，可以使用授权插件并将其添加到`Docker`守护程序配置中。
使用授权插件，`Docker`管理员可以配置更细粒度访问策略来管理对`Docker`守护进程的访问。
`Docker`的第三方集成可以实现他们自己的授权模型，以要求`Docker`的本地授权插件
（即`Kubernetes`，`Cloud Foundry`，`Openshift`）之外的`Docker`守护进程的授权。

- 审计方式

```shell script
ps -ef|grep dockerd
或
cat /etc/docker/daemon.json|grep userland-proxy
```

如果使用`Docker`本地授权，可使用`--authorization-plugin`参数加载授权插件。

- 修复建议

如无特殊需求，默认值即可

### 配置集中和远程日志记录

- 描述

`Docker`现在支持各种日志驱动程序。存储日志的最佳方式是支持集中式和远程日志记录

- 审计方式

运行`docker info`并确保日志记录驱动程序属性被设置为适当的。

```shell script
[root@localhost ~]# docker info --format '{{.LoggingDriver}}'
json-file
```

- 修复建议

> 配置`json-file`驱动

```shell script
[root@localhost ~]# cat /etc/docker/daemon.json
{
     "log-driver":"json-file",
     "log-opts":{
         "max-size":"50m",
         "max-file":"3"
     }
}
```

> 重启

```shell script
systemctl daemon-reload
systemctl restart docker
```

### 禁用旧仓库版本（v1）上的操作

- 描述

最新的`Docker`镜像仓库是`v2`。遗留镜像仓库版本`v1`上的所有操作都应受到限制

- 隐患分析

`Docker`镜像仓库`v2`在`v1`中引入了许多性能和安全性改进。
它支持容器镜像来源验证和其他安全功能。因此，对`Docker v1`仓库的操作应该受到限制

- 审计方式

```shell script
ps -ef|grep dockerd
```

上面的命令应该列出`--disable-legacy-registry`作为传递给`Docker`守护进程的选项。

- 修复建议

**注意：**`17.12+`版本已移除，无需配置

> 编辑配置文件

```shell script
vi /etc/systemd/system/docker.service
```

`ExecStart=/usr/bin/dockerd`添加参数`--userns-remap=default`

> 重载服务

```shell script
systemctl daemon-reload
systemctl restart docker
```

### 启用实时恢复

- 描述

`live-restore`参数可以支持无守护程序的容器运行。
它确保`Docker`在关闭或恢复时不会停止容器，并在重新启动后重新连接到容器。

- 隐患分析

可用性作为安全一个重要的属性。 在`Docker`守护进程中设置`--live-restore`标志可确保当`Docker`守护进程不可用时容器执行不会中断。 
这也意味着当更新和修复`Docker`守护进程而不会导致容器停止工作。

- 审计方式

```shell script
[root@localhost ~]# docker info --format '{{.LiveRestoreEnabled}}'
false
```

- 修复建议

> 编辑文件

```shell script
mkdir -p /etc/docker/
vi /etc/docker/daemon.json
```

添加如下内容

```
"live-restore": true
```

> 重载服务

```shell script
systemctl daemon-reload
systemctl restart docker
```

### 禁用userland代理 

- 描述

当容器端口需要被映射时，`Docker`守护进程都会启动用于端口转发的`userland-proxy`方式。如果使用了`DNAT`方式，该功能可以被禁用

- 隐患分析

`Docker`引擎提供了两种机制将主机端口转发到容器,`DNAT`和`userland-proxy`。
在大多数情况下，`DNAT`模式是首选，因为它提高了性能，并使用本地`Linux iptables`功能而需要附加组件。
如果`DNAT`可用，则应在启动时禁用`userland-proxy`以减少安全风险。

- 审计方法

```shell script
ps -ef|grep dockerd
或
cat /etc/docker/daemon.json|grep userland-proxy
```

确保`userland-proxy`配置为`false`

- 修复建议

> 编辑文件

```shell script
mkdir -p /etc/docker/
vi /etc/docker/daemon.json
```

添加如下内容

```
"userland-proxy": false,
```

> 重载服务

```shell script
systemctl daemon-reload
systemctl restart docker
```

### 应用守护进程范围的自定义seccomp配置文件

- 描述

如果需要，您可以选择在守护进程级别自定义`seccomp`配置文件，并覆盖`Docker`的默认`seccomp`配置文件

- 隐患分析

大量系统调用暴露于每个用户级进程，其中许多系统调用在整个生命周期中都未被使用。
大多数应用程序不需要所有的系统调用，因此可以通过减少可用的系统调用来增加安全性。
可自定义`seccomp`配置文件，而不是使用`Docker`的默认`seccomp`配置文件。
如果`Docker`的默认配置文件够用的话，则可以选择忽略此建议

- 审计

```shell script
[root@localhost ~]# docker info --format '{{.SecurityOptions}}'
```

- 修复建议

错误配置的`seccomp`配置文件可能会中断的容器运行。`Docker`默认的策略兼容性很好，可以解决一些基本的安全问题。
所以，在[重写默认值](https://docs.docker.com/engine/security/seccomp/) 时，你应该非常小心

### 生产环境中避免实验性功能

- 描述

避免生产环境中的实验性功`-Experimental`

- 隐患分析

`Docker`实验功能现在是一个运行时`Docker`守护进程标志, 
其作为运行时标志传递给`Docker`守护进程，激活实验性功能。
实验性功能现在虽然比较稳定，但是一些功能可能没有大规模经使用，并不能保证`API`的稳定性，所以不建议在生产环境中使用

- 审计方法

```shell script
[root@localhost ~]# docker version --format '{{.Server.Experimental}}'
false
```

- 修复建议

不要将`--Experimental`作为运行时参数传递给`Docker`守护进程

### 限制容器获取新的权限

- 描述

默认情况下，限制容器通过`suid`或`sgid`位获取附加权限

- 隐患分析

一个进程可以在内核中设置`no_new_priv`。 它支持`fork`，`clone`和`execve`。
`no_new_priv`确保进程或其子进程不会通过`suid`或`sgid`位获得任何其他特权。
这样，很多危险的操作就降低安全风险。在守护程序级别进行设置可确保默认情况下，所有新容器不能获取新的权限。

- 审计方法

```shell script
ps -ef|grep dockerd
或
cat /etc/docker/daemon.json|grep no-new-privileges
```

确保`no-new-privileges`配置为`false`

- 修复建议

> 编辑文件

```shell script
mkdir -p /etc/docker/
vi /etc/docker/daemon.json
```

添加如下内容

```
"no-new-privileges": false
```

> 重载服务

```shell script
systemctl daemon-reload
systemctl restart docker
```

## 参考文档

[Docker容器最佳安全实践白皮书（V1.0）]()
[Docker官方文档](https://docs.docker.com/)