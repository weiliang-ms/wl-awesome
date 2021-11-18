# Kubernetes下pod控制组管理解析

> 开始之前我们先了解下`Kubernetes QoS`概念

在`Kubernetes`里面，将资源分成不同的`QoS`类别，并且通过`pod`里面的资源定义来区分`pod`对于平台提供的资源保障的`SLA`等级：

- `Guaranteed`: `pod`中每个容器都为`CPU`和内存设置了相同的`requests`和`limits`，此类`pod`具有最高优先级
- `Burstable`: 至少有一个容器设置了`CPU`或内存的`requests`属性，但不满足`Guaranteed`类别要求的`pod`，它们具有中等优先级
- `BestEffort`: 未为任何一个容器设置`requests`和`limits`属性的`pod`，它们的优先级为最低级别

针对不同的优先级的业务，在资源紧张或者超出的时候会有不同的处理策略。
同时，针对`CPU`和内存两类不同类型的资源，一种是可压缩的，一种是不可压缩的，所以资源的分配和调控策略也会有很大区别。
`CPU`资源紧缺时，如果节点处于超卖状态，则会根据各自的`requests`配置，按比例分配`CPU`时间片，而内存资源紧缺时需要内核的`oom killer`进行管控，
`Kubernetes`负责为`OOM killer`提供管控依据：

1. `BestEfford`类容器由于没有要求系统供任何级别的资源保证，将最先被终止；但是在资源不紧张时，它们能尽可能多地占用资源，实现资源的复用和部署密度的提高
2. 如果`BestEfford`类容器都已经终止，`Burstable`中等优先级的的`pod`将被终止
3. `Guaranteed`类容器拥有最高优先级，只有在内存资源使用超出`limits`的时候或者节点`OOM`时得分最高，才会被终止；

`OOM`得分主要根据`QoS`类和容器的`requests`内存占机器总内存比来计算：

![](images/oom-score.png)

`OOM`得分越高，该进程的优先级越低，越容易被终止；根据公式，`Burstable`优先级的`pod`中，`requests`内存申请越多，越容易在`OOM`的时候被终止。

## pod的cpu控制组解析

首先我们先看下`pod`的控制组层级

```shell
$ ls -l /sys/fs/cgroup/cpu/kubepods.slice
total 0
-rw-r--r--  1 root root 0 Aug 23 16:32 cgroup.clone_children
-rw-r--r--  1 root root 0 Aug 23 16:32 cgroup.procs
-r--r--r--  1 root root 0 Aug 23 16:32 cpuacct.stat
-rw-r--r--  1 root root 0 Aug 23 16:32 cpuacct.usage
-r--r--r--  1 root root 0 Aug 23 16:32 cpuacct.usage_all
-r--r--r--  1 root root 0 Aug 23 16:32 cpuacct.usage_percpu
-r--r--r--  1 root root 0 Aug 23 16:32 cpuacct.usage_percpu_sys
-r--r--r--  1 root root 0 Aug 23 16:32 cpuacct.usage_percpu_user
-r--r--r--  1 root root 0 Aug 23 16:32 cpuacct.usage_sys
-r--r--r--  1 root root 0 Aug 23 16:32 cpuacct.usage_user
-rw-r--r--  1 root root 0 Aug 23 16:32 cpu.cfs_period_us
-rw-r--r--  1 root root 0 Aug 23 16:32 cpu.cfs_quota_us
-rw-r--r--  1 root root 0 Aug 23 16:32 cpu.rt_period_us
-rw-r--r--  1 root root 0 Aug 23 16:32 cpu.rt_runtime_us
-rw-r--r--  1 root root 0 Sep  1 17:38 cpu.shares
-r--r--r--  1 root root 0 Aug 23 16:32 cpu.stat
drwxr-xr-x 55 root root 0 Aug 23 16:32 kubepods-besteffort.slice
drwxr-xr-x 51 root root 0 Aug 23 16:32 kubepods-burstable.slice
drwxr-xr-x  4 root root 0 Aug 23 16:54 kubepods-pod934b0aa2_1d1b_4a81_bfcf_89c4beef899e.slice
drwxr-xr-x  4 root root 0 Aug 23 16:39 kubepods-podca849e84_aa86_4402_bf31_e7e73faa77fe.slice
-rw-r--r--  1 root root 0 Aug 23 16:32 notify_on_release
-rw-r--r--  1 root root 0 Aug 23 16:32 tasks
```

其中`kubepods-besteffort.slice`存放`besteffort`类型`pod`配置，`kubepods-burstable.slice`存放`burstable`类型`pod`配置。

`kubepods-pod934b0aa2_1d1b_4a81_bfcf_89c4beef899e.slice`、`kubepods-podca849e84_aa86_4402_bf31_e7e73faa77fe.slice`则为`Guaranteed`类型`pod`

为了更好的解释说明，我们创建一个新的`Guaranteed`类型的`pod`用于测试:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      limits:
        cpu: "1"
        memory: 1Gi
      requests:
        cpu: 1
        memory: 1Gi
EOF
```

1. 再次查看`/sys/fs/cgroup/cpu/kubepods.slice`下，发现新增了一个`kubepods-podf56bf66f_3efb_4c80_8818_37de69ee5b72.slice`目录

2. 名称解析

`kubepods-podf56bf66f_3efb_4c80_8818_37de69ee5b72.slice`这个名称是怎么命名的呢？

命名格式为：`kubepods-pod<pod uid>.slice`，并且会将`uid`中`-`转换为`_`

```shell
$ kubectl get pod nginx-demo -o yaml|grep uid
  uid: f56bf66f-3efb-4c80-8818-37de69ee5b72
```

3. 目录解析

```shell
$ ls -l /sys/fs/cgroup/cpu/kubepods.slice/kubepods-podf56bf66f_3efb_4c80_8818_37de69ee5b72.slice
-rw-r--r-- 1 root root 0 Nov 17 11:23 cgroup.clone_children
-rw-r--r-- 1 root root 0 Nov 17 11:23 cgroup.procs
-r--r--r-- 1 root root 0 Nov 17 11:23 cpuacct.stat
-rw-r--r-- 1 root root 0 Nov 17 11:23 cpuacct.usage
-r--r--r-- 1 root root 0 Nov 17 11:23 cpuacct.usage_all
-r--r--r-- 1 root root 0 Nov 17 11:23 cpuacct.usage_percpu
-r--r--r-- 1 root root 0 Nov 17 11:23 cpuacct.usage_percpu_sys
-r--r--r-- 1 root root 0 Nov 17 11:23 cpuacct.usage_percpu_user
-r--r--r-- 1 root root 0 Nov 17 11:23 cpuacct.usage_sys
-r--r--r-- 1 root root 0 Nov 17 11:23 cpuacct.usage_user
-rw-r--r-- 1 root root 0 Nov 17 11:23 cpu.cfs_period_us
-rw-r--r-- 1 root root 0 Nov 17 11:23 cpu.cfs_quota_us
-rw-r--r-- 1 root root 0 Nov 17 11:23 cpu.rt_period_us
-rw-r--r-- 1 root root 0 Nov 17 11:23 cpu.rt_runtime_us
-rw-r--r-- 1 root root 0 Nov 17 11:23 cpu.shares
-r--r--r-- 1 root root 0 Nov 17 11:23 cpu.stat
drwxr-xr-x 2 root root 0 Nov 17 11:23 docker-08974ffd61043b34e4cd5710d5446eb423c6371afb4c9d106e608f08cc1182a3.scope
drwxr-xr-x 2 root root 0 Nov 17 11:24 docker-d33dc12340fd32b35148293c21f84dab14f2274046056bbeef9e9666d1d0dc2a.scope
-rw-r--r-- 1 root root 0 Nov 17 11:23 notify_on_release
-rw-r--r-- 1 root root 0 Nov 17 11:23 tasks
```

我们发现怎么有两个容器呢？（`docker-08974ffd61043b34e4cd5710d5446eb423c6371afb4c9d106e608f08cc1182a3.scope`、`docker-d33dc12340fd32b35148293c21f84dab14f2274046056bbeef9e9666d1d0dc2a.scope`）

其实是业务容器 + `infra`沙箱容器，并且命名格式遵循：`docker-<container id>.scope`

```shell
$ docker ps|grep nginx
d33dc12340fd   nginx                                                                         "/docker-entrypoint.…"    7 minutes ago   Up 7 minutes             k8s_nginx_nginx-demo_default_f56bf66f-3efb-4c80-8818-37de69ee5b72_0
08974ffd6104   harbor.chs.neusoft.com/kubesphere/pause:3.2                                   "/pause"                  8 minutes ago   Up 8 minutes             k8s_POD_nginx-demo_default_f56bf66f-3efb-4c80-8818-37de69ee5b72_0
```

我们可根据以下命令获取业务容器`id`：

```shell
$ kubectl get pod nginx-demo -o yaml|grep containerID
  - containerID: docker://d33dc12340fd32b35148293c21f84dab14f2274046056bbeef9e9666d1d0dc2a
```

4. 业务容器`cgroup`解析

```shell
$ cd /sys/fs/cgroup/cpu/kubepods.slice/kubepods-podf56bf66f_3efb_4c80_8818_37de69ee5b72.slice/docker-d33dc12340fd32b35148293c21f84dab14f2274046056bbeef9e9666d1d0dc2a.scope
$ ls -l 
total 0
-rw-r--r-- 1 root root 0 Nov 17 11:24 cgroup.clone_children
-rw-r--r-- 1 root root 0 Nov 17 11:24 cgroup.procs
-r--r--r-- 1 root root 0 Nov 17 11:24 cpuacct.stat
-rw-r--r-- 1 root root 0 Nov 17 11:24 cpuacct.usage
-r--r--r-- 1 root root 0 Nov 17 11:24 cpuacct.usage_all
-r--r--r-- 1 root root 0 Nov 17 11:24 cpuacct.usage_percpu
-r--r--r-- 1 root root 0 Nov 17 11:24 cpuacct.usage_percpu_sys
-r--r--r-- 1 root root 0 Nov 17 11:24 cpuacct.usage_percpu_user
-r--r--r-- 1 root root 0 Nov 17 11:24 cpuacct.usage_sys
-r--r--r-- 1 root root 0 Nov 17 11:24 cpuacct.usage_user
-rw-r--r-- 1 root root 0 Nov 17 11:24 cpu.cfs_period_us
-rw-r--r-- 1 root root 0 Nov 17 11:24 cpu.cfs_quota_us
-rw-r--r-- 1 root root 0 Nov 17 11:24 cpu.rt_period_us
-rw-r--r-- 1 root root 0 Nov 17 11:24 cpu.rt_runtime_us
-rw-r--r-- 1 root root 0 Nov 17 11:24 cpu.shares
-r--r--r-- 1 root root 0 Nov 17 11:24 cpu.stat
-rw-r--r-- 1 root root 0 Nov 17 11:24 notify_on_release
-rw-r--r-- 1 root root 0 Nov 17 11:24 tasks
```

我们上述对`pod`配额的定义为:

```
resources:
  limits:
    cpu: "1"
    memory: 1Gi
  requests:
    cpu: 1
    memory: 1Gi
```

其实等同于以以下方式启动`docker`容器:

```shell
$ docker run --rm -dt --cpu-shares=1024 --cpu-quota=1024 --memory=1g nginx
```

我们可以看下`docker`容器的配额：

```shell
$ docker inspect d33dc12340fd32b35148293c21f84dab14f2274046056bbeef9e9666d1d0dc2a -f {{.HostConfig.CpuShares}}
1024
$ docker inspect d33dc12340fd32b35148293c21f84dab14f2274046056bbeef9e9666d1d0dc2a -f {{.HostConfig.CpuQuota}}
100000
$ docker inspect d33dc12340fd32b35148293c21f84dab14f2274046056bbeef9e9666d1d0dc2a -f {{.HostConfig.CpuPeriod}}
100000
```

`.HostConfig.CpuShares`对应控制内的`cpu.shares`文件内容
`.HostConfig.CpuPeriod`对应控制内的`cpu.cpu.cfs_period_us`文件内容
`.HostConfig.CpuQuota`对应控制内的`cpu.cfs_quota_us`文件内容

并且我们发现`k8s`基于`pod`管理控制组（同一`pod`内的容器所属同一控制组）

```
"CgroupParent": "kubepods-podf56bf66f_3efb_4c80_8818_37de69ee5b72.slice",
```

我们可以得出记录：`k8s`通过控制组的`cpu.shares`、`cpu.cpu.cfs_period_us`、`cpu.cfs_quota_us`配置，达到限制`CPU`的目的。

那么这三个文件是用来干嘛的？

> `cpu.shares`解析

1. `cpu.shares`用来设置`CPU`的相对值，并且是针对所有的`CPU`（内核），默认值是`1024`等同于一个`cpu`核心。
`CPU Shares`将每个核心划分为`1024`个片，并保证每个进程将按比例获得这些片的份额。如果有`1024`个片(即1核)，并且两个进程设置`cpu.shares`均为`1024`，那么这两个进程中每个进程将获得大约一半的`cpu`可用时间。

当系统中有两个`cgroup`，分别是`A`和`B`，`A`的`shares`值是`1024`，B 的`shares`值是`512`，
那么`A`将获得`1024/(1024+512)=66%`的`CPU`资源，而`B`将获得`33%`的`CPU`资源。`shares`有两个特点：

- 如果`A`不忙，没有使用到`66%`的`CPU`时间，那么剩余的`CPU`时间将会被系统分配给`B`，即`B`的`CPU`使用率可以超过`33%`。
- 如果添加了一个新的`cgroup C`，且它的`shares`值是`1024`，那么`A`的限额变成了`1024/(1024+512+1024)=40%`，`B`的变成了`20%`。

从上面两个特点可以看出：

在闲的时候，`shares`基本上不起作用，只有在`CPU`忙的时候起作用，这是一个优点。

由于`shares`是一个绝对值，需要和其它`cgroup`的值进行比较才能得到自己的相对限额，而在一个部署很多容器的机器上，`cgroup`的数量是变化的，所以这个限额也是变化的，自己设置了一个高的值，但别人可能设置了一个更高的值，所以这个功能没法精确的控制`CPU`使用率。

2. `cpu.shares`对应`k8s`内的`resources.requests.cpu`字段：

值对应关系为：`resources.requests.cpu` * 1024 = `cpu.shares`

如：`resources.requests.cpu`为3的时候，`cpu.shares`值为`3072`；`resources.requests.cpu`为`100m`的时候，`cpu.shares`值为`102`

> `cpu.cpu.cfs_period_us`、`cpu.cfs_quota_us`解析

1. `cpu.cfs_period_us`用来配置时间周期长度，`cpu.cfs_quota_us`用来配置当前`cgroup`在设置的周期长度内所能使用的`CPU`时间数。
两个文件配合起来设置`CPU`的使用上限。两个文件的单位都是微秒（`us`），`cfs_period_us`的取值范围为`1`毫秒（`ms`）到`1`秒（s），`cfs_quota_us`的取值大于`1ms`即可，如果`cfs_quota_us`的值为`-1`（默认值），表示不受`cpu`时间的限制。

2. `cpu.cpu.cfs_period_us`、`cpu.cfs_quota_us`对应`k8s`中的`resources.limits.cpu`字段：

```
resources.limits.cpu = cpu.cfs_quota_us/cpu.cfs_period_us
```

并且`k8s`下容器控制组的`cpu.cpu.cfs_period_us`值固定为`100000`，实际只设置`cpu.cfs_quota_us`值

例如：

`cpu.cpu.cfs_period_us`为`100000`（单位微妙，即0.1秒），`cpu.cfs_quota_us`为`500000`（单位微妙，即`0.5`秒）时，`resources.limits.cpu`为5，即5个`cpu`核心。
`cpu.cpu.cfs_period_us`为`100000`（单位微妙，即0.1秒），`cpu.cfs_quota_us`为`10000`（单位微妙，即`0.01`秒）时，`resources.limits.cpu`为0.1（或100m），即0.1个`cpu`核心。

## pod的内存控制组解析

与`cpu`不同，`k8s`里`pod`容器的`requests.memory`在控制组内没有对应的属性，未起到限制作用，只是协助`k8s`调度计算。
而`pod`容器的`limits.memory`对应控制组里的`memory.limit_in_bytes`值。

## 总结

1. `k8s`基于`pod`管理控制组，同一`pod`内的容器所属同一控制组，并且每个控制组内包含一个`infra`沙箱容器

2. `k8s`基于`.spec.containers[x].resources`对`pod`划分了三种类型，对应控制组路径如下:

| Pod类型      | 描述                          | 控制组                                                                                                        |
|:----------:|:---------------------------:|:----------------------------------------------------------------------------------------------------------:|
| Guaranteed | 内存与CPU设置了相同的requests和limits | /sys/fs/cgroup/<subsystem>/kubepods.slice/kubepods-pod<pod uid>.slice                                      |
| Burstable  | 至少有一个容器设置了CPU或内存的requests属性 | /sys/fs/cgroup/<subsystem>/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod<pod uid>.slice   |
| BestEffort | 所有容器均未设置requests和limits         | /sys/fs/cgroup/<subsystem>/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod<pod uid>.slice |


3. 控制组中`cpu.shares`对应`k8s`内的`resources.requests.cpu`字段，值对应关系为：

```
resources.requests.cpu * 1024 = cpu.shares
```

4. 控制组中`cpu.cpu.cfs_period_us`、`cpu.cfs_quota_us`对应`k8s`中的`resources.limits.cpu`字段，值对应关系为：

```
resources.limits.cpu = cpu.cfs_quota_us/cpu.cfs_period_us
```

5. 控制组里的`memory.limit_in_bytes`对应`k8s`中的`resources.limits.memory`值

## 参考文章

- [Kubernetes生产实践系列之三十：Kubernetes基础技术之集群计算资源管理](https://blog.csdn.net/cloudvtech/article/details/107634724)
- [Understanding resource limits in kubernetes: cpu time](https://medium.com/@betz.mark/understanding-resource-limits-in-kubernetes-cpu-time-9eff74d3161b)