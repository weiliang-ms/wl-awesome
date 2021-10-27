## 只有受信任的用户才能控制Docker守护进程

### 描述

`Docker`守护进程需要`root`权限。对于添加到`Docker`组的用户，
为其提供了完整的`root`访问权限。

### 隐患分析

`Docker`允许在宿主机和访客容器之间共享目录，而不会限制容器的访问权限。
这意味着可以启动容器并将主机上的`/`目录映射到容器。
容器将能够不受任何限制地更改您的主机文件系统。 简而言之，这意味着您只需作为`Docker`组的成员即可获得较高的权限，然后在主机上启动具有映射`/`目录的容器。

### 审计方式

```bash
[root@localhost ~]# yum install glibc-common -y -q
[root@localhost ~]# getent group docker
docker:x:994:
```

- 结果判定

查看`审计`步骤中的返回值是否含有非信任用户

### 修复建议

从`docker`组中删除任何不受信任的用户。另外，请勿在主机上创建敏感目录到容器卷的映射

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)