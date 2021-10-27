## 应用守护进程范围的自定义seccomp配置文件

### 描述

如果需要，您可以选择在守护进程级别自定义`seccomp`配置文件，并覆盖`Docker`的默认`seccomp`配置文件

### 隐患分析

大量系统调用暴露于每个用户级进程，其中许多系统调用在整个生命周期中都未被使用。
大多数应用程序不需要所有的系统调用，因此可以通过减少可用的系统调用来增加安全性。
可自定义`seccomp`配置文件，而不是使用`Docker`的默认`seccomp`配置文件。
如果`Docker`的默认配置文件够用的话，则可以选择忽略此建议

### 审计

```shell script
[root@localhost ~]# docker info --format '{{.SecurityOptions}}'
```

### 修复建议

错误配置的`seccomp`配置文件可能会中断的容器运行。`Docker`默认的策略兼容性很好，可以解决一些基本的安全问题。
所以，在[重写默认值](https://docs.docker.com/engine/security/seccomp/) 时，你应该非常小心

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)