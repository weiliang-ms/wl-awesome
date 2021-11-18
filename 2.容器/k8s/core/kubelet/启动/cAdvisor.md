## cAdvisor

[cAdvisor](https://github.com/google/cadvisor) 是一个容器资源使用和性能分析的开源项目

它是专门为容器构建的，并且原生支持`Docker`容器。在`Kubernetes`中，`cadvisor`被集成到`Kubelet`二进制中。
`cAdvisor`自动发现机器中的所有容器，并收集`CPU`、内存、文件系统和网络使用统计信息。

`Kubelet`充当了`Kubernetes`控制节点和工作节点之间的桥梁。
它管理机器上运行的`pod`和容器。`Kubelet`将每个`pod`转换为容器组，并从`cAdvisor`获取单个容器的使用统计信息。
然后通过`REST API`发布聚合的`pod`资源使用统计信息。

可以浏览以下优秀文章，了解更多关于`cAdvisor`

- [Resource Usage Monitoring in Kubernetes](https://kubernetes.io/blog/2015/05/resource-usage-monitoring-kubernetes/)
- [容器监控实践—cAdvisor](https://www.jianshu.com/p/91f9d9ec374f)
