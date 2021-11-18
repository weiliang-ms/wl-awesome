# 深入探究kubernetes弃用dockershim

## 关于弃用dockershim的快速问答


> 为什么kubernetes要弃用dockershim？

首先，先了解下`dockershim`是什么。

`dockershim`是`kubelet`内的一个组件，主要目的是为了通过其操作`Docker`来管理容器。




- [Dockershim Deprecation FAQ](https://kubernetes.io/blog/2020/12/02/dockershim-faq/)
- [Don't Panic: Kubernetes and Docker](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/)