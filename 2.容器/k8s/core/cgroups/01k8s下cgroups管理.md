# k8s下cgroups管理

`k8s`对`cgroups`的管理是通过`kubelet`组件完成的，涉及的`cgroups`分类如下：

1. 组件级`cgroups`:
- 容器运行时控制组：`--runtime-cgroups`
- 

## 1.组件级cgroups

### 容器级资源控制

默认情况下，容器可以无限制地使用主机的cpu资源，可以通过设置参数来进行限制。一般都采用Linux默认的CFS调度法，当然也可以使用实时调度。CFS调度可以使用如下参数来进行限制：

常用指标：

1. `cpu.cfs_period_us`：指定`cpu CFS`的周期，通常和`--cpu-quota`一起使用，单位是`us`，默认值是`100`毫秒
2. `cpu.cfs_quota_us`：指定容器在一个`cpu CFS`调度周期中可以使用`cpu`的时间，单位是`us`。默认不限制
3. `memory.limit_in_bytes`: 内存使用量，默认不限制

### pod级资源控制

pod级cgroup + QoS

- Guaranteed （该策略下，设置的requests 等于 limits）
- Burstable（该策略下，设置的requests 小于 limits）
- BestEffort（该策略下，没有设置requests 、 limits）

当某个node内存被严重消耗时，BestEffort策略的pod会最先被kubelet杀死，
其次Burstable（该策略的pods如有多个，也是按照内存使用率来由高到低地终止）， 再其次Guaranteed。

### Node级别资源控制

> kubelet会将所有的pod都创建一个kubepods的cgroup下，通过该cgroup来限制node上运行的pod最大可以使用的资源

如：/sys/fs/cgroup/cpu/kubepods.slice/

该cgroup的资源限制取值为: ${Node Capacity} - ${Kube-Reserved} - ${System-Reserved}，
即：节点总配额 - K8s预留 - 系统服务预留

${Allocatable} = ${Node Capacity} - ${Kube-Reserved} - ${System-Reserved} - ${Hard-Eviction-Threshold}

即：pod可申请资源配额 = 节点总配额 - K8s预留 - 系统服务预留 - 驱逐低优先级pod的阈值

其中kube-reserved是为kubernetes组件提供的资源预留，system-reserved是为系统组件预留的资源，
分别通过--kube-reserved, --system-reserved来指定，例如--kube-reserved=cpu=100m,memory=100Mi

{Hard-Eviction-Threshold}为在资源紧张的时候`kubelet`主动驱逐低优先级pod的阈值

### 组件级资源控制


