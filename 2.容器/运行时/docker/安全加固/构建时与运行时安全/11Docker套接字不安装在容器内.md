{% raw %}
## Docker套接字不安装或挂载到容器内

### 描述

`docker socket`不应该安装在容器内

### 隐患分析

如果`Docker`套接字安装在容器内，它将允许在容器内运行的进程执行`Docker`命令，这有效地允许完全控制主机

### 审计方式

```shell script
[root@localhost ~]# docker ps --quiet | xargs docker inspect --format='{{.Id}}:Volumes={{.Mounts}}'|grep docker.sock
```

上述命令将返回`docker.sock`作为卷映射到容器的任何实例

### 修复建议

确保没有容器将`docker.sock`作为卷挂载

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)

{% endraw %}