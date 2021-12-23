# kubelet模块

1.`PLEG`模块

`PLEG`，即`Pod Lifecycle Event Generator`。
其维护着存储`Pod`信息的`cache`，从运行时获取容器的信息，并根据前后两次信息对比，
生成对应的`PodLifecycleEvent`，通过`eventChannel`发送到`kubelet syncLoop`进行消费，最终由`kubelet syncPod`完成`Pod`的同步，维护着用户的`期望`。

![](images/pleg.jpg)

2. `CAdvisor`模块

集成在`Kubelet`中的容器监控工具，用于收集本节点和容器的监控信息。

3. 

