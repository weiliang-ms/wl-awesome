## 为pod创建日志文件

通过本文，你将了解`kubelet`是如何管理`pod`日志的。

### 定义pod日志目录

`kubelet`定义`pod`日志路径为：

```
/var/log/pods/<pod namespace>_<pod name>_<pod uid>
```

> 通过一个例子来验证上面的路径

`default`命名空间下存在一个名为`stakater-reloader-598f958967-ddkl7`的`pod`

```shell
$ kubectl get pod
NAME                                 READY   STATUS    RESTARTS   AGE
stakater-reloader-598f958967-ddkl7   1/1     Running   7          117d
```

获取其`uid`（`metadata.uid`字段）

```shell
$ kubectl get pod stakater-reloader-598f958967-ddkl7 -o yaml|grep uid
          k:{"uid":"ea8b9161-bee3-4bf6-a4e3-65fe256e3771"}:
            f:uid: {}
    uid: ea8b9161-bee3-4bf6-a4e3-65fe256e3771
  uid: 2681cb7f-daa4-4620-bb60-1d449709181c
```

跟据上面信息拼装，我们获取了该`pod`的日志目录

```shell
$ ls /var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c
stakater-reloader
```

验证上面规则正确性

> 源码实现

`kubernetes/pkg/kubelet/kuberuntime/kuberuntime_sandbox.go`

```go
$ func (m *kubeGenericRuntimeManager) generatePodSandboxConfig(pod *v1.Pod, attempt uint32) (*runtimeapi.PodSandboxConfig, error) {
...
	logDir := BuildPodLogsDirectory(pod.Namespace, pod.Name, pod.UID)
	podSandboxConfig.LogDirectory = logDir
...
}
```

### pod日志目录结构

上文我们了解到，`kubelet`定义`pod`日志路径为：

```
/var/log/pods/<pod namespace>_<pod name>_<pod uid>
```

我们观察下其路径结构：

```shell
$ ls -R /var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c
/var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c:
stakater-reloader

/var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c/stakater-reloader:
1.log  6.log  7.log
```

> 思考一：`<.spec.containers[x].name>/*.log`生成规则

```shell
$ ls -R /var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c
/var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c:
stakater-reloader

/var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c/stakater-reloader:
1.log  6.log  7.log
```

根据容器名称生成目录: `stakater-reloader`
根据容器重启次数生成日志文件：`1.log  6.log  7.log`

**源码实现:**

`kubernetes/pkg/kubelet/kuberuntime/kuberuntime_container.go`

```go
...
func (m *kubeGenericRuntimeManager) startContainer(podSandboxID string, podSandboxConfig *runtimeapi.PodSandboxConfig, spec *startSpec, pod *v1.Pod, podStatus *kubecontainer.PodStatus, pullSecrets []v1.Secret, podIP string, podIPs []string) (string, error) {
    ...
    // 1. 生成容器配置
    // 其中日志目录规则为：
	containerConfig, cleanupAction, err := m.generateContainerConfig(container, pod, restartCount, podIP, imageRef, podIPs, target)
    ...
    // 2. 拼接容器日志目录
    // 其中podSandboxConfig.LogDirectory = /var/log/pods/<pod namespace>_<pod name>_<pod uid>
    // containerConfig.LogPath = <container name>/容器重启次数.log 
    containerLog := filepath.Join(podSandboxConfig.LogDirectory, containerConfig.LogPath)
    // only create legacy symlink if containerLog path exists (or the error is not IsNotExist).
    // Because if containerLog path does not exist, only dandling legacySymlink is created.
    // This dangling legacySymlink is later removed by container gc, so it does not make sense
    // to create it in the first place. it happens when journald logging driver is used with docker.
    // 3. 建立链接
    if _, err := m.osInterface.Stat(containerLog); !os.IsNotExist(err) {
        if err := m.osInterface.Symlink(containerLog, legacySymlink); err != nil {
            klog.Errorf("Failed to create legacy symbolic link %q to container %q log %q: %v",
            legacySymlink, containerID, containerLog, err)
        }
    }
...
}
```

`kubernetes/pkg/kubelet/kuberuntime/kuberuntime_container.go`
```go
func (m *kubeGenericRuntimeManager) generateContainerConfig(container *v1.Container, pod *v1.Pod, restartCount int, podIP, imageRef string, podIPs []string, nsTarget *kubecontainer.ContainerID) (*runtimeapi.ContainerConfig, func(), error) {
	opts, cleanupAction, err := m.runtimeHelper.GenerateRunContainerOptions(pod, container, podIP, podIPs)
...
	// 拼接容器日志文件路径
	containerLogsPath := buildContainerLogsPath(container.Name, restartCount)
...
}
```

其中`restartCount`重启次数这个值我们可以通过以下方式获取:

```shell
$ kubectl get pod stakater-reloader-598f958967-ddkl7 -o yaml
...
status:
...
  containerStatuses:
  - containerID: docker://c73e273fd2886df631739b03fd71a8216054549b11c651a7c8c38ce902342332
...
    restartCount: 7
...
```

> 思考二: 日志文件链接规则及初始化位置

通过观察我们可以发现，这个目录下的日志文件是链接类型文件:

```shell
$ ls -l /var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c/stakater-reloader
lrwxrwxrwx 1 root root 165 Jul 31 18:24 1.log -> /var/lib/docker/containers/cc75d79b3aef49f739b03f5fa7379f75c69944cbeb0a4555d3833a26ebfe06b4/cc75d79b3aef49f739b03f5fa7379f75c69944cbeb0a4555d3833a26ebfe06b4-json.log
lrwxrwxrwx 1 root root 165 Oct 23 21:56 6.log -> /var/lib/docker/containers/e9bc97e0cdd1e4258f17bb18db976ac371860103b861529cb690005ada97d153/e9bc97e0cdd1e4258f17bb18db976ac371860103b861529cb690005ada97d153-json.log
lrwxrwxrwx 1 root root 165 Nov  6 16:08 7.log -> /var/lib/docker/containers/c73e273fd2886df631739b03fd71a8216054549b11c651a7c8c38ce902342332/c73e273fd2886df631739b03fd71a8216054549b11c651a7c8c38ce902342332-json.log
```


其实是`kubelet`在启动容器后，生成的链接。

通过样例，我们不难发现链接匹配的规则：(适用于docker运行时，且为json日志插件)

```
/var/log/pods/<pod namespace>_<pod name>_<pod uid>/<容器名称>/重启重启次数.log
指向
/var/lib/docker/containers/<容器id>/<容器id>-json.log
```

其中容器`id`我们可以通过以下方式获取

```shell
$ kubectl get pod stakater-reloader-598f958967-zbn2g -o yaml|grep -e "- containerID"
  - containerID: docker://fed0bdb0183c8bcfd1c91090d96e3c594c588de94f89f68ff24a8fe7f940e50e
```

> 源码实现


### 总结

通过上述分析，我们可以得出以下结论（docker运行时下）:

1. `k8s`下容器日志目录为：`/var/log/pods/<pod namespace>_<pod name>_<pod uid>/<容器名称>/重启重启次数.log`，并且是文件

`/var/lib/docker/containers/<容器id>/<容器id>-json.log`的链接。

2. `pod`会按容器的重启次数对应保留日志，具体保留个数应该与`GC`策略有关