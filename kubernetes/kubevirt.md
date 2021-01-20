
## 集成部署

### 依赖检测

- 内核：`5.10.2-1.el7.elrepo.x86_64`

- 操作系统：`CentOS Linux release 7.9.2009 (Core)`

- docker：`20.10.1`
    
- kubernetes：`v1.18.6`
    
- KubeVirt：`v0.35.0`
    

> 检测宿主是否满足虚拟化条件

安装`libvirt-client`

    yum install -y libvirt-client
    
检测

    [root@node3 ~]# virt-host-validate qemu
      QEMU: Checking for hardware virtualization                                 : PASS
      QEMU: Checking if device /dev/kvm exists                                   : PASS
      QEMU: Checking if device /dev/kvm is accessible                            : PASS
      QEMU: Checking if device /dev/vhost-net exists                             : PASS
      QEMU: Checking if device /dev/net/tun exists                               : PASS
      QEMU: Checking for cgroup 'memory' controller support                      : PASS
      QEMU: Checking for cgroup 'memory' controller mount-point                  : PASS
      QEMU: Checking for cgroup 'cpu' controller support                         : PASS
      QEMU: Checking for cgroup 'cpu' controller mount-point                     : PASS
      QEMU: Checking for cgroup 'cpuacct' controller support                     : PASS
      QEMU: Checking for cgroup 'cpuacct' controller mount-point                 : PASS
      QEMU: Checking for cgroup 'cpuset' controller support                      : PASS
      QEMU: Checking for cgroup 'cpuset' controller mount-point                  : PASS
      QEMU: Checking for cgroup 'devices' controller support                     : PASS
      QEMU: Checking for cgroup 'devices' controller mount-point                 : PASS
      QEMU: Checking for cgroup 'blkio' controller support                       : PASS
      QEMU: Checking for cgroup 'blkio' controller mount-point                   : PASS
      QEMU: Checking for device assignment IOMMU support                         : PASS
      QEMU: Checking if IOMMU is enabled by kernel                               : WARN (IOMMU appears to be disabled in kernel. Add intel_iommu=on to kernel cmdline arguments)
      
> 处理`IOMMU`告警

- 方法一

修改`GRUB_CMDLINE_LINUX`添加`intel_iommu=on`
    
修改前

    [root@node3 ~]# cat /etc/default/grub
    GRUB_TIMEOUT=5
    GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
    GRUB_DEFAULT=saved
    GRUB_DISABLE_SUBMENU=true
    GRUB_TERMINAL_OUTPUT="console"
    GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos00/root rhgb quiet"
    GRUB_DISABLE_RECOVERY="true"
    
修改后

    GRUB_TIMEOUT=5
    GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
    GRUB_DEFAULT=saved
    GRUB_DISABLE_SUBMENU=true
    GRUB_TERMINAL_OUTPUT="console"
    GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos00/root rhgb quiet intel_iommu=on"
    GRUB_DISABLE_RECOVERY="true"

重建内核引导文件

    grub2-mkconfig -o /boot/grub2/grub.cfg
    dracut --regenerate-all --force
    
重启

    reboot
    
验证

    cat /proc/cmdline |grep intel_iommu=on
    
如返回为空，尝试方法二
    
- 方法二

查询引导文件

    [root@node3 ~]# find / -name "grub.cfg"
    /boot/efi/EFI/centos/grub.cfg
    /boot/grub2/grub.cfg
    
修改`/boot/efi/EFI/centos/grub.cfg`文件内容

修改前

    linuxefi /vmlinuz-5.10.2-1.el7.elrepo.x86_64 root=/dev/mapper/centos00-root ro crashkernel=auto rd.lvm.lv=centos00/root rhgb quiet LANG=en_US.UTF-8
    
修改后

    linuxefi /vmlinuz-5.10.2-1.el7.elrepo.x86_64 root=/dev/mapper/centos00-root ro crashkernel=auto rd.lvm.lv=centos00/root rhgb quiet intel_iommu=on LANG=en_US.UTF-8

重建内核引导文件

    grub2-mkconfig -o /boot/grub2/grub.cfg
    dracut --regenerate-all --force
    
重启

    reboot
    
验证

    cat /proc/cmdline |grep intel_iommu=on

### 部署KubeVirt operator

> 下载`kubevirt-operator.yaml`

- [v0.35.0版本下载链接](https://github.com/kubevirt/kubevirt/releases/download/v0.35.0/kubevirt-operator.yaml)

> 下载`kubevirt operator`所需镜像

镜像列表

    kubevirt/virt-operator:v0.35.0
    kubevirt/virt-api:v0.35.0
    kubevirt/virt-controller:v0.35.0
    kubevirt/virt-handler:v0.35.0

修改镜像tag，修改后如下

    harbor.neusoft.com/kubevirt/virt-operator:v0.35.0
    harbor.neusoft.com/kubevirt/virt-api:v0.35.0
    harbor.neusoft.com/kubevirt/virt-controller:v0.35.0
    harbor.neusoft.com/kubevirt/virt-handler:v0.35.0
    
推送至私有仓库

    docker push harbor.neusoft.com/kubevirt/virt-operator:v0.35.0
    docker push harbor.neusoft.com/kubevirt/virt-api:v0.35.0
    docker push harbor.neusoft.com/kubevirt/virt-controller:v0.35.0
    docker push harbor.neusoft.com/kubevirt/virt-handler:v0.35.0
    
> 上传`kubevirt-operator.yaml`并调整镜像tag

    ...
    containers:
        - command:
        - virt-operator
        - --port
        - "8443"
        - -v
        - "2"
        env:
        - name: OPERATOR_IMAGE
          value: harbor.neusoft.com/kubevirt/virt-operator:v0.35.0
        - name: WATCH_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.annotations['olm.targetNamespaces']
        - name: KUBEVIRT_VERSION
          value: v0.35.0
        - name: VIRT_API_SHASUM
          value: sha256:bf38c1997f3c60a71d53b956f235973834d37c0c604b5711084b2a7ef8cd3c7b
        - name: VIRT_CONTROLLER_SHASUM
          value: sha256:7b81c59034df51c1a1f54d3180e0df678469790b6a8ac4fcc5fcaa615b1ca84c
        - name: VIRT_HANDLER_SHASUM
          value: sha256:14b4bd6d62b585ef2f4dbacafc75a66a6c575c64ed630835cf4ef6c0f77d40d1
        - name: VIRT_LAUNCHER_SHASUM
          value: sha256:a6d9f1dada1d33a218ba9ed0494d2e2cd09f5596eff5eb5b8d70bfe1fd4f8812
        image: harbor.neusoft.com/kubevirt/virt-operator:v0.35.0
    ...
    
上传k8s节点发布

    kubectl apply -f kubevirt-operator.yaml

### 部署KubeVirt CR

> 下载`kubevirt-cr.yaml`

- [v0.35.0版本下载链接](https://github.com/kubevirt/kubevirt/releases/download/v0.35/kubevirt-cr.yaml)
    
> 上传k8s节点发布

    kubectl apply -f kubevirt-cr.yaml
    
> 等待组件启动

    kubectl -n kubevirt wait kv kubevirt --for condition=Available
        