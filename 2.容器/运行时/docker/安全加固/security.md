{% raw %}
### 4.10 正确设置容器上的`CPU`优先级

- 描述

默认情况下，`Docker`主机上的所有容器均可共享资源。通过使用`Docker`主机的资源管理功能（如`CPU`共享），可以控制容器可能占用的主机`CPU`资源

- 隐患分析

默认情况下`CPU`时间在容器间平均分配。 如果需要，为了控制容器实例之间的`CPU`时间，可以使用`CPU`共享功能。
`CPU`共享允许将一个容器优先于另一个容器，并禁止较低优先级的容器更频繁占用`CPU`资源。可确保高优先级的容器更好地运行

- 审计方式

```shell script
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:CpuShares={{.HostConfig.CpuShares}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:CpuShares=0
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:CpuShares=0
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:CpuShares=0
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:CpuShares=0
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:CpuShares=0
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:CpuShares=0
```

如果上述命令返回`0`或`1024`，则表示`CPU`无限制。
如果上述命令返回非`1024`值以外的非零值，则表示`CPU`已经限制。

- 修复建议

管理容器之间的`CPU`份额。为此，请使用`--cpu-shares`参数启动容器

### 4.11 `Linux`内核功能在容器内受限

- 描述

默认情况下，`Docker`使用一组受限制的`Linux`内核功能启动容器。
这意味着可以将任何进程授予所需的功能，而不是`root`访问。
使用`Linux`内核功能，这些进程不必以`root`用户身份运行。

- 隐患分析

`Docker`支持添加和删除功能，允许使用非默认配置文件。
这可能会使`Docker`通过移除功能更加安全，或者通过增加功能来减少安全性。
因此，建议除去容器进程明确要求的所有功能。
例如，容器进程通常不需要如下所示的功能：`NET_ADMIN`、`SYS_ADMIN`、 `SYS_MODULE`

- 审计方式

```shell script
[root@localhost ~]# docker ps --quiet |xargs docker inspect --format '{{.Id}}:CapAdd={{.HostConfig.CapAdd}} CapDrop={{.HostConfig.CapDrop}}'
7121e891641679fda571e67a0e9953d263feca2508b013c70ae2546f6336b1a0:CapAdd=<no value> CapDrop=<no value>
bb3875c107daa062f2eccb10bd48ad54954cecd7d51a5eba385335f377b7aae9:CapAdd=<no value> CapDrop=<no value>
7a3a2c9e524a9d44ae857abd52447f86940dd49e1947291e7985b98e3c6a309a:CapAdd=<no value> CapDrop=<no value>
0780c27f8eb858e172e6a7458d2b2221130e6dde0f64887d396ad5bc350a4a64:CapAdd=<no value> CapDrop=<no value>
```

验证添加和删除的`Linux`内核功能是否符合每个容器实例的容器进程所需的功能

- 修复建议

只添加必须功能特性

```shell script
docker run -dit --cap-drop=all --cap-add={"NET_ADMIN", "SYS_ADMIN"} centos /bin/bash
```

默认情况下，以下功能可用于容器:

`AUDIT_WRITE`、`CHOWN`、`DAC_OVERRIDE`、`FOWNER`、`FSETID`、`KILL`、`MKNOD`、`NET_BIND_SERVICE`、`NET_RAW`、
`SETFCAP`、`SETGID`、`SETPCAP`、`SETUID`、`SYS_CHROOT`

> Linux kernel capabilities机制介绍

默认情况下，`Docker`启动具有一组受限功能的容器。

`capabilities`机制将二进制`root/no-root`二分法转换为细粒度的访问控制系统。
只需要绑定`1024`以下端口的进程(比如`web`服务器)不需要以`root`身份运行:它们只需要被授予`net_bind_service`能力即可。
对于通常需要根特权的几乎所有特定领域，还有许多其他功能。

典型的服务器以`root`身份运行多个进程，包括`SSH`守护进程、`cron`守护进程、日志守护进程、内核模块、网络配置工具等。
容器是不同的，因为几乎所有这些任务都由容器周围的基础设施处理:

- `SSH`访问通常由运行在`Docker`宿主机管理
- 必要时，`cron`应该作为一个用户进程运行，专门为需要调度服务的应用程序定制，而不是作为一个平台范围的工具
- 日志管理通常也交给`Docker`，或者像`Loggly`或`Splunk`这样的第三方服务
- 硬件管理是不相关的，这意味着您永远不需要在容器中运行`udevd`或等效的守护进程
- 网络管理也都在宿主机上设置，除非特殊需求。这意味着容器不需要执行`ifconfig`、`route`或`ip`命令（当然，除非容器被专门设计成路由器或防火墙）


这意味这大部分情况下，容器完全不需要真正的`root`权限。因此，容器可以运行一个减少的`capabilities`集，容器中的`root`也比真正的`root`拥有更少的`capabilities`,比如：

- 完全禁止任何`mount`操作
- 禁止访问络`socket`
- 禁止访问一些文件系统的操作，比如创建新的设备`node`等等
- 禁止模块加载

这意味这就算攻击者在容器中取得了`root`权限，也很难造成严重破坏

这不会影响到普通的`web`应用程序，但会大大减少恶意用户的攻击。默认情况下，`Docker`会删除所有需要的功能，使用`allowlist`而不是`denylist`方法

运行`Docker`容器的一个主要风险是，给容器的默认功能集和挂载可能会提供不完全的隔离

`Docker`支持添加和删除`capabilities`功能，允许使用非默认配置文件。这可能会使`Docker`通过删除功能而变得更安全，或者通过增加功能而变得更不安全。对于用户来说，最佳实践是删除除其流程显式需要的功能之外的所有功能

**简言之：`Linux Kernel capabilities`提供更细粒度的`root`权限控制**


### 4.13 敏感的主机系统目录未挂载在容器上

- 描述

不应允许将敏感的主机系统目录（如下所示）作为容器卷进行挂载，特别是在读写模式下。

```shell script
boot dev etc lib lib64 proc run sbin sys usr var
```

- 隐患分析

如果敏感目录以读写方式挂载，则可以对这些敏感目录中的文件进行更改。
这些更改可能会降低安全性，且直接影响`Docker`宿主机

- 审计方式

```shell script
[root@localhost ~]# docker ps --quiet |xargs docker inspect --format '{{.Id}}:Volumes={{.Mounts}}'
7121e891641679fda571e67a0e9953d263feca2508b013c70ae2546f6336b1a0:Volumes=[map[Destination:/config Driver:local Mode: Name:800e943d52c78312b2d6dd53bed41999fd5f7780af5098f688a894fb74f4360f Propagation: RW:true Source:/var/lib/docker/volumes/800e943d52c78312b2d6dd53bed41999fd5f7780af5098f688a894fb74f4360f/_data Type:volume]]
bb3875c107daa062f2eccb10bd48ad54954cecd7d51a5eba385335f377b7aae9:Volumes=[map[Destination:/var/lib/postgresql/data Driver:local Mode: Name:774546bf5c3dcfe5f90a60012c5f1f2bdeb57a5908cdc1922b3dc75550ceeaa4 Propagation: RW:true Source:/var/lib/docker/volumes/774546bf5c3dcfe5f90a60012c5f1f2bdeb57a5908cdc1922b3dc75550ceeaa4/_data Type:volume]]
7a3a2c9e524a9d44ae857abd52447f86940dd49e1947291e7985b98e3c6a309a:Volumes=[map[Destination:/usr/src/redmine/config/configuration.yml Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/config/configuration.yml Type:bind] map[Destination:/usr/src/redmine/files Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/files Type:bind] map[Destination:/usr/src/redmine/app/models/attachment.rb Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/config/attachment.rb Type:bind] map[Destination:/usr/src/redmine/config.ru Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/config/config.ru Type:bind]]
0780c27f8eb858e172e6a7458d2b2221130e6dde0f64887d396ad5bc350a4a64:Volumes=[map[Destination:/var/lib/mysql Mode: Propagation:rprivate RW:true Source:/cephfs/redmine/mysql Type:bind]]
```

- 修复建议

不要将主机敏感目录挂载在容器上，尤其是在读写模式下


### 4.17 确保容器的内存使用合理

- 描述

默认情况下，`Docker`主机上的所有容器均等共享资源。
通过使用`Docker`主机的资源管理功能，例如内存限制，您可以控制容器可能消耗的内存量

- 隐患分析

默认情况下，容器可以使用主机上的所有内存。
您可以使用内存限制机制来防止由于一个容器消耗了所有主机资源而导致拒绝服务，以致同一主机上的其他容器无法执行预期功能

- 审计方式

```shell script
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Memory={{.HostConfig.Memory}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:Memory=0
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:Memory=0
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Memory=0
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Memory=0
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Memory=0
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Memory=0
```

如果上述命令返回0，则表示内存无限制。如果上述命令返回非零值，则表示已有内存限制策略

- 修复建议

建议使用`--momery`参数运行容器，例如可以如下运行一个容器

```shell script
docker run -idt --memory 256m centos
```

### 4.18 设置容器的根文件系统为只读

- 描述

通过使用`Docker`运行的只读选项，容器的根文件系统应被视为`只读镜像`。 这样可以防止在容器运行时写入容器的根文件系统

- 隐患分析

启用此选项会迫使运行时的容器明确定义其数据写入策略，可减少安全风险，
因为容器实例的文件系统不能被篡改或写入，除非它对文件系统文件夹和目录具有明确的读写权限。

- 审计方式

```shell script
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:ReadonlyRootfs={{.HostConfig.ReadonlyRootfs}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:ReadonlyRootfs=false
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:ReadonlyRootfs=false
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:ReadonlyRootfs=false
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:ReadonlyRootfs=false
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:ReadonlyRootfs=false
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:ReadonlyRootfs=false
```

如果上述命令返回`true`，则表示容器的根文件系统是只读的。
如果上述命令返回`false`，则意味着容器的根文件系统是可写的

- 修复建议

在容器的运行时添加一个只读标志以强制容器的根文件系统以只读方式装入

```shell script
docker run  <Run arguments> -read-only <Container Image Name or ID> <Command>
```

在容器的运行时启用只读选项，包括但不限于如下：

> 1.使用`--tmpfs` 选项为非持久数据写入临时文件系统

```shell script
docker run -idt --read-only --tmpfs "/run" --tmpfs "/tmp" centos bash
```

> 2.启用Docker rw在容器的运行时载入，以便将容器数据直接保存在Docker主机文件系统上

```shell script
docker run -idt --read-only -v /opt/app/data:/run/app/data:rw centos
```

> 3.在容器运行期间，将容器数据传输到容器外部，以便保持容器数据。包括托管数据库，网络文件共享和 API。

### 4.19 确保进入容器的流量绑定到特定的主机接口

- 描述

默认情况下，`Docker`容器可以连接到外部，但外部无法连接到容器。
每个传出连接都源自主机自己的`IP`地址。所以只允许通过主机上的特定外部接口访问容器服务

- 隐患分析

如果主机上有多个网络接口，则容器可以接受任何网络接一上公开端口的连接，这可能不安全。
很多时候，特定的端口暴露在外部，并且在这些端口上运行诸如入侵检测，入侵防护，防火墙，负载均衡等服务以筛选传入的公共流量。
因此，只允许来自特定外部接口的传入连接

- 审计方式

通过执行以下命令列出容器的所有运行实例及其端口映射

```shell script
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Ports={{.NetworkSettings.Ports}}'
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:Ports=map[80/tcp:[map[HostIp:0.0.0.0 HostPort:8080]]]
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Ports=map[]
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Ports=map[]
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Ports=map[]
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Ports=map[]
```

查看列表并确保公开的容器端口与特定接口绑定，而不是通配符`IP`地址`- 0.0.0.0`
例如，如果上述命令返回是不安全的，并且容器可以接受指定端口8080上的任何主机接口上的连接

- 修复建议

将容器端口绑定到所需主机端口上的特定主机接口。

```shell script
[root@localhost ~]# docker run -idt --name=nginx2 -p 192.168.235.128:18080:80 --network=nginx-net nginx:1.14-alpine
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Ports={{.NetworkSettings.Ports}}'
83243cce85b85f9091b4c3bd7ff981762ff91c50e42ca36f2a5f47502ff00377:Ports=map[80/tcp:[map[HostIp:192.168.235.128 HostPort:18080]]]
748901568eafe1d3c21bb8e544278ed36af019281d485eb74be39b41ca549605:Ports=map[80/tcp:[map[HostIp:0.0.0.0 HostPort:8080]]]
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Ports=map[]
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Ports=map[]
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Ports=map[]
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Ports=map[]
```

### 4.20 容器重启策略`on-failure`设置为`5`

- 描述

在`docker run`命令中使用`--restart`标志，可以指定重启策略，以便在廿出时确定是否重启容器。
基于安全考虑，应该设置重启尝试次数限制为5次

- 隐患分析

如果无限期地尝试启动容器，可能会导致主机上的拒绝服务。
这可能是一种简单的方法来执行分布式拒绝服务攻击，特别是在同一主机上有多个容器时。
此外，忽略容器的廿出状态并始终尝试重新启动容器导致未调查容器终止的根本原因。
如果一个容器被终止，应该做的是去调查它重启的原因，而不是试图无限期地重启它。 
因此，建议使用故障重启策略并将其限制为最多 5 次重启尝试

- 审计方式

```shell script
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:RestartPolicyName={{.HostConfig.RestartPolicy.Name}} MaximumRetryCount={{.HostConfig.RestartPolicy.MaximumRetryCount}}'
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:RestartPolicyName=no MaximumRetryCount=0
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:RestartPolicyName=no MaximumRetryCount=0
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:RestartPolicyName=no MaximumRetryCount=0
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:RestartPolicyName=no MaximumRetryCount=0
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:RestartPolicyName=no MaximumRetryCount=0
```

- 修复建议

如果一个容器需要自己重新启动，可以如下设置：

```shell script
docker run -idt --restart=on-failure:5 nginx
```



### 4.23 主机设备不直接共享给容器

- 描述

主机设备可以在运行时直接共享给容器。 不要将主机设备直接共享给容器，特别是对不受信任的容器

- 隐患分析

选项`--device` 将主机设备共享给容器，因此容器可以直接访问这些主机设备。
不允许容器以特权模式运行以访问和操作主机设备默认情况下，容器将能够读取，写入和`mknod`这些设备。
此外，容器可能会从主机中删除设备。 因此，不要直接将主机设备共享给容器。如果必须的将主机设备共享给容器，请适当地使用共享权限：

```shell script
w -> write
r -> read
m -> mknod
```

- 审计方式

```shell script
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{{.Id}}:Devices={{.HostConfig.Devices}}'
3b8b371f5e800e25d85e7426020cb7088e6cccb5bd950ad269a185cadf6f7adc:Devices=[]
5bf74b6014405acad5f724cb005b320a864528ac2dd48de1fbb0e37165befc71:Devices=[]
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:Devices=[]
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:Devices=[]
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:Devices=[]
```

验证是否需要从容器中访问主机设备，并且正确设置所需的权限。如果上述命令返回[]，则容器无权访问主机设备

- 修复建议

不要将主机设备直接共享于容器。如果必须将主机设备共享给容器，请使用正确的一组权限，以下为错误示范

```shell script
docker run --interactive --tty --device=/dev/tty0:/dev/tty0:rwm centos bash
```

### 4.24 设置装载传播模式不共享

- 描述

装载传播模式允许在容器上以`shared`、`private`和`slave`模式挂载数据卷。只有必要的时候才使用共享模式

- 隐患分析

共享模式下挂载卷不会限制任何其他容器的安装并对该卷进行更改。
如果使用的数据卷对变化比较敏感，则这可能是灾难性的。最好不要将安装传播模式设置为共享

- 审计方式

```shell script
[root@localhost ~]# docker ps --quiet --all|xargs docker inspect --format '{.Id}:Propagation={{range $mnt:=.Mounts}}{{json $mnt.Propagation}}{{end}}'
{.Id}:Propagation=
{.Id}:Propagation=
{.Id}:Propagation=
{.Id}:Propagation=
{.Id}:Propagation=
```

上述命令将返回已安装卷的传播模式。除非需要，不应将传播模式设置为共享。

- 修复建议

不建议以共享模式传播中安装卷。例如，不要启动容器，如下所示

```shell script
docker run <Run arguments> --volume=/hostPath:/containerPath:shared <Container Image Name or ID> <Command>
```

### 4.29 限制使用`PID cgroup`

- 描述

在容器运行时使用`--pids-limit`标志

- 隐患分析

攻击者可以在容器内发射`fork`炸弹。 这个`fork`炸弹可能会使整个系统崩溃，并需要重新启动主机以使系统重新运行。 
`PIDs cgroup --pids-limit`将通过限制在给定时间内可能发生在容器内的`fork`数来防止这种攻击

- 审计分析

运行以下命令并确保`PidsLimit`未设置为`0`或`-1`。
`PidsLimit`为`0`或`-1`意味着任何数量的进程可以同时在容器内分叉。

```shell script
[root@localhost ~]# docker ps --quiet | xargs docker inspect --format='{{.Id}}:PidsLi                                                            mit={{.HostConfig.PidsLimit}}'
0aede0130fd30b8cb40200aa9b61e84f0d911740617dda3dd707037655419854:PidsLimit=<no value>
d35fd7bd5e90e6aebc237368453361f632f775490da3c1d28011b9f7e43ff75c:PidsLimit=<no value>
cff4f40d63e7ba39cb013706f0c73351c3a99325adf606c715df63b8c81001be:PidsLimit=<no value>
```

- 修复建议

升级内核至`4.3+`，添加`--pids-limit参数`，如

```shell script
docker run -idt --name=box --pids-limit=100 busybox:1.31.1
```





## 5.`Docker`安全操作

### 5.1 避免镜像泛滥

- 描述

不要在同一主机上保留大量容器镜像，根据需要仅使用标记的镜像。 

- 隐患分析

标记镜像有助于从`latest`退回到生产中镜像的特定版本。
如果实例化了未使用或旧标签的镜像，则可能包含可能被利用的漏洞。
此外，如果您无法从系统中删除未使用的镜像，并且存在各种此类冗余和未使用的镜像，主机文件空间可能会变满，从而导致拒绝服务。

- 审计方式

> 1.通过执行以下命令列出当前实例化的所有镜像`ID`

```shell script
[root@localhost ~]# docker images --quiet | xargs docker inspect --format='{{.Id}}:Image={{.Config.Image}}'
sha256:d6e46aa2470df1d32034c6707c8041158b652f38d2a9ae3d7ad7e7532d22ebe0:Image=sha256:3543079adc6fb5170279692361be8b24e89ef1809a374c1b4429e1d560d1459c
```

> 2.通过执行以下命令列出系统中存在的所有镜像

```shell script
[root@localhost ~]# docker images
REPOSITORY                         TAG       IMAGE ID       CREATED        SIZE
harbor.wl.com/public/alpine   latest    d6e46aa2470d   6 months ago   5.57MB
```

> 3.比较步骤1和步骤2中的镜像`ID`列表，找出当前未实例化的镜像。如果发现未使用或旧镜像，请与系统管理员讨论是否需要在系统上保留这些镜像

- 修复建议

保留您实际需要的一组镜像，并建立工作流程以从主机中删除陈旧的镜像。
此外，使用诸如按摘要的功能从镜像仓库中获取特定镜像。
对于无用镜像，应予以删除

### 5.2 避免容器泛滥

- 描述

不要在同一主机上保留大量无用容器 

- 隐患分析

容器的灵活性使得运行多个应用程序实例变得很容易，并间接导致存在于不同安全补丁级别的`Docker`镜像。
因此，避免容器泛滥，并将主机上的容器数量保持在可管理的总量上

- 审计方式

> 1.查找主机上的容器总数

```shell script
[root@localhost ~]# docker info --format '{{.Containers}}'
1
```
> 2.执行以下命令以查找主机上实际正在运行或处于停止状态的容器总数。

```shell script
[root@localhost ~]# docker info --format '{{.ContainersStopped}}'
0
[root@localhost ~]# docker info --format '{{.ContainersRunning}}'
1
```

如果主机上保留的容器数量与主机上实际运行的容器数量之间的差异很大（比如说 25 或更多），
那么请清理无用容器（确保`stopped`无用再进行清理）。

- 修复建议

定期检查每个主机的容器清单，并使用以下命令清理已停止的容器

```
[root@localhost ~]# docker container prune
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
Total reclaimed space: 0B
```

## 最佳实践

### 安装

> 安装更新`CentOS 7`最新稳定版

降低低版本操作系统可能存在的安全漏洞

> 安装更新最新稳定版内核

- [香港镜像源](http://hkg.mirror.rackspace.com/elrepo/kernel/el7/x86_64/RPMS/)

更新高版本内核以支持`docker`新特性、降低内核导致的安全漏洞风险

> 安装最新稳定版`docker-ce`

- [docker-ce 二进制下载地址](https://download.docker.com/mac/static/stable/x86_64/)
- [docker-ce 镜像源](https://mirrors.tuna.tsinghua.edu.cn/docker-ce/)

### 配置

> 配置`limit`参数

```shell script
ulimit -HSn 65536
cat <<EOF >>/etc/security/limits.conf
*    soft    nofile    65536
*    hard    nofile    65536
*    soft    noproc    10240
*    hard    noproc    10240
EOF
```

> 配置内核参数

```shell script
cat <<EOF >>/etc/sysctl.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
user.max_user_namespaces=15000
EOF
sysctl -p
```

> 配置`docker daemon`

```shell script
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "log-opts": {
    "max-size": "5m",
    "max-file":"3"
  },
  "userland-proxy": false,
  "live-restore": true,
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  },
  "default-address-pools": [
    {
      "base": "172.80.0.0/16",
      "size": 24
    },
    {
      "base": "172.90.0.0/16",
      "size": 24
    }
  ],
  "no-new-privileges": false,
  "default-gateway": "",
  "default-gateway-v6": "",
  "default-runtime": "runc",
  "default-shm-size": "64M",
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload
systemctl restart docker
```
 
### 文件权限调整

```shell script
chmod 755 /etc/docker
chown root:root /etc/docker
chmod 660 /var/run/docker.sock
chown root:docker /var/run/docker.sock
systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 chmod 644
systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 chmod 644
systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 chown root:root
systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 chown root:root
if [ -d /etc/docker/certs.d/ ];then chmod 444 /etc/docker/certs.d/*; fi
if [ -d /etc/docker/certs.d/ ];then chown root:root /etc/docker/certs.d/*; fi
if [ -f /etc/docker/daemon.json ];then chown root:root /etc/docker/daemon.json; fi
```
 
## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)

{% endraw %}