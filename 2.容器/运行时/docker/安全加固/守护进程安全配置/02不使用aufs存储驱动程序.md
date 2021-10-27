## 不使用aufs存储驱动程序

### 描述

`aufs`存储驱动程序是较旧的存储驱动程序。 它基于`Linux`内核补丁集，不太可能合并到主版本`Linux`内核中。
`aufs`驱动会导致一些严重的内核崩溃。`aufs`在`Docker`中只是保留了历史遗留支持,现在主要使用`overlay2`和`devicemapper`。
而且最重要的是，在许多使用最新`Linux`内核的发行版中，`aufs`不再被支持

### 审计方式

```bash
[root@node105 ~]# docker info |grep  "Storage Driver:"
 Storage Driver: overlay2
```

### 修复建议

默认安装情况下存储驱动为`overlay2`，避免使用`aufs`作为存储驱动

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)