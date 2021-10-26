## 在Dockerfile中使用COPY而不是ADD

### 描述

在`Dockerfile`中使用`COPY`指令而不是`ADD`指令

### 隐患分析

`COPY`指令只是将文件从本地主机复制到容器文件系统。
`ADD`指令可能会从远程`URL`下载文件并执行诸如解包等操作。
因此，`ADD`指令增加了从`URL`添加恶意文件的风险

### 审计

步骤 1：运行以下命令获取镜像列表

```shell script
$ docker images
```

步骤 2：对上述列表中的每个镜像执行以下命令，并查找任何`ADD`指令：

```
for i in `docker images --quiet`;do
docker history $i |grep ADD > /dev/null
if [ $? -eq 0 ];then
    echo "imageID: $i has 'ADD' direct..."
fi
done
```

### 修复建议

在`Dockerfile`中使用`COPY`指令

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)