# pod容器日志管理

通过本文，你将了解`kubelet`是如何管理`pod`内的容器日志的。

## 定义pod日志目录

`kubelet`定义`pod`日志路径为：

```
/var/log/pods/<pod namespace>_<pod name>_<pod uid>
```

> 通过一个例子来验证上面的路径规则

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

证明上面规则正确

> 关于源码的实现

`kubernetes/pkg/kubelet/kuberuntime/kuberuntime_sandbox.go`

```go
$ func (m *kubeGenericRuntimeManager) generatePodSandboxConfig(pod *v1.Pod, attempt uint32) (*runtimeapi.PodSandboxConfig, error) {
...
	logDir := BuildPodLogsDirectory(pod.Namespace, pod.Name, pod.UID)
	podSandboxConfig.LogDirectory = logDir
...
}
```

## pod日志目录结构

### 思考一: pod日志目录下日志文件生成规则

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

- 其中`stakater-reloader`是根据容器名称生成的目录
- 其中`1.log  6.log  7.log`是根据容器重启次数生成日志文件，格式为: `<容器重启次数>.log`

> 我们看下源码实现:

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

### 思考二: 日志文件软链接规则

通过观察我们可以发现，这个目录下的日志文件是软链接类型文件:

```shell
$ ls -l /var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c/stakater-reloader
lrwxrwxrwx 1 root root 165 Jul 31 18:24 1.log -> /var/lib/docker/containers/cc75d79b3aef49f739b03f5fa7379f75c69944cbeb0a4555d3833a26ebfe06b4/cc75d79b3aef49f739b03f5fa7379f75c69944cbeb0a4555d3833a26ebfe06b4-json.log
lrwxrwxrwx 1 root root 165 Oct 23 21:56 6.log -> /var/lib/docker/containers/e9bc97e0cdd1e4258f17bb18db976ac371860103b861529cb690005ada97d153/e9bc97e0cdd1e4258f17bb18db976ac371860103b861529cb690005ada97d153-json.log
lrwxrwxrwx 1 root root 165 Nov  6 16:08 7.log -> /var/lib/docker/containers/c73e273fd2886df631739b03fd71a8216054549b11c651a7c8c38ce902342332/c73e273fd2886df631739b03fd71a8216054549b11c651a7c8c38ce902342332-json.log
```

其实是`kubelet`在启动容器后，生成的链接。

通过样例，我们不难发现链接匹配的规则如下：(适用于docker运行时，且为json日志插件)

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

日志文件的软链接设置逻辑实际发生于容器启动后：

```
/var/log/pods/<pod namespace>_<pod name>_<pod uid>/<容器名称>/重启重启次数.log
指向
/var/lib/docker/containers/<容器id>/<容器id>-json.log
```

`kubelet`启动容器核心源码：`kubernetes/pkg/kubelet/dockershim/docker_container.go`

```go
func (ds *dockerService) StartContainer(_ context.Context, r *runtimeapi.StartContainerRequest) (*runtimeapi.StartContainerResponse, error) {
	err := ds.client.StartContainer(r.ContainerId)

	// Create container log symlink for all containers (including failed ones).
	if linkError := ds.createContainerLogSymlink(r.ContainerId); linkError != nil {
		// Do not stop the container if we failed to create symlink because:
		//   1. This is not a critical failure.
		//   2. We don't have enough information to properly stop container here.
		// Kubelet will surface this error to user via an event.
		return nil, linkError
	}

	if err != nil {
		err = transformStartContainerError(err)
		return nil, fmt.Errorf("failed to start container %q: %v", r.ContainerId, err)
	}

	return &runtimeapi.StartContainerResponse{}, nil
}
```

其中`ds.createContainerLogSymlink(r.ContainerId)`便是创建日志文件软链接的逻辑，我们接下来对其进行深入分析

> 容器日志链接创建流程解析

创建容器日志软链接，主要分为三个步骤:

1. 根据容器`ID`，解析容器的真实日志路径，对应返回值`realPath`

```shell
$ docker inspect cff000d9fc5e -f "{{ .LogPath }}"
/var/lib/docker/containers/cff000d9fc5edad5a8b042b8879fedd1d7de978b928c522a53c11b3217c220df/cff000d9fc5edad5a8b042b8879fedd1d7de978b928c522a53c11b3217c220df-json.log
```

2. 根据容器`ID`，解析容器的`pod`日志路径标签，对应返回值`path`

```shell
$ docker inspect cff000d9fc5e -f '{{ index .Config.Labels "io.kubernetes.container.logpath" }}'
/var/log/pods/istio-system_istio-ingressgateway-c694cfd-cgk2n_c6ea97b6-d858-4c4c-8d83-17477599aebf/istio-proxy/4.log
```

3. 根据前两步获取的`path`与`realPath`创建文件链接，等同于

```shell
$ ln -s $realPath $path
```

> 源码解析其实现

其中`path, realPath, err := ds.getContainerLogPath(containerID)`为获取容器信息逻辑，关于返回值解析:

- `path`: 容器的`Config.Labels["io.kubernetes.container.logpath"]`字段，该容器所属`pod`日志路径（实质为真实日志路径的软链接）
- `realPath`: 该容器的真实日志路径

`kubernetes/pkg/kubelet/dockershim/docker_container.go`源码

```go
// createContainerLogSymlink creates the symlink for docker container log.
func (ds *dockerService) createContainerLogSymlink(containerID string) error {
	path, realPath, err := ds.getContainerLogPath(containerID)
	if err != nil {
		return fmt.Errorf("failed to get container %q log path: %v", containerID, err)
	}

	if path == "" {
		klog.V(5).Infof("Container %s log path isn't specified, will not create the symlink", containerID)
		return nil
	}

	if realPath != "" {
		// Only create the symlink when container log path is specified and log file exists.
		// Delete possibly existing file first
		if err = ds.os.Remove(path); err == nil {
			klog.Warningf("Deleted previously existing symlink file: %q", path)
		}
		if err = ds.os.Symlink(realPath, path); err != nil {
			return fmt.Errorf("failed to create symbolic link %q to the container log file %q for container %q: %v",
				path, realPath, containerID, err)
		}
	} else {
		supported, err := ds.IsCRISupportedLogDriver()
		if err != nil {
			klog.Warningf("Failed to check supported logging driver by CRI: %v", err)
			return nil
		}

		if supported {
			klog.Warningf("Cannot create symbolic link because container log file doesn't exist!")
		} else {
			klog.V(5).Infof("Unsupported logging driver by CRI")
		}
	}

	return nil
}
```

- 其中函数`getContainerLogPath()`源码如下:

```go
func (ds *dockerService) getContainerLogPath(containerID string) (string, string, error) {
    info, err := ds.client.InspectContainer(containerID)
    if err != nil {
        return "", "", fmt.Errorf("failed to inspect container %q: %v", containerID, err)
    }
    return info.Config.Labels[containerLogPathLabelKey], info.LogPath, nil
}
```

- 其中函数`createContainerLogSymlink()`源码如下:

```go
func (ds *dockerService) getContainerLogPath(containerID string) (string, string, error) {
	info, err := ds.client.InspectContainer(containerID)
	if err != nil {
		return "", "", fmt.Errorf("failed to inspect container %q: %v", containerID, err)
	}
	return info.Config.Labels[containerLogPathLabelKey], info.LogPath, nil
}
```

`ds.os.Symlink(realPath, path)`为调用系统接口，创建日志文件软链接

## 总结

通过上述分析，我们可以得出以下结论（docker运行时下）:

1. `k8s`下容器日志目录为：`/var/log/pods/<pod namespace>_<pod name>_<pod uid>/<容器名称>/重启重启次数.log`，并且是文件

`/var/lib/docker/containers/<容器id>/<容器id>-json.log`的链接。

2. `pod`会按容器的重启次数对应保留日志，具体保留个数应该与`GC`策略有关