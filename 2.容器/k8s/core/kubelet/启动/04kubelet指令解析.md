## kubelet指令解析

完整的指令定义:

```go
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

这里我们只探讨`Run`部分内容，这部分内容为实际运行时逻辑，其他部分内容可参考[cobra](https://github.com/spf13/cobra)

内容较多，我们按步骤进行拆解分析

### 1.命令行参数解析

1. 标识解析

```go
if err := cleanFlagSet.Parse(args); err != nil {
    cmd.Usage()
    klog.Fatal(err)
}
```

第一步解析命令行的入参（如: `--kubeconfig`、`--config`），如果解析阶段出现异常（通常为标识名或值错误），
调用`cmd.Usage()`输出可选标识，退出启动。

2. 子命令解析

`kubelet`无子命令（如：`kubectl apply`中的`apply`为`kubectl`的子命令），若解析出含有子命令，调用`cmd.Usage()`输出可选标识，退出启动。

```go
// check if there are non-flag arguments in the command line
cmds := cleanFlagSet.Args()
if len(cmds) > 0 {
    cmd.Usage()
    klog.Fatalf("unknown command: %s", cmds[0])
}
```

3. 判断是否为`--help`或`-h`

如果为`help`标识，输出以下内容，退出启动流程

```shell
$ kubelet -h
The kubelet is the primary "node agent" that runs on each
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
(underspec'd currently) to submit a new manifest.

Usage:
  kubelet [flags]

Flags:
      --add-dir-header                                                                                            If true, adds the file directory to the header
      --address 0.0.0.0                                                                                           The IP address for the Kubelet to serve on (set to 0.0.0.0 for all IPv4 interfaces and `::` for all IPv6 interfaces) (default 0.0.0.0) (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
      --allowed-unsafe-sysctls strings                                                                            Comma-separated whitelist of unsafe sysctls or unsafe sysctl patterns (ending in *). Use these at your own risk. (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
      --alsologtostderr                                                                                           log to standard error as well as files
      --anonymous-auth                                                                                            Enables anonymous requests to the Kubelet server. Requests that are not rejected by another authentication method are treated as anonymous requests. Anonymous requests have a username of system:anonymous, and a group name of system:unauthenticated. (default true) (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
      --application-metrics-count-limit int                                                                       Max number of application metrics to store (per container) (default 100) (DEPRECATED: This is a cadvisor flag that was mistakenly registered with the Kubelet. Due to legacy concerns, it will follow the standard CLI deprecation timeline before being removed.)
      --authentication-token-webhook                                                                              Use the TokenReview API to determine authentication for bearer tokens. (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
      --authentication-token-webhook-cache-ttl duration                                                           The duration to cache responses from the webhook token authenticator. (default 2m0s) (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
      --authorization-mode string                                                                                 Authorization mode for Kubelet server. Valid options are AlwaysAllow or Webhook. Webhook mode uses the SubjectAccessReview API to determine authorization. (default "AlwaysAllow") (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
...
```

4. 判断是否为`--version`或`-v`

如果为`version`标识，输出以下内容，退出启动流程

```shell
$ kubelet --version
Kubernetes v1.18.6
```

### 2.设置门控特性

```go
// set feature gates from initial flags-based config
if err := utilfeature.DefaultMutableFeatureGate.SetFromMap(kubeletConfig.FeatureGates); err != nil {
    klog.Fatal(err)
}
```

根据门控特性标识`--feature-gates`设置门控特性，特性包含如下：

```go
--feature-gates mapStringBool                                                                               A set of key=value pairs that describe feature gates for alpha/experimental features. Options are:
        APIListChunking=true|false (BETA - default=true)
        APIPriorityAndFairness=true|false (ALPHA - default=false)
        APIResponseCompression=true|false (BETA - default=true)
        AllAlpha=true|false (ALPHA - default=false)
        AllBeta=true|false (BETA - default=false)
        AllowInsecureBackendProxy=true|false (BETA - default=true)
        AnyVolumeDataSource=true|false (ALPHA - default=false)
        AppArmor=true|false (BETA - default=true)
        BalanceAttachedNodeVolumes=true|false (ALPHA - default=false)
        BoundServiceAccountTokenVolume=true|false (ALPHA - default=false)
        CPUManager=true|false (BETA - default=true)
        CRIContainerLogRotation=true|false (BETA - default=true)
        CSIInlineVolume=true|false (BETA - default=true)
        CSIMigration=true|false (BETA - default=true)
        CSIMigrationAWS=true|false (BETA - default=false)
        CSIMigrationAWSComplete=true|false (ALPHA - default=false)
        CSIMigrationAzureDisk=true|false (ALPHA - default=false)
        CSIMigrationAzureDiskComplete=true|false (ALPHA - default=false)
        CSIMigrationAzureFile=true|false (ALPHA - default=false)
        CSIMigrationAzureFileComplete=true|false (ALPHA - default=false)
        CSIMigrationGCE=true|false (BETA - default=false)
        CSIMigrationGCEComplete=true|false (ALPHA - default=false)
        CSIMigrationOpenStack=true|false (BETA - default=false)
        CSIMigrationOpenStackComplete=true|false (ALPHA - default=false)
        ConfigurableFSGroupPolicy=true|false (ALPHA - default=false)
        CustomCPUCFSQuotaPeriod=true|false (ALPHA - default=false)
        DefaultIngressClass=true|false (BETA - default=true)
        DevicePlugins=true|false (BETA - default=true)
        DryRun=true|false (BETA - default=true)
        DynamicAuditing=true|false (ALPHA - default=false)
        DynamicKubeletConfig=true|false (BETA - default=true)
        EndpointSlice=true|false (BETA - default=true)
        EndpointSliceProxying=true|false (ALPHA - default=false)
        EphemeralContainers=true|false (ALPHA - default=false)
        EvenPodsSpread=true|false (BETA - default=true)
        ExpandCSIVolumes=true|false (BETA - default=true)
        ExpandInUsePersistentVolumes=true|false (BETA - default=true)
        ExpandPersistentVolumes=true|false (BETA - default=true)
        ExperimentalHostUserNamespaceDefaulting=true|false (BETA - default=false)
        HPAScaleToZero=true|false (ALPHA - default=false)
        HugePageStorageMediumSize=true|false (ALPHA - default=false)
        HyperVContainer=true|false (ALPHA - default=false)
        IPv6DualStack=true|false (ALPHA - default=false)
        ImmutableEphemeralVolumes=true|false (ALPHA - default=false)
        KubeletPodResources=true|false (BETA - default=true)
        LegacyNodeRoleBehavior=true|false (ALPHA - default=true)
        LocalStorageCapacityIsolation=true|false (BETA - default=true)
        LocalStorageCapacityIsolationFSQuotaMonitoring=true|false (ALPHA - default=false)
        NodeDisruptionExclusion=true|false (ALPHA - default=false)
        NonPreemptingPriority=true|false (ALPHA - default=false)
        PodDisruptionBudget=true|false (BETA - default=true)
        PodOverhead=true|false (BETA - default=true)
        ProcMountType=true|false (ALPHA - default=false)
        QOSReserved=true|false (ALPHA - default=false)
        RemainingItemCount=true|false (BETA - default=true)
        RemoveSelfLink=true|false (ALPHA - default=false)
        ResourceLimitsPriorityFunction=true|false (ALPHA - default=false)
        RotateKubeletClientCertificate=true|false (BETA - default=true)
        RotateKubeletServerCertificate=true|false (BETA - default=true)
        RunAsGroup=true|false (BETA - default=true)
        RuntimeClass=true|false (BETA - default=true)
        SCTPSupport=true|false (ALPHA - default=false)
        SelectorIndex=true|false (ALPHA - default=false)
        ServerSideApply=true|false (BETA - default=true)
        ServiceAccountIssuerDiscovery=true|false (ALPHA - default=false)
        ServiceAppProtocol=true|false (ALPHA - default=false)
        ServiceNodeExclusion=true|false (ALPHA - default=false)
        ServiceTopology=true|false (ALPHA - default=false)
        StartupProbe=true|false (BETA - default=true)
        StorageVersionHash=true|false (BETA - default=true)
        SupportNodePidsLimit=true|false (BETA - default=true)
        SupportPodPidsLimit=true|false (BETA - default=true)
        Sysctls=true|false (BETA - default=true)
        TTLAfterFinished=true|false (ALPHA - default=false)
        TokenRequest=true|false (BETA - default=true)
        TokenRequestProjection=true|false (BETA - default=true)
        TopologyManager=true|false (BETA - default=true)
        ValidateProxyRedirects=true|false (BETA - default=true)
        VolumeSnapshotDataSource=true|false (BETA - default=true)
        WinDSR=true|false (ALPHA - default=false)
        WinOverlay=true|false (ALPHA - default=false) (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
```

### 3.标识合法性检测

```go
// validate the initial KubeletFlags
if err := options.ValidateKubeletFlags(kubeletFlags); err != nil {
    klog.Fatal(err)
}
```

检测内容如下：

- 如果指定了`--dynamic-config-dir`标识，却未开启`DynamicKubeletConfig`特性门控，返回异常退出启动流程
- `--node-status-max-images`标识值不能小于`-1`
- `--node-labels`节点标签合法性检测

如果运行时标识值为`remote`，并且`--pod-infra-container-image`值非空，会输出警告信息:

```
Warning: For remote container runtime, --pod-infra-container-image is ignored in kubelet, which should be set in that remote runtime instead
```

### 4.配置导入

```go
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
```

> 若`--config`值非空，加载配置文件内容

具体流程如下：
1. 加载文件内容，序列化
2. 在解析完`--config`配置后重新解析命令行标识，避免配置混乱。若配置文件内与命令标识存在相同配置属性，命令行优先级高于配置文件
3. 配置文件内如果存在特新门控配置，则会追加赋值
4. 再次检测配置的合法性，检测内容包参考`kubernetes/pkg/kubelet/apis/config/validation/validation.go`

```go
// ValidateKubeletConfiguration validates `kc` and returns an error if it is invalid
func ValidateKubeletConfiguration(kc *kubeletconfig.KubeletConfiguration) error {
	allErrors := []error{}

	// Make a local copy of the global feature gates and combine it with the gates set by this configuration.
	// This allows us to validate the config against the set of gates it will actually run against.
	localFeatureGate := utilfeature.DefaultFeatureGate.DeepCopy()
	if err := localFeatureGate.SetFromMap(kc.FeatureGates); err != nil {
		return err
	}

	if kc.NodeLeaseDurationSeconds <= 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: NodeLeaseDurationSeconds must be greater than 0"))
	}
	if !kc.CgroupsPerQOS && len(kc.EnforceNodeAllocatable) > 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: EnforceNodeAllocatable (--enforce-node-allocatable) is not supported unless CgroupsPerQOS (--cgroups-per-qos) feature is turned on"))
	}
	if kc.SystemCgroups != "" && kc.CgroupRoot == "" {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: SystemCgroups (--system-cgroups) was specified and CgroupRoot (--cgroup-root) was not specified"))
	}
	if kc.EventBurst < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: EventBurst (--event-burst) %v must not be a negative number", kc.EventBurst))
	}
	if kc.EventRecordQPS < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: EventRecordQPS (--event-qps) %v must not be a negative number", kc.EventRecordQPS))
	}
	if kc.HealthzPort != 0 && utilvalidation.IsValidPortNum(int(kc.HealthzPort)) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: HealthzPort (--healthz-port) %v must be between 1 and 65535, inclusive", kc.HealthzPort))
	}
	if localFeatureGate.Enabled(features.CPUCFSQuotaPeriod) && utilvalidation.IsInRange(int(kc.CPUCFSQuotaPeriod.Duration), int(1*time.Microsecond), int(time.Second)) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: CPUCFSQuotaPeriod (--cpu-cfs-quota-period) %v must be between 1usec and 1sec, inclusive", kc.CPUCFSQuotaPeriod))
	}
	if utilvalidation.IsInRange(int(kc.ImageGCHighThresholdPercent), 0, 100) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: ImageGCHighThresholdPercent (--image-gc-high-threshold) %v must be between 0 and 100, inclusive", kc.ImageGCHighThresholdPercent))
	}
	if utilvalidation.IsInRange(int(kc.ImageGCLowThresholdPercent), 0, 100) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: ImageGCLowThresholdPercent (--image-gc-low-threshold) %v must be between 0 and 100, inclusive", kc.ImageGCLowThresholdPercent))
	}
	if kc.ImageGCLowThresholdPercent >= kc.ImageGCHighThresholdPercent {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: ImageGCLowThresholdPercent (--image-gc-low-threshold) %v must be less than ImageGCHighThresholdPercent (--image-gc-high-threshold) %v", kc.ImageGCLowThresholdPercent, kc.ImageGCHighThresholdPercent))
	}
	if utilvalidation.IsInRange(int(kc.IPTablesDropBit), 0, 31) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: IPTablesDropBit (--iptables-drop-bit) %v must be between 0 and 31, inclusive", kc.IPTablesDropBit))
	}
	if utilvalidation.IsInRange(int(kc.IPTablesMasqueradeBit), 0, 31) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: IPTablesMasqueradeBit (--iptables-masquerade-bit) %v must be between 0 and 31, inclusive", kc.IPTablesMasqueradeBit))
	}
	if kc.KubeAPIBurst < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: KubeAPIBurst (--kube-api-burst) %v must not be a negative number", kc.KubeAPIBurst))
	}
	if kc.KubeAPIQPS < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: KubeAPIQPS (--kube-api-qps) %v must not be a negative number", kc.KubeAPIQPS))
	}
	if kc.MaxOpenFiles < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: MaxOpenFiles (--max-open-files) %v must not be a negative number", kc.MaxOpenFiles))
	}
	if kc.MaxPods < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: MaxPods (--max-pods) %v must not be a negative number", kc.MaxPods))
	}
	if utilvalidation.IsInRange(int(kc.OOMScoreAdj), -1000, 1000) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: OOMScoreAdj (--oom-score-adj) %v must be between -1000 and 1000, inclusive", kc.OOMScoreAdj))
	}
	if kc.PodsPerCore < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: PodsPerCore (--pods-per-core) %v must not be a negative number", kc.PodsPerCore))
	}
	if utilvalidation.IsValidPortNum(int(kc.Port)) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: Port (--port) %v must be between 1 and 65535, inclusive", kc.Port))
	}
	if kc.ReadOnlyPort != 0 && utilvalidation.IsValidPortNum(int(kc.ReadOnlyPort)) != nil {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: ReadOnlyPort (--read-only-port) %v must be between 0 and 65535, inclusive", kc.ReadOnlyPort))
	}
	if kc.RegistryBurst < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: RegistryBurst (--registry-burst) %v must not be a negative number", kc.RegistryBurst))
	}
	if kc.RegistryPullQPS < 0 {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: RegistryPullQPS (--registry-qps) %v must not be a negative number", kc.RegistryPullQPS))
	}
	if kc.RotateCertificates && !localFeatureGate.Enabled(features.RotateKubeletClientCertificate) {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: RotateCertificates %v requires feature gate RotateKubeletClientCertificate", kc.RotateCertificates))
	}
	if kc.ServerTLSBootstrap && !localFeatureGate.Enabled(features.RotateKubeletServerCertificate) {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: ServerTLSBootstrap %v requires feature gate RotateKubeletServerCertificate", kc.ServerTLSBootstrap))
	}
	if kc.TopologyManagerPolicy != kubeletconfig.NoneTopologyManagerPolicy && !localFeatureGate.Enabled(features.TopologyManager) {
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: TopologyManager %v requires feature gate TopologyManager", kc.TopologyManagerPolicy))
	}
	for _, val := range kc.EnforceNodeAllocatable {
		switch val {
		case kubetypes.NodeAllocatableEnforcementKey:
		case kubetypes.SystemReservedEnforcementKey:
			if kc.SystemReservedCgroup == "" {
				allErrors = append(allErrors, fmt.Errorf("invalid configuration: systemReservedCgroup (--system-reserved-cgroup) must be specified when system-reserved contained in EnforceNodeAllocatable (--enforce-node-allocatable)"))
			}
		case kubetypes.KubeReservedEnforcementKey:
			if kc.KubeReservedCgroup == "" {
				allErrors = append(allErrors, fmt.Errorf("invalid configuration: kubeReservedCgroup (--kube-reserved-cgroup) must be specified when kube-reserved contained in EnforceNodeAllocatable (--enforce-node-allocatable)"))
			}
		case kubetypes.NodeAllocatableNoneKey:
			if len(kc.EnforceNodeAllocatable) > 1 {
				allErrors = append(allErrors, fmt.Errorf("invalid configuration: EnforceNodeAllocatable (--enforce-node-allocatable) may not contain additional enforcements when '%s' is specified", kubetypes.NodeAllocatableNoneKey))
			}
		default:
			allErrors = append(allErrors, fmt.Errorf("invalid configuration: option %q specified for EnforceNodeAllocatable (--enforce-node-allocatable). Valid options are %q, %q, %q, or %q",
				val, kubetypes.NodeAllocatableEnforcementKey, kubetypes.SystemReservedEnforcementKey, kubetypes.KubeReservedEnforcementKey, kubetypes.NodeAllocatableNoneKey))
		}
	}
	switch kc.HairpinMode {
	case kubeletconfig.HairpinNone:
	case kubeletconfig.HairpinVeth:
	case kubeletconfig.PromiscuousBridge:
	default:
		allErrors = append(allErrors, fmt.Errorf("invalid configuration: option %q specified for HairpinMode (--hairpin-mode). Valid options are %q, %q or %q",
			kc.HairpinMode, kubeletconfig.HairpinNone, kubeletconfig.HairpinVeth, kubeletconfig.PromiscuousBridge))
	}
	if kc.ReservedSystemCPUs != "" {
		// --reserved-cpus does not support --system-reserved-cgroup or --kube-reserved-cgroup
		if kc.SystemReservedCgroup != "" || kc.KubeReservedCgroup != "" {
			allErrors = append(allErrors, fmt.Errorf("can't use --reserved-cpus with --system-reserved-cgroup or --kube-reserved-cgroup"))
		}
		if _, err := cpuset.Parse(kc.ReservedSystemCPUs); err != nil {
			allErrors = append(allErrors, fmt.Errorf("unable to parse --reserved-cpus, error: %v", err))
		}
	}

	if err := validateKubeletOSConfiguration(kc); err != nil {
		allErrors = append(allErrors, err)
	}
	allErrors = append(allErrors, metrics.ValidateShowHiddenMetricsVersion(kc.ShowHiddenMetricsForVersion)...)
	return utilerrors.NewAggregate(allErrors)
}

```

> 若`--dynamic-config-dir`值非空，`kubelet`将使用此目录对下载的配置进行检查点和跟踪配置运行状况。
如果该目录不存在，`kubelet`将创建该目录。路径可以是绝对的，也可以是相对的。
相对路径从`kubelet`的当前工作目录开始。提供此标志将启用动态`kubelet`配置。必须启用`DynamicKubeletConfig`特性门才能通过该标志;这个门目前默认为`true`，因为该功能处于`beta`版。

关于`kubelet`动态配置解析请参考[Dynamic Kubelet Configuration](https://kubernetes.io/blog/2018/07/11/dynamic-kubelet-configuration/)

同时定义`--dynamic-config-dir`与`--config`时，`kubelet`会`--dynamic-config-dir`中的动态配置。`--config`的配置不会生效

### 5.启动dockershim

当指定开启`dockershim only`模式时，才会走这个启动逻辑

```go
// start the experimental docker shim, if enabled
if kubeletServer.KubeletFlags.ExperimentalDockershim {
    if err := RunDockershim(&kubeletServer.KubeletFlags, kubeletConfig, stopCh); err != nil {
        klog.Fatal(err)
    }
    return
}
```

一般用于测试容器运行时，官方考虑后续提供独立的二进制文件，我们暂且不做讨论。

### 6.启动server前的准备

经过前几个步骤的准备，我们已经获取了`kubelet`的配置参数，接下来我们分析启动前还需要做哪些准备：

```go
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
```

透过源码我们了解了最后的`Run`函数执行启动的逻辑，而他需要四个参数：
- 参数一`*options.KubeletServer`: 包含`kubelet`启动所需的配置项与标识集合
- 参数二`*kubelet.Dependencies`: 实质是一个`注入依赖`的容器--在运行时构造的对象，这些对象是运行`Kubelet`所必需的。(如：想操作容器时，得需要实现容器运行时接口)
- 参数三`featuregate.FeatureGate`: 特性门控列表，决定开启/关闭那些特性
- 参数四`<-chan struct{}`: 用于作为主程序退出的信号通知其他各协程进行相关的退出操作

参数一、三、四很好理解，我们着重分析下`*kubelet.Dependencies`这个入参对象

> `kubelet.Dependencies`结构体解析

`kubelet`初始化阶段，通过`KubeletServer`、`DefaultFeatureGate`入参实例化

```go
// use kubeletServer to construct the default KubeletDeps
kubeletDeps, err := UnsecuredDependencies(kubeletServer, utilfeature.DefaultFeatureGate)
if err != nil {
    klog.Fatal(err)
}

// add the kubelet config controller to kubeletDeps
kubeletDeps.KubeletConfigController = kubeletConfigController
```

我们看下`kubelet.Dependencies`结构体属性:

```go
type Dependencies struct {
	Options []Option

	// Injected Dependencies
	Auth                    server.AuthInterface
	CAdvisorInterface       cadvisor.Interface
	Cloud                   cloudprovider.Interface
	ContainerManager        cm.ContainerManager
	DockerClientConfig      *dockershim.ClientConfig
	EventClient             v1core.EventsGetter
	HeartbeatClient         clientset.Interface
	OnHeartbeatFailure      func()
	KubeClient              clientset.Interface
	Mounter                 mount.Interface
	HostUtil                hostutil.HostUtils
	OOMAdjuster             *oom.OOMAdjuster
	OSInterface             kubecontainer.OSInterface
	PodConfig               *config.PodConfig
	Recorder                record.EventRecorder
	Subpather               subpath.Interface
	VolumePlugins           []volume.VolumePlugin
	DynamicPluginProber     volume.DynamicPluginProber
	TLSOptions              *server.TLSOptions
	KubeletConfigController *kubeletconfig.Controller
	RemoteRuntimeService    internalapi.RuntimeService
	RemoteImageService      internalapi.ImageManagerService
	criHandler              http.Handler
	dockerLegacyService     dockershim.DockerLegacyService
	// remove it after cadvisor.UsingLegacyCadvisorStats dropped.
	useLegacyCadvisorStats bool
}
```

我们看到`kubelet.Dependencies`其实是一个接口集合，包括对卷、容器运行时、`kube-apiserver`等操作的接口。针对这些接口的使用场景及实现我们不做过多讨论。

至此为止，所有的启动前准备工作均已完成（配置项，运行时所需接口），接下来我们将分析`kubelet`实际运行流程(`Run`函数)