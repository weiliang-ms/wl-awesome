# Argo CD

![](images/argo.png)

## 简介

> `Argo CD`是什么？

`Argo CD`是一个基于`Kubernetes`声明性的`GitOps`持续交付工具

> 为什么使用`Argo CD`

- 声明式定义应用程序、配置和环境，并且是版本控制的

- 应用程序部署和生命周期管理是自动化的、可审计的和易于理解的

> 工作原理

`Argo CD`遵循`GitOps`模式，使用`Git`存储库作为定义应用程序期望状态的数据源。
`Kubernetes`应用清单可以通过以下几种方式指定:

- [kustomize应用](https://kustomize.io/)
- [helm应用](https://helm.sh/)
- [ksonnet应用](https://ksonnet.io/)
- [jsonnet](https://jsonnet.org/)
- 带有`yaml`|`json`清单的目录
- 任意自定义配置管理工具|插件

`Argo CD`可以在指定的目标环境中自动部署、维护期望的应用程序状态，该期望状态由清单文件定义。
应用程序清单版本可以基于`Git`提交时跟踪对分支、`tag`或固定到特定版本的`Git commit`。  

`Argo CD`基于`kubernetes`控制器实现，它持续监控运行中的应用程序，
并将当前的活动状态与期望的目标状态(如`Git repo`中所指定的)进行比较。
如果已部署的应用程序的活动状态偏离目标状态，则将被视为`OutOfSync`。
`Argo CD`可视化展现程序状态差异，同时提供自动或手动同步工具。

> 特性

- 将应用程序自动部署到指定的目标环境
- 支持多种应用配置管理工具/模板（`Kustomize, Helm, Ksonnet, Jsonnet, plain-YAML`）
- 能够管理和部署到多个`k8s`集群
- 单点登录（`OIDC, OAuth2, LDAP, SAML 2.0, GitHub, GitLab, Microsoft, LinkedIn`）
- 用于授权的多租户和`RBAC`策略
- 回滚至`Git`仓库中指定的`commit`
- 应用程序资源的运行状况分析
- 自动配置漂移检测和可视化
- 自动/手动同步应用至期望状态
- 提供应用程序活动的实时视图的`Web UI`
- 用于自动化和`CI`集成的`CLI`
- `Webhook`集成(`GitHub, BitBucket, GitLab`)
- `PreSync, Sync, PostSync`钩子来支持复杂应用(例如蓝/绿和金丝雀的升级)
- 应用程序事件审计和追踪`API`调用
- `Prometheus`指标
- 覆盖`Git`中`ksonnet/helm`的参数
    


    

   


  



  

  





    

  




