# 创建容器流程概念

本文主要分析创建`pod`容器时，`kubelet`所需做的操作，针对容器运行时创建容器的具体操作不作讨论。

主要分为以下几个步骤：

1. 设置容器重启次数: 该步骤根据容器名称查询`pod`的`status`中容器状态，若查询不到则重启次数设置为`0`，如查询到该容器状态则重启次数基于原值加`1`。
2. 生成创建容器所需配置，主要逻辑如下：
- 根据镜像名称，调用容器运行时，获取运行容器启动命令的用户
- 检测运行容器启动命令的用户判是否违反`pod`安全上下文设置（`runAsNonRoot: true`时，不允许容器以`root`用户启动）
- 生成日志目录（格式为: `/var/log/pods/<pod namespace>_<pod name>_<pod uid>/<容器名称>`）
- 针对`windows`平台，定义额外配置
- 定义容器内的环境变量
- 组装创建容器所需配置项并返回，配置项包括:
    - 主机名
    - 环境变量列表
    - 挂载点信息列表
    - 映射到容器中的主机设备列表
    - 容器端口映射列表
    - 容器注解列表
    - 容器标签列表
    - 容器根文件系统是否只读
    - 容器资源配额
    - 容器安全上下文配置
3. 创建容器: 调用容器运行时创建容器，返回成功创建的容器`id`，其中入参为：沙箱（`pause`容器）元数据 + 容器元数据
4. 预启动容器: 设置`pod`容器的`cpu`管理策略与拓扑管理策略。
5. 生成容器引用信息: 根据`pod`与容器实例元数据生成容器引用，引用用于报告事件，如创建、失败等。

> 源码部分

```go
func (m *kubeGenericRuntimeManager) startContainer(podSandboxID string, podSandboxConfig *runtimeapi.PodSandboxConfig, spec *startSpec, pod *v1.Pod, podStatus *kubecontainer.PodStatus, pullSecrets []v1.Secret, podIP string, podIPs []string) (string, error) {
...

	// Step 2: create the container.
	ref, err := kubecontainer.GenerateContainerRef(pod, container)
	if err != nil {
		klog.Errorf("Can't make a ref to pod %q, container %v: %v", format.Pod(pod), container.Name, err)
	}
	klog.V(4).Infof("Generating ref for container %s: %#v", container.Name, ref)

	// For a new container, the RestartCount should be 0
	// 如果该容器存在，则重启次数加1
	restartCount := 0
	containerStatus := podStatus.FindContainerStatusByName(container.Name)
	if containerStatus != nil {
		restartCount = containerStatus.RestartCount + 1
	}

	// 生成容器配置-获取临时容器ID
	target, err := spec.getTargetID(podStatus)
	if err != nil {
		s, _ := grpcstatus.FromError(err)
		m.recordContainerEvent(pod, container, "", v1.EventTypeWarning, events.FailedToCreateContainer, "Error: %v", s.Message())
		return s.Message(), ErrCreateContainerConfig
	}

	containerConfig, cleanupAction, err := m.generateContainerConfig(container, pod, restartCount, podIP, imageRef, podIPs, target)
	if cleanupAction != nil {
		defer cleanupAction()
	}
	if err != nil {
		s, _ := grpcstatus.FromError(err)
		m.recordContainerEvent(pod, container, "", v1.EventTypeWarning, events.FailedToCreateContainer, "Error: %v", s.Message())
		return s.Message(), ErrCreateContainerConfig
	}

	containerID, err := m.runtimeService.CreateContainer(podSandboxID, containerConfig, podSandboxConfig)
	if err != nil {
		s, _ := grpcstatus.FromError(err)
		m.recordContainerEvent(pod, container, containerID, v1.EventTypeWarning, events.FailedToCreateContainer, "Error: %v", s.Message())
		return s.Message(), ErrCreateContainer
	}
	err = m.internalLifecycle.PreStartContainer(pod, container, containerID)
	if err != nil {
		s, _ := grpcstatus.FromError(err)
		m.recordContainerEvent(pod, container, containerID, v1.EventTypeWarning, events.FailedToStartContainer, "Internal PreStartContainer hook failed: %v", s.Message())
		return s.Message(), ErrPreStartHook
	}
	m.recordContainerEvent(pod, container, containerID, v1.EventTypeNormal, events.CreatedContainer, fmt.Sprintf("Created container %s", container.Name))

	if ref != nil {
		m.containerRefManager.SetRef(kubecontainer.ContainerID{
			Type: m.runtimeName,
			ID:   containerID,
		}, ref)
	}
	...
}
```
