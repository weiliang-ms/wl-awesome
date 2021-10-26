## 设置docker.service文件权限为644或更多限制性

### 描述

验证`docker.service`文件权限是否正确设置为`644`或更多限制

### 隐患分析

`docker.service`文件包含可能会改变`Docker`守护进程行为的敏感参数。
因此，它应该由`root`拥有和归属，以保持文件的完整性。

### 审计方式

```shell script
[root@localhost ~]# systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 stat -c %a
644
```

### 修复建议

若权限非`644`，修改授权
```shell script
$ systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 chmod 644
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)