{% raw %}
## 镜像添加HEALTHCHECK

### 描述

在`Docker`容器镜像中添加`HEALTHCHECK`指令以对正在运行的容器执行运行状况检查。

### 安全出发点

安全性最重要的一个特性就是可用性。将`HEALTHCHECK`指令添加到容器镜像可确保`Docker`引擎定期检查运行的容器实例是否符合该指令，
以确保实例仍在运行。根据报告的健康状况，`Docker`引擎可以退出非工作容器并实例化新容器。

### 审计

运行以下命令，并确保`Docker`镜像对`HEALTHCHECK`指令设置

```shell script
[root@localhost ~]# docker inspect --format='{{.Config.Healthcheck}}' 8a2fb25a19f5
<nil>
```

应当返回设置值而非`nil`

### 修复建议

按照`Docker`文档，并使用`HEALTHCHECK`指令重建容器镜像。

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)

{% endraw %}