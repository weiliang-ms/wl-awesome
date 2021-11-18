# k8s下cgroups管理

`k8s`对`cgroups`的管理是通过`kubelet`组件完成的，涉及的`cgroups`分类如下：

1. 组件级`cgroups`:
- 容器运行时控制组：`--runtime-cgroups`
- 


## 1.组件级cgroups

### 容器运行时cgroups

