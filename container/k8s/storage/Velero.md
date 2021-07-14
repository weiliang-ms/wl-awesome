# Velero

基于`v1.6`

## 介绍

`Velero`（以前叫`Heptio Ark`）提供了备份和恢复`Kubernetes`集群资源和持久卷的工具。

`Velero`主要功能如下：

- 备份`k8s`集群，并在集群丢失时恢复
- 迁移`k8s`集群资源至另一个集群
- 将生产集群复制到开发和测试集群

`Velero`组件:

- 服务端：运行于`k8s`集群内部
- 客户端：`cli`工具

## 工作原理

每个`Velero`操作（按需备份、定时备份、还原）都是一个自定义资源，由`Kubernetes`自定义资源定义（`CRD`）定义并存储在`etcd`中。
`Velero`还包括处理自定义资源以执行备份、恢复和所有相关操作的控制器。

可以备份或还原群集中的所有对象，也可以按类型、命名空间和/或标签筛选对象。

`Velero`非常适合于灾难恢复用例，以及在集群上执行系统操作（如升级）之前对应用程序状态进行快照

### 按需备份

备份操作包括：

- 将复制的`Kubernetes`对象上传到云对象存储中
- 调用云提供程序`API`以生成持久卷的磁盘快照（如果指定）

您可以选择指定备份期间要执行的备份`hook`。
例如，在拍摄快照之前，您可能需要通知数据库将其内存缓冲区刷新到磁盘。

请注意，群集备份并不是严格的原子备份。
如果备份时正在创建或编辑`Kubernetes`对象，则备份中可能不包括这些对象。
捕捉不一致信息的几率很低，但这是可能的

### 定时备份

定时备份操作允许您定期备份数据。

第一次备份是在第一次创建计划时执行的，随后的备份将按计划的指定间隔进行。这些间隔由`Cron`表达式指定。

定时备份以名称`<SCHEDULE name>-<TIMESTAMP>`保存，其中`<TIMESTAMP>`的格式为`YYYYMMDDhhmmss`

### 数据恢复/还原

还原操作允许您从以前创建的备份还原所有对象和持久卷。也可以仅还原对象和持久卷的筛选子集。

`Velero`支持多个命名空间重新映射—例如:
- 命名空间`abc`中的对象可以在命名空间`def`下重新创建
- 命名空间`123`中的对象可以在`456`下重新创建

还原的默认名称是`<BACKUP name>-<TIMESTAMP>`，其中`<TIMESTAMP>`的格式为`YYYYMMDDhhmmss`。也可以指定自定义名称。
还原的对象还包括一个带有键`velero.io/restore-name`和值`<restore name>`的标签。

默认情况下，以读写模式创建备份存储位置。
但是，在还原过程中，可以将备份存储位置配置为只读模式，这将禁用存储位置的备份创建和删除。
这有助于确保在还原场景中不会无意中创建或删除备份。

您可以选择指定要在还原期间或资源还原之后执行的还原`hook`。
例如，您可能需要在启动数据库应用程序容器之前执行自定义数据库还原操作。

### 备份操作流程

当你执行`velero backup create test-backup`时：

- `Velero`客户端调用`kubernetes api`服务来创建备份对象
- `BackupController`控制器发现新的备份对象并对其执行验证
- `BackupController`控制器开始备份过程。它通过查询`API`服务的资源来收集要备份的数据。
- `BackupController`调用对象存储服务（例如，`AWS S3`）来上载备份文件

默认情况下，`velero backup create`为任何持久卷创建磁盘快照。
您可以通过指定其他标志来调整快照。运行`velero backup create--`帮助查看可用标志。
可以使用选项`--snapshot volumes=false`禁用快照。

![](images/velero-backup-process.png)

### 备份的API版本
    
`Velero`为每个组/资源使用`Kubernetes API`服务器的首选版本备份资源。
还原资源时，目标群集中必须存在相同的`API`组/版本才能成功还原。

例如，如果要备份的集群在`things API`组中有一个`gizmos`资源，
其中包含`group/versions things/v1alpha1`、`things/v1beta1`和`things/v1`，
并且服务器的首选组/版本是`things/v1`，那么将从`things/v1api`端点备份所有`gizmos`。
还原此群集的备份时，目标群集必须具有`things/v1`端点才能还原`gizmo`。
注意，`things/v1`不需要是目标集群中的首选版本；它只需要存在。

### 配置备份过期时间

创建备份时，可以通过添加标志`--TTL<DURATION>`来指定`TTL`（生存时间）。
如果`Velero`发现现有备份资源已过期，它将删除：

- 备份资源对象
- 来自云对象存储的备份文件
- 所有`PersistentVolume`快照
- 所有相关恢复数据

`TTL`标志允许用户使用以小时、分钟和秒为单位的值指定备份保留期，
格式为`TTL 24h0m0s`。如果未指定，将应用默认的`TTL`值`30`天。
    
    
### 同步对象存储与集群的备份信息
    
`Velero`会不断检查是否始终存在正确的备份资源。
如果存储桶中有格式正确的备份文件，但`Kubernetes API`中没有相应的备份资源，
则`Velero`会将对象存储中的信息同步到`Kubernetes`。

这使得恢复功能可以在群集迁移场景中工作，其中新群集中不存在原始备份对象。

同样，如果备份对象存在于`Kubernetes`中，但不在对象存储中，
那么它将从`Kubernetes`中删除，因为备份`tarball`不再存在。

## 安装Velero

### 基础安装

> 安装环境要求

- `k8s`主节点
- `kubectl`可用

`Velero`使用对象存储来存储备份和相关的工件。它还可以选择与受支持的块存储系统集成以快照持久卷。
在开始安装过程之前，应该从兼容提供程序列表中标识要使用的对象存储提供程序和可选块存储提供程序。

> 安装cli工具

下载[velero-v1.6.1-linux-amd64.tar.gz](https://github.com/vmware-tanzu/velero/releases/download/v1.6.1/velero-v1.6.1-linux-amd64.tar.gz)

解压安装

    
  

  
