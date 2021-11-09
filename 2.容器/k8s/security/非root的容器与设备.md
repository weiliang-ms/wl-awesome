# 非根用户下的容器与设备

[Non-root Containers And Devices](https://kubernetes.io/blog/2021/11/09/non-root-containers-and-devices/)

`Author: Mikko Ylinen (Intel)`

当用户希望在`Linux`上部署使用加速器设备的容器(通过[Kubernetes Device Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/) )时，`Pod`的`securityContext`中与用户/组`ID`相关的安全设置会导致一个问题

在这篇博文中，我将讨论这个问题，并描述到目前为止为解决这个问题所做的工作。解决该[issue](https://github.com/kubernetes/kubernetes/issues/92211) 并不需要长篇大论。

相反，这篇文章的目的是提高人们对这个问题的认识，并强调重要的设备用例。这是`Kubernetes`需要的，因为`Kubernetes`要处理新的相关特性，比如对用户名称空间的支持。

## 为什么非根容器无权使用设备？

> 在`Kubernetes`中运行容器的关键安全原则之一是最小权限原则:

`Pod/container securityContext`指定要设置的配置选项，例如`Linux`功能(`CAP`)、`MAC`策略和用户/组`ID`值。
此外，集群管理员还可以使用`PodSecurityPolicy`(已弃用)或`PodSecurity Admission `(alpha)等工具来对部署在集群中的`Pod`实施所需的安全设置

例如，这些设置可能要求容器必须是`runAsNonRoot`，或者禁止它们在`runAsGroup`或`supplementalGroups`中使用`root`的组`ID`运行

在`Kubernetes`中，`kubelet`构建容器可用的设备资源列表(基于来自设备插件的输入)，
该列表包含在发送给`CRI`容器运行时的`CreateContainer CRI`消息中。

每个设备包含很少的信息: 主机/容器设备路径和所需的设备组权限。

```
{
        "type": "<string>",
        "path": "<string>",
        "major": <int64>,
        "minor": <int64>,
        "fileMode": <uint32>,
        "uid": <uint32>,
        "gid": <uint32>
},
```

`CRI`容器运行时(`containerd, CRI-O`)负责从主机获取每个设备的信息。默认情况下，运行时复制主机设备的用户和组`id`:

- `uid`(`uint32`，可选)-容器命名空间中设备所有者的`id`
- `gid`(`uint32`，可选)-容器命名空间中设备组的`id`

类似地，运行时还提供了一些其他配置选项。基于`CRI`字段的`config.json`部分进行定义，
包括`securityContext: runAsUser/runAsGroup`中定义的部分内容，
它通过以下方式成为`POSIX`平台用户结构的一部分:

- `uid`(`int`, 必需): 指定容器名称空间中的用户`ID`
- `gid`(`int`, 必需): 指定容器名称空间中的组`ID`
- `additionalGids`(`int`数组, 可选): 在容器名称空间中指定要添加到进程的附加组`id`。

然而，以`config.json`中的配置运行容器时将导致以下问题：

当运行容器既添加了设备，又通过`runAsUser/runAsGroup`设置了非根用户`uid/gid`的容器时，将导致以下问题：
容器用户进程没有使用设备的权限(即使设备的组`id`是允许非根用户组使用的)。

这是因为容器用户不属于那个主机组(例如，通过`additionalGids`)。

## 如何解决这个问题呢？

您可能已经从问题定义中注意到，至少可以通过手动将设备`gid`添加到`supplementalGroups`来解决问题。
或者在只有一个设备的情况下，将`runAsGroup`设置为设备的组`id`。

然而，这是有问题的，因为设备的`gid`可能有不同的值，这取决于集群中的节点的发行版/版本。
例如，对于不同的发行版和版本，下面的命令返回不同的`gid`:

- `Fedora 33`:

```shell
$ ls -l /dev/dri/
total 0
drwxr-xr-x. 2 root root         80 19.10. 10:21 by-path
crw-rw----+ 1 root video  226,   0 19.10. 10:42 card0
crw-rw-rw-. 1 root render 226, 128 19.10. 10:21 renderD128
$ grep -e video -e render /etc/group
video:x:39:
render:x:997:
```

- `Ubuntu 20.04`:

```shell
$ ls -l /dev/dri/
total 0
drwxr-xr-x 2 root root         80 19.10. 17:36 by-path
crw-rw---- 1 root video  226,   0 19.10. 17:36 card0
crw-rw---- 1 root render 226, 128 19.10. 17:36 renderD128
$ grep -e video -e render /etc/group
video:x:44:
render:x:133:
```

所以说在`securityContext`中应该设置哪个数字? 

此外，如果`runAsGroup/runAsUser`值是通过外部安全策略自动分配的，不能硬编码，该怎么办?

与带有`fsGroup`属性的卷不同，这些设备没有`CRI`运行时(或`kubelet`)能够使用的`deviceGroup/deviceUser`的正式概念。

如果使用由设备插件设置的容器注释(例如，`io.kubernetes.cri.hostDeviceSupplementalGroup/`)来获得自定义的`OCI`的`conf.json`中`uid/gid`值。
这将需要改变所有现有的设备插件，这不是理想的。

相反，这里有一个对终端用户更好的解决方案 -> 设备复用`securityContext`的`runAsUser`和`runAsGroup`值:

- 设备`uid`对应`runAsUser`
- 设备`gid`对应`runAsGroup`

```
{
        "type": "c",
        "path": "/dev/foo",
        "major": 123,
        "minor": 4,
        "fileMode": 438,
        "uid": <runAsUser>,
        "gid": <runAsGroup>
},
```

使用`runc OCI`运行时(在`non-rootless`模式下)下，设备将在容器名称空间中创建(通过`mknod(2)`)，并且使用`chmod(2)`将所有权更改为`runAsUser/runAsGroup`。


在容器名称空间中更新所有权是合理的，因为用户进程是唯一访问设备的进程。
只考虑`runAsUser/runAsGroup`，例如，容器中的`USER`设置当前被忽略。

`containerd `与`CRI-O`中通过配置下面参数生效（设备权限从安全上下文中获取: 默认false）
```
device_ownership_from_security_context (bool)
```
 
## 使用样例

```shell

```




