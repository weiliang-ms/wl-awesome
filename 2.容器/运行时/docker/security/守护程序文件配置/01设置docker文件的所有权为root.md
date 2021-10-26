## 设置docker文件的所有权为root:root

### 隐患分析

`docker.service`文件包含可能会改变`Docker`守护进程行为的敏感参数。
因此，它应该由`root`拥有和归属，以保持文件的完整性。

### 审计方式

```shell script
$ systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 ls -l
```

返回值应为

```
-rw-r--r-- 1 root root 1157 Apr 26 08:04 /etc/systemd/system/docker.service
```

### 修复建议

若所属用户非`root:root`，修改授权
```shell script
$ systemctl show -p FragmentPath docker.service|sed "s/FragmentPath=//"|xargs -n1 chown root:root
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)