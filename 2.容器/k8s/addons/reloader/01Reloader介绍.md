# Reloader项目介绍

## 项目信息

- [项目地址](https://github.com/stakater/Reloader)
- `LICENSE`: `Apache 2.0`

## 项目介绍

以下内容翻自项目`README.md`

### Reloader是什么？

有些时候，我们需要监控`k8s`中`ConfigMap`和/或`Secret`变化。
当配置发生变更，需滚动升级相关`Deployment、Daemonset、Statefulset`以便重新加载配置。

而`Reloader`便是以上需求的一个具体实现，`Reloader`基于`kubernetes 1.9`。

### 对比k8s-trigger-controller

`Reloader`和`k8s`触发器控制器都是为了相同的目的而构建的。所以它们之间有很多相似和不同之处。

- 共同点：
  - 两者均支持检测`ConfigMap`与`Secret`变更
  - 两者均支持`Deployment`滚动更新
  - 两者均使用`SHA1`进行哈希
  - 两者均有端到端的单元测试用例

- 不同点：
  - `k8s-trigger-controller`不支持`StatefulSet`与`DaemonSet`类型滚动更新，而`Reloader`支持
  - `k8s-trigger-controller`将哈希值存于注释中(`trigger.k8s.io/[secret|configMap]-NAME-last-hash`)
而`Reloader`将哈希值存于环境变量中（`STAKATER_NAME_[SECRET|CONFIGMAP]`）
  - `k8s-trigger-controller`限制使用哈希值（`trigger.k8s.io/[secret|configMap]-NAME-last-hash`），而`Reloader`可定制化更强。

