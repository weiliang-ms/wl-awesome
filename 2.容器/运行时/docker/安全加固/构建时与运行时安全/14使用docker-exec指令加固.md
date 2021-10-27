## docker exec命令不能使用特权选项

### 描述

不要使用`--privileged`选项来执行`docker exec`

### 隐患分析

在`docker exec`中使用`--privileged`选项可为命令提供扩展的`Linux`功能。这可能会造成不安全的情况

### 修复建议

在`docker exec`命令中不要使用`--privileged`选项

## docker exec命令不能与user选项一起使用

### 描述

不要使用`--user`选项执行`docker exec`

### 隐患分析

在`docker exec`中使用`--user`选项以该用户身份在容器内执行该命令。这可能会造成不安全的情况。
例如，假设你的容器是以`tomcat`用户（或任何其他非`root`用户）身份运行的，
那么可以使用`--user=root`选项以`root`用户身份运行命令，这是非常危险的

### 修复建议

在`docker exec`命令中不要使用`--user`选项

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)