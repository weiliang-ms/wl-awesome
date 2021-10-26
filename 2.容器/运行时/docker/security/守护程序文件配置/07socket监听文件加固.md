## 设置docker.sock文件所有权为root:docker

### 描述

验证`docker.sock`文件由`root`拥有，而用户组为`docker`。

### 隐患分析

`Docker`守护进程以`root`用户身份运行。 因此，默认的`Unix`套接字必须由`root`拥有。
如果任何其他用户或进程拥有此套接字，那么该非特权用户或进程可能与`Docker`守护进程交互。
另外，这样的非特权用户或进程可能与容器交互，这样非常不安全。
另外，`Docker`安装程序会创建一个名为`docker`的用户组。
可以将用户添加到该组，然后这些用户将能够读写默认的`Docker Unix`套接字。
`docker`组成员由系统管理员严格控制。 如果任何其他组拥有此套接字，那么该组的成员可能会与`Docker`守护进程交互。。
因此，默认的`Docker Unix`套接字文件必须由`docker`组拥有权限，以维护套接字文件的完整性

### 审计

```shell script
[root@localhost ~]# stat -c %U:%G /var/run/docker.sock
root:docker
```

### 修复建议

若所属用户非`root:docker`，修改授权
```shell script
$ chown root:docker /var/run/docker.sock
```

## 设置docker.sock文件权限为660或更多限制性

### 描述

验证`docker`套接字文件是否具有`660`或更多限制的权限

### 隐患分析

只有`root`和`docker`组的成员允许读取和写入默认的`Docker Unix`套接字。
因此，`Docker`套接字文件必须具有`660`或更多限制的权限

### 审计

```shell script
[root@localhost ~]# stat -c %a /var/run/docker.sock
660
```

### 修复建议

若权限非`660`，修改授权
```shell script
$ chmod 660 /var/run/docker.sock
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)