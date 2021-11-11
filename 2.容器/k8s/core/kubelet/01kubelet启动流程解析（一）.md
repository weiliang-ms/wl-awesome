# kubelet启动流程解析（一）

基于`kubernetes v1.18.6`

## 1.启动方式分析

我们一般以`systemd`系统守护进程的方式启动`kubelet`

```shell
$ systemctl status kubelet
● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: disabled)
  Drop-In: /etc/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: active (running) since Sat 2021-11-06 16:05:42 CST; 4 days ago
     Docs: http://kubernetes.io/docs/
  Process: 2153 ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/hugetlb/system.slice/kubelet.service (code=exited, status=0/SUCCESS)
  Process: 2150 ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/systemd/system.slice/kubelet.service (code=exited, status=0/SUCCESS)
  Process: 2143 ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/memory/system.slice/kubelet.service (code=exited, status=0/SUCCESS)
  Process: 2111 ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/cpuset/system.slice/kubelet.service (code=exited, status=0/SUCCESS)
  Process: 2105 ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/cpuacct/system.slice/kubelet.service (code=exited, status=0/SUCCESS)
  Process: 2061 ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/cpu/system.slice/kubelet.service (code=exited, status=0/SUCCESS)
 Main PID: 2168 (kubelet)
    Tasks: 230
   Memory: 867.4M
   CGroup: /system.slice/kubelet.service
           └─2168 /usr/local/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.co...

Nov 11 10:20:57 node1 kubelet[2168]: W1111 10:20:57.208900    2168 volume_linux.go:49] Setting volume ownership for /var/lib/kubelet/pods/5a15...
Nov 11 10:20:57 node1 kubelet[2168]: W1111 10:20:57.210533    2168 volume_linux.go:49] Setting volume ownership for /var/lib/kubelet/pods/5a15...
Nov 11 10:20:57 node1 kubelet[2168]: W1111 10:20:57.210833    2168 volume_linux.go:49] Setting volume ownership for /var/lib/kubelet/pods/5a15...
Nov 11 10:20:57 node1 kubelet[2168]: E1111 10:20:57.767389    2168 summary_sys_containers.go:47] Failed to get system container stats for "/sy...
Nov 11 10:20:58 node1 kubelet[2168]: I1111 10:20:58.064091    2168 topology_manager.go:219] [topologymanager] RemoveContainer - Contai...8291c7ef
Nov 11 10:20:58 node1 kubelet[2168]: I1111 10:20:58.064592    2168 topology_manager.go:219] [topologymanager] RemoveContainer - Contai...78e11ac7
Nov 11 10:20:58 node1 kubelet[2168]: E1111 10:20:58.074045    2168 pod_workers.go:191] Error syncing pod 2f3115c0-22d2-4094-a467-f543cd34da3f ...
Nov 11 10:20:58 node1 kubelet[2168]: E1111 10:20:58.082305    2168 pod_workers.go:191] Error syncing pod ea9d254d-3d05-4b69-b1ff-c986454078d8 ...
Nov 11 10:20:58 node1 kubelet[2168]: E1111 10:20:58.085689    2168 kuberuntime_manager.go:801] container start failed: CreateContainer...ot found
Nov 11 10:20:58 node1 kubelet[2168]: E1111 10:20:58.085713    2168 pod_workers.go:191] Error syncing pod ececebcf-daeb-45e1-8516-06a95d706293 ...
Hint: Some lines were ellipsized, use -l to show in full.
```

我们看下`service`配置


```shell
$ cat /etc/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=http://kubernetes.io/docs/

[Service]
ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/cpu/system.slice/kubelet.service
ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/cpuacct/system.slice/kubelet.service
ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/cpuset/system.slice/kubelet.service
ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/memory/system.slice/kubelet.service
ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/systemd/system.slice/kubelet.service
ExecStartPre=/usr/bin/mkdir -p /sys/fs/cgroup/hugetlb/system.slice/kubelet.service
ExecStart=/usr/local/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
```

其中启动部分执行了`/usr/local/bin/kubelet`二进制文件，启动的参数我们暂且不关注。

`/usr/local/bin/kubelet`二进制文件是由`kubernetes`源码编译而来，接下来让我们从`kubelet`源码角度分析它的启动流程

## 2.源码部分

[源码地址](https://github.com/kubernetes/kubernetes)

## 3.主函数入口

启动主函数位于: `kubernetes/cmd/kubelet/kubelet.go`

```
package main

import (
	"math/rand"
	"os"
	"time"

	"k8s.io/component-base/logs"
	_ "k8s.io/component-base/metrics/prometheus/restclient"
	_ "k8s.io/component-base/metrics/prometheus/version" // for version metric registration
	"k8s.io/kubernetes/cmd/kubelet/app"
)
func main() {
	rand.Seed(time.Now().UnixNano())

	// 初始化kubelet指令
	command := app.NewKubeletCommand()
	logs.InitLogs()
	defer logs.FlushLogs()

	if err := command.Execute(); err != nil {
		os.Exit(1)
	}
}
```

- `rand.Seed(time.Now().UnixNano())`: 定义了全局随机数种子
- `command := app.NewKubeletCommand()`: 根据启动参数初始化了`kubelet`指令
- `logs.InitLogs()`: 初始化日志控制器
- `err := command.Execute()`: 执行启动流程

接下来我们来分析`kubelet`初始化及启动流程

## 4.kubelet指令初始化解析

源码位置: `kubernetes/cmd/kubelet/app/server.go`

```
// NewKubeletCommand creates a *cobra.Command object with default parameters
func NewKubeletCommand() *cobra.Command {
	cleanFlagSet := pflag.NewFlagSet(componentKubelet, pflag.ContinueOnError)
	cleanFlagSet.SetNormalizeFunc(cliflag.WordSepNormalizeFunc)
	kubeletFlags := options.NewKubeletFlags()
	kubeletConfig, err := options.NewKubeletConfiguration()
	// programmer error
	if err != nil {
		klog.Fatal(err)
	}

	cmd := &cobra.Command{
		Use: componentKubelet,
		Long: `The kubelet is the primary "node agent" that runs on each
node. It can register the node with the apiserver using one of: the hostname; a flag to
override the hostname; or specific logic for a cloud provider.

The kubelet works in terms of a PodSpec. A PodSpec is a YAML or JSON object
that describes a pod. The kubelet takes a set of PodSpecs that are provided through
various mechanisms (primarily through the apiserver) and ensures that the containers
described in those PodSpecs are running and healthy. The kubelet doesn't manage
containers which were not created by Kubernetes.

Other than from an PodSpec from the apiserver, there are three ways that a container
manifest can be provided to the Kubelet.

File: Path passed as a flag on the command line. Files under this path will be monitored
periodically for updates. The monitoring period is 20s by default and is configurable
via a flag.

HTTP endpoint: HTTP endpoint passed as a parameter on the command line. This endpoint
is checked every 20 seconds (also configurable with a flag).

HTTP server: The kubelet can also listen for HTTP and respond to a simple API
(underspec'd currently) to submit a new manifest.`,
		// The Kubelet has special flag parsing requirements to enforce flag precedence rules,
		// so we do all our parsing manually in Run, below.
		// DisableFlagParsing=true provides the full set of flags passed to the kubelet in the
		// `args` arg to Run, without Cobra's interference.
		DisableFlagParsing: true,
		Run: func(cmd *cobra.Command, args []string) {
			// initial flag parse, since we disable cobra's flag parsing
			if err := cleanFlagSet.Parse(args); err != nil {
				cmd.Usage()
				klog.Fatal(err)
			}

			// check if there are non-flag arguments in the command line
			cmds := cleanFlagSet.Args()
			if len(cmds) > 0 {
				cmd.Usage()
				klog.Fatalf("unknown command: %s", cmds[0])
			}

			// short-circuit on help
			help, err := cleanFlagSet.GetBool("help")
			if err != nil {
				klog.Fatal(`"help" flag is non-bool, programmer error, please correct`)
			}
			if help {
				cmd.Help()
				return
			}

			// short-circuit on verflag
			verflag.PrintAndExitIfRequested()
			utilflag.PrintFlags(cleanFlagSet)

			// set feature gates from initial flags-based config
			if err := utilfeature.DefaultMutableFeatureGate.SetFromMap(kubeletConfig.FeatureGates); err != nil {
				klog.Fatal(err)
			}

			// validate the initial KubeletFlags
			if err := options.ValidateKubeletFlags(kubeletFlags); err != nil {
				klog.Fatal(err)
			}

			if kubeletFlags.ContainerRuntime == "remote" && cleanFlagSet.Changed("pod-infra-container-image") {
				klog.Warning("Warning: For remote container runtime, --pod-infra-container-image is ignored in kubelet, which should be set in that remote runtime instead")
			}

			// load kubelet config file, if provided
			if configFile := kubeletFlags.KubeletConfigFile; len(configFile) > 0 {
				kubeletConfig, err = loadConfigFile(configFile)
				if err != nil {
					klog.Fatal(err)
				}
				// We must enforce flag precedence by re-parsing the command line into the new object.
				// This is necessary to preserve backwards-compatibility across binary upgrades.
				// See issue #56171 for more details.
				if err := kubeletConfigFlagPrecedence(kubeletConfig, args); err != nil {
					klog.Fatal(err)
				}
				// update feature gates based on new config
				if err := utilfeature.DefaultMutableFeatureGate.SetFromMap(kubeletConfig.FeatureGates); err != nil {
					klog.Fatal(err)
				}
			}

			// We always validate the local configuration (command line + config file).
			// This is the default "last-known-good" config for dynamic config, and must always remain valid.
			if err := kubeletconfigvalidation.ValidateKubeletConfiguration(kubeletConfig); err != nil {
				klog.Fatal(err)
			}

			// use dynamic kubelet config, if enabled
			var kubeletConfigController *dynamickubeletconfig.Controller
			if dynamicConfigDir := kubeletFlags.DynamicConfigDir.Value(); len(dynamicConfigDir) > 0 {
				var dynamicKubeletConfig *kubeletconfiginternal.KubeletConfiguration
				dynamicKubeletConfig, kubeletConfigController, err = BootstrapKubeletConfigController(dynamicConfigDir,
					func(kc *kubeletconfiginternal.KubeletConfiguration) error {
						// Here, we enforce flag precedence inside the controller, prior to the controller's validation sequence,
						// so that we get a complete validation at the same point where we can decide to reject dynamic config.
						// This fixes the flag-precedence component of issue #63305.
						// See issue #56171 for general details on flag precedence.
						return kubeletConfigFlagPrecedence(kc, args)
					})
				if err != nil {
					klog.Fatal(err)
				}
				// If we should just use our existing, local config, the controller will return a nil config
				if dynamicKubeletConfig != nil {
					kubeletConfig = dynamicKubeletConfig
					// Note: flag precedence was already enforced in the controller, prior to validation,
					// by our above transform function. Now we simply update feature gates from the new config.
					if err := utilfeature.DefaultMutableFeatureGate.SetFromMap(kubeletConfig.FeatureGates); err != nil {
						klog.Fatal(err)
					}
				}
			}

			// construct a KubeletServer from kubeletFlags and kubeletConfig
			kubeletServer := &options.KubeletServer{
				KubeletFlags:         *kubeletFlags,
				KubeletConfiguration: *kubeletConfig,
			}

			// use kubeletServer to construct the default KubeletDeps
			kubeletDeps, err := UnsecuredDependencies(kubeletServer, utilfeature.DefaultFeatureGate)
			if err != nil {
				klog.Fatal(err)
			}

			// add the kubelet config controller to kubeletDeps
			kubeletDeps.KubeletConfigController = kubeletConfigController

			// set up stopCh here in order to be reused by kubelet and docker shim
			stopCh := genericapiserver.SetupSignalHandler()

			// start the experimental docker shim, if enabled
			if kubeletServer.KubeletFlags.ExperimentalDockershim {
				if err := RunDockershim(&kubeletServer.KubeletFlags, kubeletConfig, stopCh); err != nil {
					klog.Fatal(err)
				}
				return
			}

			// run the kubelet
			klog.V(5).Infof("KubeletConfiguration: %#v", kubeletServer.KubeletConfiguration)
			if err := Run(kubeletServer, kubeletDeps, utilfeature.DefaultFeatureGate, stopCh); err != nil {
				klog.Fatal(err)
			}
		},
	}

	// keep cleanFlagSet separate, so Cobra doesn't pollute it with the global flags
	kubeletFlags.AddFlags(cleanFlagSet)
	options.AddKubeletConfigFlags(cleanFlagSet, kubeletConfig)
	options.AddGlobalFlags(cleanFlagSet)
	cleanFlagSet.BoolP("help", "h", false, fmt.Sprintf("help for %s", cmd.Name()))

	// ugly, but necessary, because Cobra's default UsageFunc and HelpFunc pollute the flagset with global flags
	const usageFmt = "Usage:\n  %s\n\nFlags:\n%s"
	cmd.SetUsageFunc(func(cmd *cobra.Command) error {
		fmt.Fprintf(cmd.OutOrStderr(), usageFmt, cmd.UseLine(), cleanFlagSet.FlagUsagesWrapped(2))
		return nil
	})
	cmd.SetHelpFunc(func(cmd *cobra.Command, args []string) {
		fmt.Fprintf(cmd.OutOrStdout(), "%s\n\n"+usageFmt, cmd.Long, cmd.UseLine(), cleanFlagSet.FlagUsagesWrapped(2))
	})

	return cmd
}
```

### 4.1 参数解析

```
cleanFlagSet := pflag.NewFlagSet(componentKubelet, pflag.ContinueOnError)
cleanFlagSet.SetNormalizeFunc(cliflag.WordSepNormalizeFunc)
kubeletFlags := options.NewKubeletFlags()
kubeletConfig, err := options.NewKubeletConfiguration()
// programmer error
if err != nil {
    klog.Fatal(err)
}
```

其中以下部分定义了一个名为`cleanFlagSet`参数集合，并具有自动将参数中`_`转换为`-`能力

```
cleanFlagSet := pflag.NewFlagSet(componentKubelet, pflag.ContinueOnError)
cleanFlagSet.SetNormalizeFunc(cliflag.WordSepNormalizeFunc)
```

> `kubeletFlags := options.NewKubeletFlags()`则初始化了`kubelet`参数集合并赋予默认值

- `kubernetes/cmd/kubelet/app/options/options.go`

```
func NewKubeletFlags() *KubeletFlags {
	remoteRuntimeEndpoint := ""
	if runtime.GOOS == "linux" {
		remoteRuntimeEndpoint = "unix:///var/run/dockershim.sock"
	} else if runtime.GOOS == "windows" {
		remoteRuntimeEndpoint = "npipe:////./pipe/dockershim"
	}

	return &KubeletFlags{
		EnableServer:                        true,
		ContainerRuntimeOptions:             *NewContainerRuntimeOptions(),
		CertDirectory:                       "/var/lib/kubelet/pki",
		RootDirectory:                       defaultRootDir,
		MasterServiceNamespace:              metav1.NamespaceDefault,
		MaxContainerCount:                   -1,
		MaxPerPodContainerCount:             1,
		MinimumGCAge:                        metav1.Duration{Duration: 0},
		NonMasqueradeCIDR:                   "10.0.0.0/8",
		RegisterSchedulable:                 true,
		ExperimentalKernelMemcgNotification: false,
		RemoteRuntimeEndpoint:               remoteRuntimeEndpoint,
		NodeLabels:                          make(map[string]string),
		VolumePluginDir:                     "/usr/libexec/kubernetes/kubelet-plugins/volume/exec/",
		RegisterNode:                        true,
		SeccompProfileRoot:                  filepath.Join(defaultRootDir, "seccomp"),
		// prior to the introduction of this flag, there was a hardcoded cap of 50 images
		NodeStatusMaxImages:         50,
		EnableCAdvisorJSONEndpoints: false,
	}
}
```

参数值解析

1. `EnableServer`: 开启`kubelet`服务端
2. `ContainerRuntimeOptions`: 定义了容器运行时选项

```
func NewContainerRuntimeOptions() *config.ContainerRuntimeOptions {
	dockerEndpoint := ""
	if runtime.GOOS != "windows" {
		dockerEndpoint = "unix:///var/run/docker.sock"
	}

	return &config.ContainerRuntimeOptions{
		ContainerRuntime:           kubetypes.DockerContainerRuntime,
		RedirectContainerStreaming: false,
		DockerEndpoint:             dockerEndpoint,
		DockershimRootDirectory:    "/var/lib/dockershim",
		PodSandboxImage:            defaultPodSandboxImage,
		ImagePullProgressDeadline:  metav1.Duration{Duration: 1 * time.Minute},
		ExperimentalDockershim:     false,

		//Alpha feature
		CNIBinDir:   "/opt/cni/bin",
		CNIConfDir:  "/etc/cni/net.d",
		CNICacheDir: "/var/lib/cni/cache",
	}
}
```

`&config.ContainerRuntimeOptions`会初始化一部分字段，并非所有。

- `ContainerRuntime`: 默认使用`docker`容器运行时（`--container-runtime`）
- `RedirectContainerStreaming`: 重定向容器流，默认`false`（`--container-runtime`）
    - 当为`true`时: `kubelet`将返回一个`HTTP`重定向到`apiserver`，`apiserver`将直接访问容器运行时。
  虽然这样的话性能会有所提升，但安全方面又有了隐患（`apiserver`与容器运行时间无身份认证）
    - 当为`false`时: `kubelet`将会代理`apiserver`与容器运行时间的流数据，虽然性能上有些损耗，但也提供了安全保障。
- `DockerEndpoint`: 定义了`docker socket`路径(`unix:///var/run/docker.sock`)用于与`docker`间通信
- `DockershimRootDirectory`: `dockershim`根目录，默认为`/var/lib/dockershim`，用于集成测试（例如: `OpenShift`）
- `PodSandboxImage`: `pod`沙箱镜像，默认`k8s.gcr.io/pause:3.2`
- `ImagePullProgressDeadline`: 镜像拉取超时时间，默认1分钟，超过1分钟如果镜像未拉取成功将取消进行镜像拉取。
- `ExperimentalDockershim`: 是否开启`dockershim only`模式，默认`false`
- `CNIBinDir`: `CNI`二进制目录
- `CNIConfDir`: `CNI`配置文件目录
- `CNICacheDir`: `CNI`缓存目录

3. `CertDirectory`: 存放`TLS`证书的目录，默认为`/var/lib/kubelet/pki`。如果指定了`tlsCertFile`与`tlsPrivateKeyFile`，该参数会被忽略。
4. `RootDirectory`: 存放`kubelet`文件 (卷挂载，配置等)的目录，默认`/var/lib/kubelet`
5. `MasterServiceNamespace`: 已移除参数。注入到`pod`中的`kubernetes master`服务的命名空间，默认`default`
6. `MaxContainerCount`: 已移除参数。当前节点最大容器数量，默认无限制。
7. `MaxPerPodContainerCount`: 已移除参数。每一个容器最多在系统中保存的最大已经停止的实例数量，默认为`1`
8. `MinimumGCAge`: 已移除该参数。
9. `NonMasqueradeCIDR`: 已移除该参数。
10. `RegisterSchedulable`: 已移除该参数。
11. `ExperimentalKernelMemcgNotification`: 默认`false`。如果启用，`kubelet`将与内核`memcg`通知集成，以确定是否越过内存回收阈值，而不是轮询。
12. `RemoteRuntimeEndpoint`: 运行时服务端点
- `unix`系统: `unix:///var/run/dockershim.sock`
- `windows`系统: `npipe:////./pipe/dockershim`
13. `NodeLabels`: 注册节点至集群时，提供的节点标签集合(`map[string]string`)
14. `VolumePluginDir`: 存放第三方卷插件的目录，默认`/usr/libexec/kubernetes/kubelet-plugins/volume/exec/`
15. `RegisterNode`: 启用自动注册`apiserver`，默认`true`
16. `SeccompProfileRoot`: 存放`seccomp`配置文件的目录，默认为`/var/lib/kubelet/seccomp`
17. `NodeStatusMaxImages`: 限制了`node.status.images`中上报的映像数量，这是一个实验性的短期标志，用于帮助实现节点可伸缩性。默认50
18. `EnableCAdvisorJSONEndpoints`: 启用一些将在未来版本中删除的`cAdvisor`端点，默认`false`

### 4.2 初始化`kubelet`配置

```
kubeletConfig, err := options.NewKubeletConfiguration()
// programmer error
if err != nil {
klog.Fatal(err)
}
```

TODO

### 4.3 初始化kubelet指令

以下代码块定义了`kubelet`指令，其中`Run`字段定义了运行时逻辑，我们后文再做探讨
```
cmd := &cobra.Command{
      Use: componentKubelet,
      Long: `The kubelet is the primary "node agent" that runs on each
      node. It can register the node with the apiserver using one of: the hostname; a flag to
      override the hostname; or specific logic for a cloud provider.
      
      The kubelet works in terms of a PodSpec. A PodSpec is a YAML or JSON object
      that describes a pod. The kubelet takes a set of PodSpecs that are provided through
      various mechanisms (primarily through the apiserver) and ensures that the containers
      described in those PodSpecs are running and healthy. The kubelet doesn't manage
      containers which were not created by Kubernetes.
      
      Other than from an PodSpec from the apiserver, there are three ways that a container
      manifest can be provided to the Kubelet.
      
      File: Path passed as a flag on the command line. Files under this path will be monitored
      periodically for updates. The monitoring period is 20s by default and is configurable
      via a flag.
      
      HTTP endpoint: HTTP endpoint passed as a parameter on the command line. This endpoint
      is checked every 20 seconds (also configurable with a flag).
      
      HTTP server: The kubelet can also listen for HTTP and respond to a simple API
      (underspec'd currently) to submit a new manifest.`,
      // The Kubelet has special flag parsing requirements to enforce flag precedence rules,
      // so we do all our parsing manually in Run, below.
      // DisableFlagParsing=true provides the full set of flags passed to the kubelet in the
      // `args` arg to Run, without Cobra's interference.
      DisableFlagParsing: true,
      Run: func(cmd *cobra.Command, args []string) {
      // initial flag parse, since we disable cobra's flag parsing
      if err := cleanFlagSet.Parse(args); err != nil {
      cmd.Usage()
      klog.Fatal(err)
      }
      
      // check if there are non-flag arguments in the command line
      cmds := cleanFlagSet.Args()
      if len(cmds) > 0 {
      cmd.Usage()
      klog.Fatalf("unknown command: %s", cmds[0])
      }
      
      // short-circuit on help
      help, err := cleanFlagSet.GetBool("help")
      if err != nil {
      klog.Fatal(`"help" flag is non-bool, programmer error, please correct`)
      }
      if help {
      cmd.Help()
      return
      }
      
      // short-circuit on verflag
      verflag.PrintAndExitIfRequested()
      utilflag.PrintFlags(cleanFlagSet)
      
      // set feature gates from initial flags-based config
      if err := utilfeature.DefaultMutableFeatureGate.SetFromMap(kubeletConfig.FeatureGates); err != nil {
      klog.Fatal(err)
      }
      
      // validate the initial KubeletFlags
      if err := options.ValidateKubeletFlags(kubeletFlags); err != nil {
      klog.Fatal(err)
      }
      
      if kubeletFlags.ContainerRuntime == "remote" && cleanFlagSet.Changed("pod-infra-container-image") {
      klog.Warning("Warning: For remote container runtime, --pod-infra-container-image is ignored in kubelet, which should be set in that remote runtime instead")
      }
      
      // load kubelet config file, if provided
      if configFile := kubeletFlags.KubeletConfigFile; len(configFile) > 0 {
      kubeletConfig, err = loadConfigFile(configFile)
      if err != nil {
      klog.Fatal(err)
      }
      // We must enforce flag precedence by re-parsing the command line into the new object.
      // This is necessary to preserve backwards-compatibility across binary upgrades.
      // See issue #56171 for more details.
      if err := kubeletConfigFlagPrecedence(kubeletConfig, args); err != nil {
      klog.Fatal(err)
      }
      // update feature gates based on new config
      if err := utilfeature.DefaultMutableFeatureGate.SetFromMap(kubeletConfig.FeatureGates); err != nil {
      klog.Fatal(err)
      }
      }
      
      // We always validate the local configuration (command line + config file).
      // This is the default "last-known-good" config for dynamic config, and must always remain valid.
      if err := kubeletconfigvalidation.ValidateKubeletConfiguration(kubeletConfig); err != nil {
      klog.Fatal(err)
      }
      
      // use dynamic kubelet config, if enabled
      var kubeletConfigController *dynamickubeletconfig.Controller
      if dynamicConfigDir := kubeletFlags.DynamicConfigDir.Value(); len(dynamicConfigDir) > 0 {
      var dynamicKubeletConfig *kubeletconfiginternal.KubeletConfiguration
      dynamicKubeletConfig, kubeletConfigController, err = BootstrapKubeletConfigController(dynamicConfigDir,
      func(kc *kubeletconfiginternal.KubeletConfiguration) error {
      // Here, we enforce flag precedence inside the controller, prior to the controller's validation sequence,
      // so that we get a complete validation at the same point where we can decide to reject dynamic config.
      // This fixes the flag-precedence component of issue #63305.
      // See issue #56171 for general details on flag precedence.
      return kubeletConfigFlagPrecedence(kc, args)
      })
      if err != nil {
      klog.Fatal(err)
      }
      // If we should just use our existing, local config, the controller will return a nil config
      if dynamicKubeletConfig != nil {
      kubeletConfig = dynamicKubeletConfig
      // Note: flag precedence was already enforced in the controller, prior to validation,
      // by our above transform function. Now we simply update feature gates from the new config.
      if err := utilfeature.DefaultMutableFeatureGate.SetFromMap(kubeletConfig.FeatureGates); err != nil {
      klog.Fatal(err)
      }
      }
      }
      
      // construct a KubeletServer from kubeletFlags and kubeletConfig
      kubeletServer := &options.KubeletServer{
      KubeletFlags:         *kubeletFlags,
      KubeletConfiguration: *kubeletConfig,
      }
      
      // use kubeletServer to construct the default KubeletDeps
      kubeletDeps, err := UnsecuredDependencies(kubeletServer, utilfeature.DefaultFeatureGate)
      if err != nil {
      klog.Fatal(err)
      }
      
      // add the kubelet config controller to kubeletDeps
      kubeletDeps.KubeletConfigController = kubeletConfigController
      
      // set up stopCh here in order to be reused by kubelet and docker shim
      stopCh := genericapiserver.SetupSignalHandler()
      
      // start the experimental docker shim, if enabled
      if kubeletServer.KubeletFlags.ExperimentalDockershim {
      if err := RunDockershim(&kubeletServer.KubeletFlags, kubeletConfig, stopCh); err != nil {
      klog.Fatal(err)
      }
      return
      }
      
      // run the kubelet
      klog.V(5).Infof("KubeletConfiguration: %#v", kubeletServer.KubeletConfiguration)
      if err := Run(kubeletServer, kubeletDeps, utilfeature.DefaultFeatureGate, stopCh); err != nil {
      klog.Fatal(err)
      }
      },
}
```

### 4.4为kubelet指令定义参数

可选参数主要分为三个部分：
- 容器运行时相关参数
- 操作系统相关参数
- `kubelet`相关参数

> kubeletFlags.AddFlags(cleanFlagSet)

函数主体内容：
```
func (f *KubeletFlags) AddFlags(mainfs *pflag.FlagSet) {
	fs := pflag.NewFlagSet("", pflag.ExitOnError)
	defer func() {
		// Unhide deprecated flags. We want deprecated flags to show in Kubelet help.
		// We have some hidden flags, but we might as well unhide these when they are deprecated,
		// as silently deprecating and removing (even hidden) things is unkind to people who use them.
		fs.VisitAll(func(f *pflag.Flag) {
			if len(f.Deprecated) > 0 {
				f.Hidden = false
			}
		})
		mainfs.AddFlagSet(fs)
	}()

	f.ContainerRuntimeOptions.AddFlags(fs)
	f.addOSFlags(fs)

	fs.StringVar(&f.KubeletConfigFile, "config", f.KubeletConfigFile, "The Kubelet will load its initial configuration from this file. The path may be absolute or relative; relative paths start at the Kubelet's current working directory. Omit this flag to use the built-in default configuration values. Command-line flags override configuration from this file.")
	fs.StringVar(&f.KubeConfig, "kubeconfig", f.KubeConfig, "Path to a kubeconfig file, specifying how to connect to the API server. Providing --kubeconfig enables API server mode, omitting --kubeconfig enables standalone mode.")

	fs.StringVar(&f.BootstrapKubeconfig, "bootstrap-kubeconfig", f.BootstrapKubeconfig, "Path to a kubeconfig file that will be used to get client certificate for kubelet. "+
		"If the file specified by --kubeconfig does not exist, the bootstrap kubeconfig is used to request a client certificate from the API server. "+
		"On success, a kubeconfig file referencing the generated client certificate and key is written to the path specified by --kubeconfig. "+
		"The client certificate and key file will be stored in the directory pointed by --cert-dir.")

	fs.BoolVar(&f.ReallyCrashForTesting, "really-crash-for-testing", f.ReallyCrashForTesting, "If true, when panics occur crash. Intended for testing.")
	fs.Float64Var(&f.ChaosChance, "chaos-chance", f.ChaosChance, "If > 0.0, introduce random client errors and latency. Intended for testing.")

	fs.BoolVar(&f.RunOnce, "runonce", f.RunOnce, "If true, exit after spawning pods from static pod files or remote urls. Exclusive with --enable-server")
	fs.BoolVar(&f.EnableServer, "enable-server", f.EnableServer, "Enable the Kubelet's server")

	fs.StringVar(&f.HostnameOverride, "hostname-override", f.HostnameOverride, "If non-empty, will use this string as identification instead of the actual hostname. If --cloud-provider is set, the cloud provider determines the name of the node (consult cloud provider documentation to determine if and how the hostname is used).")

	fs.StringVar(&f.NodeIP, "node-ip", f.NodeIP, "IP address of the node. If set, kubelet will use this IP address for the node. If unset, kubelet will use the node's default IPv4 address, if any, or its default IPv6 address if it has no IPv4 addresses. You can pass `::` to make it prefer the default IPv6 address rather than the default IPv4 address.")

	fs.StringVar(&f.ProviderID, "provider-id", f.ProviderID, "Unique identifier for identifying the node in a machine database, i.e cloudprovider")

	fs.StringVar(&f.CertDirectory, "cert-dir", f.CertDirectory, "The directory where the TLS certs are located. "+
		"If --tls-cert-file and --tls-private-key-file are provided, this flag will be ignored.")

	fs.StringVar(&f.CloudProvider, "cloud-provider", f.CloudProvider, "The provider for cloud services. Specify empty string for running with no cloud provider. If set, the cloud provider determines the name of the node (consult cloud provider documentation to determine if and how the hostname is used).")
	fs.StringVar(&f.CloudConfigFile, "cloud-config", f.CloudConfigFile, "The path to the cloud provider configuration file.  Empty string for no configuration file.")

	fs.StringVar(&f.RootDirectory, "root-dir", f.RootDirectory, "Directory path for managing kubelet files (volume mounts,etc).")

	fs.Var(&f.DynamicConfigDir, "dynamic-config-dir", "The Kubelet will use this directory for checkpointing downloaded configurations and tracking configuration health. The Kubelet will create this directory if it does not already exist. The path may be absolute or relative; relative paths start at the Kubelet's current working directory. Providing this flag enables dynamic Kubelet configuration. The DynamicKubeletConfig feature gate must be enabled to pass this flag; this gate currently defaults to true because the feature is beta.")

	fs.BoolVar(&f.RegisterNode, "register-node", f.RegisterNode, "Register the node with the apiserver. If --kubeconfig is not provided, this flag is irrelevant, as the Kubelet won't have an apiserver to register with.")
	fs.Var(utiltaints.NewTaintsVar(&f.RegisterWithTaints), "register-with-taints", "Register the node with the given list of taints (comma separated \"<key>=<value>:<effect>\"). No-op if register-node is false.")

	// EXPERIMENTAL FLAGS
	fs.StringVar(&f.ExperimentalMounterPath, "experimental-mounter-path", f.ExperimentalMounterPath, "[Experimental] Path of mounter binary. Leave empty to use the default mount.")
	fs.BoolVar(&f.ExperimentalKernelMemcgNotification, "experimental-kernel-memcg-notification", f.ExperimentalKernelMemcgNotification, "If enabled, the kubelet will integrate with the kernel memcg notification to determine if memory eviction thresholds are crossed rather than polling.")
	fs.StringVar(&f.RemoteRuntimeEndpoint, "container-runtime-endpoint", f.RemoteRuntimeEndpoint, "[Experimental] The endpoint of remote runtime service. Currently unix socket endpoint is supported on Linux, while npipe and tcp endpoints are supported on windows.  Examples:'unix:///var/run/dockershim.sock', 'npipe:////./pipe/dockershim'")
	fs.StringVar(&f.RemoteImageEndpoint, "image-service-endpoint", f.RemoteImageEndpoint, "[Experimental] The endpoint of remote image service. If not specified, it will be the same with container-runtime-endpoint by default. Currently unix socket endpoint is supported on Linux, while npipe and tcp endpoints are supported on windows.  Examples:'unix:///var/run/dockershim.sock', 'npipe:////./pipe/dockershim'")
	fs.BoolVar(&f.ExperimentalCheckNodeCapabilitiesBeforeMount, "experimental-check-node-capabilities-before-mount", f.ExperimentalCheckNodeCapabilitiesBeforeMount, "[Experimental] if set true, the kubelet will check the underlying node for required components (binaries, etc.) before performing the mount")
	fs.BoolVar(&f.ExperimentalNodeAllocatableIgnoreEvictionThreshold, "experimental-allocatable-ignore-eviction", f.ExperimentalNodeAllocatableIgnoreEvictionThreshold, "When set to 'true', Hard Eviction Thresholds will be ignored while calculating Node Allocatable. See https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/ for more details. [default=false]")
	bindableNodeLabels := cliflag.ConfigurationMap(f.NodeLabels)
	fs.Var(&bindableNodeLabels, "node-labels", fmt.Sprintf("<Warning: Alpha feature> Labels to add when registering the node in the cluster.  Labels must be key=value pairs separated by ','. Labels in the 'kubernetes.io' namespace must begin with an allowed prefix (%s) or be in the specifically allowed set (%s)", strings.Join(kubeletapis.KubeletLabelNamespaces(), ", "), strings.Join(kubeletapis.KubeletLabels(), ", ")))
	fs.StringVar(&f.VolumePluginDir, "volume-plugin-dir", f.VolumePluginDir, "The full path of the directory in which to search for additional third party volume plugins")
	fs.StringVar(&f.LockFilePath, "lock-file", f.LockFilePath, "<Warning: Alpha feature> The path to file for kubelet to use as a lock file.")
	fs.BoolVar(&f.ExitOnLockContention, "exit-on-lock-contention", f.ExitOnLockContention, "Whether kubelet should exit upon lock-file contention.")
	fs.StringVar(&f.SeccompProfileRoot, "seccomp-profile-root", f.SeccompProfileRoot, "<Warning: Alpha feature> Directory path for seccomp profiles.")
	fs.StringVar(&f.BootstrapCheckpointPath, "bootstrap-checkpoint-path", f.BootstrapCheckpointPath, "<Warning: Alpha feature> Path to the directory where the checkpoints are stored")
	fs.Int32Var(&f.NodeStatusMaxImages, "node-status-max-images", f.NodeStatusMaxImages, "<Warning: Alpha feature> The maximum number of images to report in Node.Status.Images. If -1 is specified, no cap will be applied.")

	// DEPRECATED FLAGS
	fs.StringVar(&f.BootstrapKubeconfig, "experimental-bootstrap-kubeconfig", f.BootstrapKubeconfig, "")
	fs.MarkDeprecated("experimental-bootstrap-kubeconfig", "Use --bootstrap-kubeconfig")
	fs.DurationVar(&f.MinimumGCAge.Duration, "minimum-container-ttl-duration", f.MinimumGCAge.Duration, "Minimum age for a finished container before it is garbage collected.  Examples: '300ms', '10s' or '2h45m'")
	fs.MarkDeprecated("minimum-container-ttl-duration", "Use --eviction-hard or --eviction-soft instead. Will be removed in a future version.")
	fs.Int32Var(&f.MaxPerPodContainerCount, "maximum-dead-containers-per-container", f.MaxPerPodContainerCount, "Maximum number of old instances to retain per container.  Each container takes up some disk space.")
	fs.MarkDeprecated("maximum-dead-containers-per-container", "Use --eviction-hard or --eviction-soft instead. Will be removed in a future version.")
	fs.Int32Var(&f.MaxContainerCount, "maximum-dead-containers", f.MaxContainerCount, "Maximum number of old instances of containers to retain globally.  Each container takes up some disk space. To disable, set to a negative number.")
	fs.MarkDeprecated("maximum-dead-containers", "Use --eviction-hard or --eviction-soft instead. Will be removed in a future version.")
	fs.StringVar(&f.MasterServiceNamespace, "master-service-namespace", f.MasterServiceNamespace, "The namespace from which the kubernetes master services should be injected into pods")
	fs.MarkDeprecated("master-service-namespace", "This flag will be removed in a future version.")
	fs.BoolVar(&f.RegisterSchedulable, "register-schedulable", f.RegisterSchedulable, "Register the node as schedulable. Won't have any effect if register-node is false.")
	fs.MarkDeprecated("register-schedulable", "will be removed in a future version")
	fs.StringVar(&f.NonMasqueradeCIDR, "non-masquerade-cidr", f.NonMasqueradeCIDR, "Traffic to IPs outside this range will use IP masquerade. Set to '0.0.0.0/0' to never masquerade.")
	fs.MarkDeprecated("non-masquerade-cidr", "will be removed in a future version")
	fs.BoolVar(&f.KeepTerminatedPodVolumes, "keep-terminated-pod-volumes", f.KeepTerminatedPodVolumes, "Keep terminated pod volumes mounted to the node after the pod terminates.  Can be useful for debugging volume related issues.")
	fs.MarkDeprecated("keep-terminated-pod-volumes", "will be removed in a future version")
	fs.BoolVar(&f.EnableCAdvisorJSONEndpoints, "enable-cadvisor-json-endpoints", f.EnableCAdvisorJSONEndpoints, "Enable cAdvisor json /spec and /stats/* endpoints.")
	fs.MarkDeprecated("enable-cadvisor-json-endpoints", "will be removed in a future version")

}
```

1. 添加容器运行时参数:

`4.1 参数解析`部分提到的初始化阶段会初始化`ContainerRuntimeOptions`对象一部分参数，并对一些字段赋予默认值。
被赋予默认值的字段会被启动参数覆盖。并且在初始化阶段`ContainerRuntimeOptions`未被初始化的字段，要求显示指定(如：`--runtime-cgroups`)

```
f.ContainerRuntimeOptions.AddFlags(fs)
```
- 基础参数:
  - `--container-runtime`: 设置容器运行时
  - `--runtime-cgroups`: 设置运行时`cgroups`类型（一般为：`systemd`、`cgroupfs`）
  - `--redirect-container-streaming`: 重定向容器流，上文已做解释，不再探讨。(该参数处于移除状态)
- 当运行时为`Docker`时的参数（其他运行时以下参数不生效）:
  - `--experimental-dockershim`: 是否开启`dockershim only`模式，默认`false`，外部不可见该参数。
  - `--experimental-dockershim-root-directory`: `dockershim`根目录，默认为`/var/lib/dockershim`，用于集成测试（例如: `OpenShift`）,外部不可见该参数。
  - `--pod-infra-container-image`: `pod`沙箱镜像，默认`k8s.gcr.io/pause:3.2`，用于共享同一`pod`内容器的网络与`IPC`命名空间
  - `--docker-endpoint`: 定义了`docker socket`路径(`unix:///var/run/docker.sock`)用于与`docker`间通信
  - `--image-pull-progress-deadline`: 镜像拉取超时时间，默认1分钟，超过1分钟如果镜像未拉取成功将取消进行镜像拉取。
  - `--network-plugin`: 为`kubelet/pod`生命周期中的各种事件调用的网络插件的名称（calico、flannel）
  - `--cni-conf-dir`: `CNI`配置文件目录
  - `--cni-bin-dir`: `CNI`二进制文件目录
  - `--cni-cache-dir`: `CNI`缓存目录
  - `--network-plugin-mtu`: 设置网络`MTU`值，默认`1460`

2. 添加系统参数

```
f.addOSFlags(fs)
```

- `--windows-service`: 默认`false`，当`kubelet`运行于`widnows`上时需要设置为`true`
- `--windows-priorityclass`: `windows`下设置与`kubelet`进程关联的优先级

以上两个参数适用于`windows`场景，不做过多讨论

3. 添加`kubelet`参数

- `--config`: 字符串类型参数。`kubelet`将从这个文件加载它的初始配置。路径可以是绝对的，也可以是相对的。相对路径从`kubelet`的当前工作目录开始。
省略此标志以使用内置的默认配置值。命令行参数会覆盖此文件中的配置。
- `--kubeconfig`: 字符串类型参数。`kubeconfig`文件的路径，指定如何连接到`api-server`。当指定`--kubecconfig`时将启用`api-server`模式，不指定`--kubecconfig`将启用独立模式。
- `--bootstrap-kubeconfig`: 字符串类型参数。`kubeconfig`文件的路径，该文件将用于获取`kubelet`的客户端证书。
如果由`--kubeconfig`参数指定的文件不存在，则使用`--bootstrap-kubeconfig`从`api-server`请求客户端证书。
如果请求成功，生成的客户端证书和密钥的`kubeconfig`文件会被写入`--kubeconfig`指定的路径。
客户端证书和密钥文件将存储在`--cert-dir`指向的目录中。
- `--really-crash-for-testing`: 布尔类型参数，默认`false`。测试/调试场景下可以通过设置为`true`，使当发生异常时程序将崩溃退出。
- `--chaos-chance`: 浮点型参数，如果值大于0.0，则引入随机客户端错误和延迟，用于测试。
- `--runonce`: 布尔类型参数。如果为`true`，`kubelet`在从静态`pod`文件或远程`url`中生成`pod`后退出。
- `--enable-server`: 布尔类型参数。如果为`true`将启用`kubelet`服务端。
- `--hostname-override`: 字符串类型参数。如果非空，将使用此标识值作为主机名，而不是实际的主机名。如果设置了`--cloud-provider`，云提供程序将确定节点的名称(请参阅云提供程序文档，以确定是否以及如何使用该主机名)。
- `--node-ip`: 字符串类型参数，节点`IP`地址。如果设置，`kubelet`将使用该`IP`地址作为节点地址。
如果未设置，`kubelet`将使用节点的默认`IPv4`地址(如果有)，或者使用节点的默认`IPv6`地址(如果没有`IPv4`地址)。
你可以通过`::`使它更喜欢默认的`IPv6`地址而不是默认的`IPv4`地址。
- `--provider-id`: 字符串类型参数，如果设置了这个标识，它将设置外部提供者(如`cloudprovider`)用来识别特定节点的实例的唯一`id`
- `--cert-dir`: 字符串类型参数，指定存放`TLS`证书的目录，默认为`/var/lib/kubelet/pki`。如果指定了`tlsCertFile`与`tlsPrivateKeyFile`，该参数会被忽略。
- `--cloud-provider`: 云服务提供商。指定空字符串以在没有云提供商的情况下运行。
如果设置了，云提供程序将确定节点的名称(请参阅云提供程序文档，以确定是否以及如何使用该主机名)。
- `--`








