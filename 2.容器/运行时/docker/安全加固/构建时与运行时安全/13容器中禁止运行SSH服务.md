## 容器中禁止运行SSH服务

### 描述

`SSH`服务不应该在容器内运行

### 隐患分析

在容器内运行`SSH`可以增加安全管理的复杂性
难以管理`SSH`服务器的访问策略和安全合规性
难以管理各种容器的密钥和密码
难以管理`SSH`服务器的安全升级
可以在不使用`SSH`情况下对容器进行`shell`访问，避免不必要地增加安全管理的复杂性。

### 审计方式

```shell script
for i in `docker ps --quiet`;do
docker exec $i ps -el|grep sshd >/dev/null
if [ $? -eq 0 ]; then
    echo "container : $i run sshd..."
fi
done
```

返回值如下，说明下面几个容器内部运行`ssh`服务

```shell script
container : 0781479bef1b run sshd...
container : fea9d4d5708a run sshd...
container : 38bb65479056 run sshd...
container : 212fec812c01 run sshd...
```

### 修复建议

卸载容器内部`ssh`服务或重新构建不含有`ssh`的镜像，运行容器

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)