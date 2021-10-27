## 禁用userland代理

### 描述

当容器端口需要被映射时，`Docker`守护进程都会启动用于端口转发的`userland-proxy`方式。如果使用了`DNAT`方式，该功能可以被禁用

### 隐患分析

`Docker`引擎提供了两种机制将主机端口转发到容器,`DNAT`和`userland-proxy`。
在大多数情况下，`DNAT`模式是首选，因为它提高了性能，并使用本地`Linux iptables`功能而需要附加组件。
如果`DNAT`可用，则应在启动时禁用`userland-proxy`以减少安全风险。

### 审计方法

```shell script
$ ps -ef|grep dockerd
或
$ cat /etc/docker/daemon.json|grep userland-proxy
```

确保`userland-proxy`配置为`false`

### 修复建议

> 编辑文件

```shell script
$ mkdir -p /etc/docker/
$ vi /etc/docker/daemon.json
```

添加如下内容

```
"userland-proxy": false,
```

> 重载服务

```shell script
$ systemctl daemon-reload
$ systemctl restart docker
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)