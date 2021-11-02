# Pod安全策略

[pod-security-policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/)

特性状态: `Kubernetes v1.21 [deprecated]`

`PodSecurityPolicy`在`Kubernetes v1.21`中已弃用，将在`v1.25`中被删除。有关弃用的更多信息，移步[PodSecurityPolicy Deprecation: Past, Present, and Future
](https://kubernetes.io/blog/2021/04/06/podsecuritypolicy-deprecation-past-present-and-future/)

`Pod`安全策略支持对`Pod`创建和更新的细粒度授权。

## Pod安全策略是用来做什么的？

`Pod`安全策略是一个集群级资源，它控制`Pod`规范的安全方面。
`PodSecurityPolicy`(`PSP`)对象定义了`pod`要进入系统必须运行的一组条件，以及相关字段的默认值。它们允许管理员控制以下内容:

| **控制面**             | **字段名称**                                                              |
|:-------------------:|:---------------------------------------------------------------------:|
| 运行特权容器              | privileged                                                            |
| 主机命名空间的使用           | hostPID, hostIPC                                                      |
| 主机网络和端口的使用          | hostNetwork, hostPorts                                                |
| 卷类型的使用              | volumes                                                               |
| 主机文件系统的使用           | allowedHostPaths                                                      |
| 允许特定的FlexVolume驱动程序 | allowedFlexVolumes                                                    |
| 分配一个拥有pod卷的FSGroup  | fsGroup                                                               |
| 需要使用只读的根文件系统        | readOnlyRootFilesystem                                                |
| 容器的用户和组id           | runAsUser, runAsGroup, supplementalGroups                             |
| 限制升级到根权限            | allowPrivilegeEscalation, defaultAllowPrivilegeEscalation             |
| Linux capabilities  | defaultAddCapabilities, requiredDropCapabilities, allowedCapabilities |
| 容器的SELinux上下文       | seLinux                                                               |
| 容器允许的Proc挂载类型       | allowedProcMountTypes                                                 |
| 容器使用的AppArmor配置文件   | annotations                                                           |
| 容器使用的seccomp配置文件    | annotations                                                           |
| 容器使用的sysctl配置文件     | forbiddenSysctls,allowedUnsafeSysctls                                 |

### 策略解析

> `Privileged`

`Privileged`决定`pod`中的任何容器是否可以启用特权模式。默认情况下，容器不允许访问主机上的任何设备，但`特权`容器被授予访问主机上的所有设备的权限。

这允许容器与主机上运行的进程进行几乎相同的访问。这对于希望使用`linux cap`(如操作网络堆栈和访问设备)的容器(比如`CSI`容器)很有用

> 共享主机命名空间

- `HostPID`: 控制`pod`是否可以共享主机`Pid`进程命名空间
- `HostIPC`: 控制`pod`是否可以共享主机`IPC`命名空间
- `HostNetwork`: 控制`pod`是否可以使用节点网络名称空间。这样做可以让`pod`访问环回设备、在本地主机上监听的服务，并且可以用来窥探同一节点上其他`pod`的网络活动。
- `HostPorts`: 结合`HostNetwork`提供主机网络名称空间中允许的端口范围的列表。定义为`HostPortRange`列表，包含`min`(包括)和`max`(包括)。默认为不允许主机端口。

> 卷与文件系统

- `Volumes`: 提供允许的卷类型列表。允许值对应于创建卷时定义的卷源。有关卷类型的完整列表，请参见[卷类型](https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes) 。
此外，*可用于允许所有卷类型。 推荐的最小允许卷集：
  - `configMap`
  - `downwardAPI`
  - `emptyDir`
  - `persistentVolumeClaim`
  - `secret`
  - `projected`

**注意**: `PodSecurityPolicy`不会限制可被`persistentvolumecclaim`引用的`PersistentVolume`对象类型，
`hostPath`类型的`PersistentVolumes`不支持只读访问模式。
应该只向受信任的用户授予创建`PersistentVolume`对象的权限。

> FSGroup: 控制应用于某些卷的补充组

- `MustRunAs`: 要求至少指定一个范围。使用第一个范围的最小值作为默认值。针对所有范围进行验证。
- `MayRunAs`: 要求至少指定一个范围。允许不设置`FSGroups`而不提供默认值。如果设置了`FSGroups`，则对所有范围进行验证。
- `RunAsAny`: 没有提供默认。允许指定任意`fsGroup ID`。

> AllowedHostPaths

指定`hostPath`卷允许使用的主机路径列表。空列表意味着对所使用的主机路径没有限制。
它被定义为一个带有单个`pathPrefix`字段的对象列表，该字段允许`hostPath`卷挂载以允许前缀开头的路径，并且`readOnly`字段指示它必须以只读方式挂载。
例如:

```yaml
allowedHostPaths:
    # This allows "/foo", "/foo/", "/foo/bar" etc., but
    # disallows "/fool", "/etc/foo" etc.
    # "/foo/../" is never valid.
    - pathPrefix: "/foo"
      readOnly: true # only allow read-only mounts
```

---

**注意：** 对主机文件系统具有无限制访问权限的容器可以通过多种方式升级特权，包括从其他容器读取数据，以及滥用系统服务(如`Kubelet`)的凭证。
可写`hostPath`目录卷允许容器以在`pathPrefix`之外遍历主机文件系统的方式写入文件系统。`readOnly: true`，在`Kubernetes 1.11+`中可用，必须在所有`allowedHostPaths`上使用，以有效地限制对指定`pathPrefix`的访问。

---

> ReadOnlyRootFilesystem

要求容器必须在只读的根文件系统中运行(即没有可写层)。

> 用户和组

- `RunAsUser`: 控制运行容器的用户`ID`
  - `MustRunAs`: 要求至少指定一个范围。使用第一个范围的最小值作为默认值。针对所有范围进行验证
  - `MustRunAsNonRoot`: 
  - ``:




## 开启PSP

`Pod`安全策略控制是作为可选的允许控制器实现的，`PodSecurityPolicies`是通过启用允许控制器来执行的 ，但是在不授权任何策略的情况下执行将会阻止在集群中创建任何`pod`。

由于`pod`安全策略`API` (`policy/v1beta1/podsecuritypolicy`)是独立于许可控制器启用的，
因此对于现有集群，建议在启用许可控制器之前添加并授权策略。

## 授权策略

`PodSecurityPolicy`通过以下两个步骤使用：

1. 创建`PodSecurityPolicy`
2. 授权请求用户或目标`pod`的服务帐户使用策略

大多数`Kubernetes pod`不是由用户直接创建的。
相反，它们通常是通过`ControllerManager`间接创建的，作为`Deployment`、`ReplicaSet`或其他模板化控制器的一部分。

授予控制器对策略的访问权将授予该控制器创建的所有`pod`的访问权，因此授权策略的首选方法是授予对`pod`服务帐户的访问权。

### 通过RBAC

`RBAC`是一种标准的`Kubernetes`授权模式，可以方便地对策略的使用进行授权。

首先，`Role`或`ClusterRole`需要授予使用所需策略的访问权限。授予访问权限的规则如下:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: <role name>
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs:     ['use']
  resourceNames:
  - <list of policies to authorize>
```

然后(Cluster)角色绑定到授权用户:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: <binding name>
roleRef:
  kind: ClusterRole
  name: <role name>
  apiGroup: rbac.authorization.k8s.io
subjects:
# Authorize all service accounts in a namespace (recommended):
- kind: Group
  apiGroup: rbac.authorization.k8s.io
  name: system:serviceaccounts:<authorized namespace>
# Authorize specific service accounts (not recommended):
- kind: ServiceAccount
  name: <authorized service account name>
  namespace: <authorized pod namespace>
# Authorize specific users (not recommended):
- kind: User
  apiGroup: rbac.authorization.k8s.io
  name: <authorized user name>
```

如果使用了`RoleBinding`(不是`ClusterRoleBinding`)，它将只允许在与绑定相同的名称空间中运行`pod`。
这可以与系统组配对，以授予对名称空间中运行的所有`pod`的访问权限:

```yaml
# Authorize all service accounts in a namespace:
- kind: Group
  apiGroup: rbac.authorization.k8s.io
  name: system:serviceaccounts
# Or equivalently, all authenticated users in a namespace:
- kind: Group
  apiGroup: rbac.authorization.k8s.io
  name: system:authenticated
```

## 最佳实践

`PodSecurityPolicy`正在被一个新的、简化的`PodSecurity`允许控制器所取代。遵循以下指导方针来简化从`PodSecurityPolicy`到新的允许控制器的迁移:

1. 将`Pod`安全策略限制为`Pod`安全标准定义的策略:
- [Privileged](https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/policy/privileged-psp.yaml)
- [Baseline](https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/policy/baseline-psp.yaml)
- [Restricted](https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/policy/restricted-psp.yaml)

2. 通过`system:serviceaccounts:<namespace>`将`psp`绑定到整个命名空间。例如:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This cluster role binding allows all pods in the "development" namespace to use the baseline PSP.
kind: ClusterRoleBinding
metadata:
  name: psp-baseline-namespaces
roleRef:
  kind: ClusterRole
  name: psp-baseline
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: Group
  name: system:serviceaccounts:development
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: system:serviceaccounts:canary
  apiGroup: rbac.authorization.k8s.io
```


