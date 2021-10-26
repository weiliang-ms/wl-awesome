## 设置docker.socket文件的所有权为root:root

### 描述

验证`docker.socket`文件所有权和组所有权是否正确设置为`root`

### 隐患分析

`docker.socket`文件包含可能会改变`Docker`远程`API`行为的敏感参数。
因此，它应该拥有`root`权限，以保持文件的完整性。

### 审计方式

```shell script
systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 ls -l
```

返回值应为

```
-rw-r--r-- 1 root root 197 Mar 10  2020 /usr/lib/systemd/system/docker.socket
```

### 修复建议

若所属用户非`root:root`，修改授权
```shell script
$ systemctl show -p FragmentPath docker.socket|sed "s/FragmentPath=//"|xargs -n1 chown root:root
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)