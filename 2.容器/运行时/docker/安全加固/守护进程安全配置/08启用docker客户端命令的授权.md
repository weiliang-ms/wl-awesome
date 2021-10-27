## 启用docker客户端命令的授权

### 描述

使用本机`Docker`授权插件或第三方授权机制与`Docker`守护程序来管理对`Docker`客户端命令的访问。

### 隐患分析

`Docker`默认是没有对客户端命令进行授权管理的功能。
任何有权访问`Docker`守护程序的用户都可以运行任何`Docker`客户端命令。
对于使用`Docker`远程`API`来调用守护进程的调用者也是如此。
如果需要细粒度的访问控制，可以使用授权插件并将其添加到`Docker`守护程序配置中。
使用授权插件，`Docker`管理员可以配置更细粒度访问策略来管理对`Docker`守护进程的访问。
`Docker`的第三方集成可以实现他们自己的授权模型，以要求`Docker`的本地授权插件
（即`Kubernetes`，`Cloud Foundry`，`Openshift`）之外的`Docker`守护进程的授权。

### 审计方式

```shell script
$ ps -ef|grep dockerd
或
$ cat /etc/docker/daemon.json|grep userland-proxy
```

如果使用`Docker`本地授权，可使用`--authorization-plugin`参数加载授权插件。

### 修复建议

如无特殊需求，默认值即可

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)