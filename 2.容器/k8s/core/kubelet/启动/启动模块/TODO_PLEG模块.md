## PLEG模块解析

基于`kubernetes v1.18.6`

`PLEG`(`Pod Lifecycle Event Generator`) 通过`CRI`接口轮询容器状态，然后与内存中的容器状态做比对，并发送相应事件。

`PLEG`是`kubelet`的核心模块,`PLEG`会周期性调用`container runtime`获取本节点`containers/sandboxes`的信息，
并与自身维护的`pods cache`信息进行对比，生成对应的`PodLifecycleEvent`，
然后输出到`eventChannel`中，通过`eventChannel`发送到`kubelet syncLoop`进行消费，
然后由`kubelet syncPod`来触发`pod`同步处理过程，最终达到用户的期望状态。

![](images/pleg.jpg)

