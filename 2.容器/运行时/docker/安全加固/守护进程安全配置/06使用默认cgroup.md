## 使用默认cgroup

### 描述

查看`--cgroup-parent`选项允许设置用于所有容器的默认`cgroup parent`。 如果没有特定用例,则该设置应保留默认值。

### 隐患分析

系统管理员可定义容器应运行的`cgroup`。 若系统管理员没有明确定义`cgroup`，容器也会在`docker cgroup`下运行。
应该监测和确认使用情况。通过加到与默认不同的`cgroup`，导致不合理地共享资源，从而可能会主机资源耗尽

### 审计方式

```shell script
$ ps -ef|grep dockerd
```

确保`--cgroup-parent`参数未设置或设置为适当的非默认`cgroup`

### 修复建议

如无特殊需求，默认值即可

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)