# Kubernetes v1.22 alpha特性: 支持使用交换内存

`Author: Elana Hashman (Red Hat)`

`1.22`版本引入了一个`alpha`特性支持: `Kubernetes`工作负载可以配置使用`node`节点上的交换内存

在之前版本中，`Kubernetes`不支持在`Linux`上使用交换内存，因为当涉及内存交换时，很难描述`pod`内存的使用情况。
并且如果在一个节点上检测到交换分区，该节点上的`kubelet`默认情况下将无法启动。

但是，交换内存有许多[使用场景](https://github.com/kubernetes/enhancements/blob/9d127347773ad19894ca488ee04f1cd3af5774fc/keps/sig-node/2400-node-swap/README.md#user-stories) 
，并且可以改进节点稳定性、更好地支持具有高内存开销但工作集较小的应用程序、使用内存受限的设备和内存灵活性。

因此，在过去的两个版本中，`SIG Node`(k8s社区Node方向的兴趣小组)一直在收集关于交换内存的使用场景与社区反馈建议。
并提出了一种以可控的、可预测的方式向节点添加交换内存（swap）支持的设计，
以便`Kubernetes`用户可以进行测试`swap`并提供测试数据，从而可以基于具有`swap`的运行时构建集群功能。

对`swap`支持的第一个里程碑，便是该特性`alpha`阶段毕业。

## 初衷

`swap`有两种不同类型的用户，它们可能会重叠:
- 节点管理员: 他们可能希望交换可用来进行节点级性能调优和稳定性/减少`嘈杂的邻居`问题
- 应用程序开发人员: 他们编写的应用程序将从使用交换内存中受益

## 用户故事

### 通过使用swap提高系统稳定性

`Cgroupsv2`改进的内存管理算法，如`oomd`，强烈推荐使用`swap`。因此，在节点上使用少量的交换可以改善更好的资源压力处理和恢复.

- [systemd-oomd.service](https://man7.org/linux/man-pages/man8/systemd-oomd.service.8.html)
- [cgroup-v2](https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html#id1)
- []()

节点的`swap`配置通过[KubeletConfiguration](https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/) 中的`memorySwap`字段对集群管理员可见

作为集群管理员，您可以通过设置`memorySwap.swapBehavior`来指定`swap`使用限制。

`kubelet`通过向容器运行时接口(CRI)添加`memory_swap_limit_in_bytes`字段，
实现容器对`swap`的使用限制，然后容器运行时将`swap`设置写入容器级别`cgroup`

## 使用方式

> step1: `kubelet`开启该特性

```shell
--feature-gates="...,NodeMemorySwap=true"
```

> step2: `failSwapOn`配置为`false`

`/var/lib/kubelet/config.yaml`

```yaml
...
failSwapOn: false
...
```

> step3: 配置`swap`使用限制(可选)

`/var/lib/kubelet/config.yaml`

```yaml
...
memorySwap:
  swapBehavior: LimitedSwap
...
```

`memorySwap.swapBehavior`可选值

- `LimitedSwap`(default): `Kubernetes`工作负载可以使用多少交换是有限的，工作负载使用的内存、交换内存总和 <= 工作负载的`resource.limits.memory`值
- `UnlimitedSwap`: `Kubernetes`工作负载可以根据请求使用尽可能多的交换内存，直到达到系统`swap`最大限制


---
`LimitedSwap`设置的行为取决于节点运行的是`v1`还是`v2`的控制组(即`cgroups`):

- `cgroups v1`: `Kubernetes`工作负载可以使用多少交换是有限的，工作负载使用的内存、交换内存总和 <= 工作负载的`resource.limits.memory`值.
- `cgroups v2`: `swap`的配置独立于内存，因此，在这种情况下，容器运行时可以将`memory.swap.max`设置为`0`，并且不允许使用交换

当`memorySwap.swapBehavior`设置为`UnlimitedSwap`时
