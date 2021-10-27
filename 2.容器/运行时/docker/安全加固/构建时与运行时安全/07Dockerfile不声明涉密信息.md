## Dockerfile不声明涉密信息

### 描述

不要在`Dockerfile`中存储任何涉密信息

### 隐患分析

通过使用`Docker`历史命令，可以查看各种工具和实用程序。
通常情况，镜像发布者提供`Dockerfile`来构建镜像。所以，`Dockerfile`中的涉密信息可能会被暴露并被恶意利用。

### 审计方式

第 1 步：运行以下命令以获取镜像列表：

```shell script
$ docker images
```
第 2 步：对上面列表中的每个镜像运行以下命令，并查找是否有涉密信息：

```shell script
$ docker history <imageID>
```

如果有权访问镜像的`Dockerfile`，请确认没有涉密信息（不应该有涉密的信息，如用户账号，私钥证书等。）

### 修复建议

不要在`Dockerfile`中存储任何类型的涉密信息

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)