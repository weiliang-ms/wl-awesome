{% raw %}
## Dockerfile指定USER

### 描述

为容器镜像的`Dockerfile`中的容器创建非`root`用户

### 隐患分析

如果可能，指定非`root`用户身份运行容器是个很好的做法。
虽然用户命名空间映射可用，但是如果用户在容器镜像中指定了用户，则默认情况下容器将作为该用户运行，并且不需要特定的用户命名空间重新映射。

### 审计方式

```shell script
[root@localhost ~]# docker ps |grep ccc|awk '{print $1}'|xargs -n1 docker inspect --format='{{.Id}}:User={{.Config.User}}'
4e53c86daf89a1bac0ed178d043663d2af162ca813ff17864ebdb964d8233459:User=
```

上述命令应该返回容器用户名或用户`ID`。 如果为空，则表示容器以`root`身份运行

### 修复建议

确保容器镜像的`Dockerfile`包含以下指令：`USER <用户名或 ID>`
其中用户名或`ID`是指可以在容器基础镜像中找到的用户。 如果在容器基础镜像中没有创建特定用户，则在`USER`指令之前添加`useradd`命令以添加特定用户。
例如，在`Dockerfile`中创建用户：
```
RUN useradd -d /home/username -m -s /bin/bash username USER username
```

**注意:** 如果镜像中有容器不需要的用户，请考虑删除它们。
删除这些用户后，提交镜像，然后生成新的容器实例以供使用。

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)

{% endraw %}