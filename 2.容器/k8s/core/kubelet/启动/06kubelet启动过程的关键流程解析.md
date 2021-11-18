## 初始化运行时服务

初始化运行时服务调用:

```go
err = kubelet.PreInitRuntimeService(&s.KubeletConfiguration,
		kubeDeps, &s.ContainerRuntimeOptions,
		s.ContainerRuntime,
		s.RuntimeCgroups,
		s.RemoteRuntimeEndpoint,
		s.RemoteImageEndpoint,
		s.NonMasqueradeCIDR)
if err != nil {
    return err
}
```

`PreInitRuntimeService`函数解析

```go
func PreInitRuntimeService(kubeCfg *kubeletconfiginternal.KubeletConfiguration,
	kubeDeps *Dependencies,
	crOptions *config.ContainerRuntimeOptions,
	containerRuntime string,
	runtimeCgroups string,
	remoteRuntimeEndpoint string,
	remoteImageEndpoint string,
	nonMasqueradeCIDR string) error {
	if remoteRuntimeEndpoint != "" {
		// remoteImageEndpoint is same as remoteRuntimeEndpoint if not explicitly specified
		if remoteImageEndpoint == "" {
			remoteImageEndpoint = remoteRuntimeEndpoint
		}
	}

	switch containerRuntime {
	case kubetypes.DockerContainerRuntime:
		// TODO: These need to become arguments to a standalone docker shim.
		pluginSettings := dockershim.NetworkPluginSettings{
			HairpinMode:        kubeletconfiginternal.HairpinMode(kubeCfg.HairpinMode),
			NonMasqueradeCIDR:  nonMasqueradeCIDR,
			PluginName:         crOptions.NetworkPluginName,
			PluginConfDir:      crOptions.CNIConfDir,
			PluginBinDirString: crOptions.CNIBinDir,
			PluginCacheDir:     crOptions.CNICacheDir,
			MTU:                int(crOptions.NetworkPluginMTU),
		}

		// Create and start the CRI shim running as a grpc server.
		streamingConfig := getStreamingConfig(kubeCfg, kubeDeps, crOptions)
		ds, err := dockershim.NewDockerService(kubeDeps.DockerClientConfig, crOptions.PodSandboxImage, streamingConfig,
			&pluginSettings, runtimeCgroups, kubeCfg.CgroupDriver, crOptions.DockershimRootDirectory, !crOptions.RedirectContainerStreaming)
		if err != nil {
			return err
		}
		if crOptions.RedirectContainerStreaming {
			kubeDeps.criHandler = ds
		}

		// The unix socket for kubelet <-> dockershim communication, dockershim start before runtime service init.
		klog.V(5).Infof("RemoteRuntimeEndpoint: %q, RemoteImageEndpoint: %q",
			remoteRuntimeEndpoint,
			remoteImageEndpoint)
		klog.V(2).Infof("Starting the GRPC server for the docker CRI shim.")
		dockerServer := dockerremote.NewDockerServer(remoteRuntimeEndpoint, ds)
		if err := dockerServer.Start(); err != nil {
			return err
		}

		// Create dockerLegacyService when the logging driver is not supported.
		supported, err := ds.IsCRISupportedLogDriver()
		if err != nil {
			return err
		}
		if !supported {
			kubeDeps.dockerLegacyService = ds
		}
	case kubetypes.RemoteContainerRuntime:
		// No-op.
		break
	default:
		return fmt.Errorf("unsupported CRI runtime: %q", containerRuntime)
	}

	var err error
	if kubeDeps.RemoteRuntimeService, err = remote.NewRemoteRuntimeService(remoteRuntimeEndpoint, kubeCfg.RuntimeRequestTimeout.Duration); err != nil {
		return err
	}
	if kubeDeps.RemoteImageService, err = remote.NewRemoteImageService(remoteImageEndpoint, kubeCfg.RuntimeRequestTimeout.Duration); err != nil {
		return err
	}

	kubeDeps.useLegacyCadvisorStats = cadvisor.UsingLegacyCadvisorStats(containerRuntime, remoteRuntimeEndpoint)

	return nil
}
```

主要做了以下几件事：

1. 初始化网络插件
2. 创建并启动`CRI shim`作为`grpc`服务端运行
3. 








