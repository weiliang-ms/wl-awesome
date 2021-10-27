## 将卷权限和所有权更改委托给CSI驱动程序

[delegating-volume-permission-and-ownership-change-to-csi-driver](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#delegating-volume-permission-and-ownership-change-to-csi-driver)

特性状态: `Kubernetes v1.22 [alpha]`

如果部署了支持`VOLUME_MOUNT_GROUP NodeServiceCapability`的`CSI`(`Container Storage Interface`)驱动，
则基于`securityContext`中指定的`fsGroup`来设置文件的归属和权限的过程将由`CSI`驱动来完成，而不是`Kubernetes`。

前提是启用了`DelegateFSGroupToCSIDriver Kubernetes`特性门控。

在本例中，由于`Kubernetes`没有执行任何所有权和权限更改，因此`fsGroupChangePolicy`不会生效，并且正如`CSI`所指定的那样，
驱动程序将使用提供的`fsGroup`挂载卷，从而产生一个`fsGroup`可读/可写的卷。

请参阅[KEP](https://github.com/gnufied/enhancements/blob/master/keps/sig-storage/2317-fsgroup-on-mount/README.md) 
和`VolumeCapability.MountVolume`的描述。更多信息请参见[CSI规范](https://github.com/container-storage-interface/spec/blob/master/spec.md#createvolume) 中的`volume_mount_group`字段。