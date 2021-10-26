## 设置/etc/docker目录所有权为root:root

### 描述

验证`/etc/docker`目录所有权和组所有权是否正确设置为`root:root`

### 隐患分析

除了各种敏感文件之外，`/etc/docker`目录还包含证书和密钥。
因此，它应该由`root:root`拥有和归组来维护目录的完整性。

### 审计方式

```shell script
[root@localhost ~]# stat -c %U:%G /etc/docker
root:root
```

### 修复建议

若所属用户非`root:root`，修改授权
```shell script
$ chown root:root /etc/docker
```

## 设置/etc/docker目录权限为755或更多限制性

### 描述

验证`/etc/docker`目录权限是否正确设置为`755`

### 隐患分析

除了各种敏感文件之外，`/etc/docker`目录还包含证书和密钥。
因此，它应该由`root:root`拥有和归组来维护目录的完整性。

### 审计方式

```shell script
[root@localhost ~]# stat -c %a /etc/docker
755
```

### 修复建议

若所属用户非`root:root`，修改授权
```shell script
$ chmod 755 /etc/docker
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)