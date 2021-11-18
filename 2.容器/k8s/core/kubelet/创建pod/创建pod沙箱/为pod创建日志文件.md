## 为pod创建日志文件

### 定义pod日志目录

日志路径为：

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

日志路径为：

```
/var/log/pods/<pod namespace>_<pod name>_<pod uid>/<.spec.containers[x].name>/*.log
```

其中`<.spec.containers[x].name>`为`pod`内定义容器的名称，可为多个。每个容器对应一个以容器名命名的目录，下面存放容器日志。

通过观察我们可以发现，这个目录下的日志文件是链接类型文件:

```shell
$ ls -l /var/log/pods/default_stakater-reloader-598f958967-ddkl7_2681cb7f-daa4-4620-bb60-1d449709181c/stakater-reloader
lrwxrwxrwx 1 root root 165 Jul 31 18:24 1.log -> /var/lib/docker/containers/cc75d79b3aef49f739b03f5fa7379f75c69944cbeb0a4555d3833a26ebfe06b4/cc75d79b3aef49f739b03f5fa7379f75c69944cbeb0a4555d3833a26ebfe06b4-json.log
lrwxrwxrwx 1 root root 165 Oct 23 21:56 6.log -> /var/lib/docker/containers/e9bc97e0cdd1e4258f17bb18db976ac371860103b861529cb690005ada97d153/e9bc97e0cdd1e4258f17bb18db976ac371860103b861529cb690005ada97d153-json.log
lrwxrwxrwx 1 root root 165 Nov  6 16:08 7.log -> /var/lib/docker/containers/c73e273fd2886df631739b03fd71a8216054549b11c651a7c8c38ce902342332/c73e273fd2886df631739b03fd71a8216054549b11c651a7c8c38ce902342332-json.log
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

源码实现:

`kubernetes/pkg/kubelet/kuberuntime/kuberuntime_container.go`
```go
func (m *kubeGenericRuntimeManager) generateContainerConfig(container *v1.Container, pod *v1.Pod, restartCount int, podIP, imageRef string, podIPs []string, nsTarget *kubecontainer.ContainerID) (*runtimeapi.ContainerConfig, func(), error) {
	opts, cleanupAction, err := m.runtimeHelper.GenerateRunContainerOptions(pod, container, podIP, podIPs)
..
	containerLogsPath := buildContainerLogsPath(container.Name, restartCount)
...
}
```

`restartCount`重启次数这个值我们可以通过以下方式获取:

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

> 思考二：`<.spec.containers[x].name>/*.log`生成规则

其实是`kubelet`在启动容器后，生成的链接。

链接匹配的规则：

```
源: 
```

> 源码实现

```go
...
func (m *kubeGenericRuntimeManager) startContainer(podSandboxID string, podSandboxConfig *runtimeapi.PodSandboxConfig, spec *startSpec, pod *v1.Pod, podStatus *kubecontainer.PodStatus, pullSecrets []v1.Secret, podIP string, podIPs []string) (string, error) {
    ...
    // 生成容器配置
    // 其中日志目录规则为：
	containerConfig, cleanupAction, err := m.generateContainerConfig(container, pod, restartCount, podIP, imageRef, podIPs, target)
    ...
    // 拼接容器日志目录
    // 其中podSandboxConfig.LogDirectory为：
    containerLog := filepath.Join(podSandboxConfig.LogDirectory, containerConfig.LogPath)
    // only create legacy symlink if containerLog path exists (or the error is not IsNotExist).
    // Because if containerLog path does not exist, only dandling legacySymlink is created.
    // This dangling legacySymlink is later removed by container gc, so it does not make sense
    // to create it in the first place. it happens when journald logging driver is used with docker.
    if _, err := m.osInterface.Stat(containerLog); !os.IsNotExist(err) {
        if err := m.osInterface.Symlink(containerLog, legacySymlink); err != nil {
            klog.Errorf("Failed to create legacy symbolic link %q to container %q log %q: %v",
            legacySymlink, containerID, containerLog, err)
        }
    }
...
}
```