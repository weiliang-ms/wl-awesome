# redis-operator

[项目地址](https://ot-container-kit.github.io/redis-operator/guide/)

## redis-operator是什么

`redis-operator`负责在`Kubernetes`之上建立独立的`redis`和集群模式。它可以基于云环境或裸金属环境创建一个`redis`集群，并基于最佳实践设置。此外，通过集成`redis-export`提供了内置的监控功能。

## 特性列表

`redis-operator`具备以下特性：

- `redis`单机、集群模式创建
- `redis`集群故障转移及恢复
- 内置`prometheus exporter`
- 动态存储模板支持
- 配额设置
- `redis`密码/无密码
- 发布节点选择、亲和性设置
- 优先级管理（pod服务质量）
- 内核参数设置

这看起来跟使用`helm`安装`redis cluster`并无太大差别，那它是否有额外特性呢？


## 架构

![](images/redis-operator-architecture.png)

## 部署

演示环境信息：

- CentOS7
- 5.10.2-1.el7.elrepo.x86_64
- Kubernetes v1.21.5

接下来我们部署`redis-operator`，并通过`redis-operator`维护`redis`:

1. 下载`redis-operator chart`



