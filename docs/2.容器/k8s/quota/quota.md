- [配额](#%E9%85%8D%E9%A2%9D)
  - [相关概念](#%E7%9B%B8%E5%85%B3%E6%A6%82%E5%BF%B5)
  - [配额限制维度](#%E9%85%8D%E9%A2%9D%E9%99%90%E5%88%B6%E7%BB%B4%E5%BA%A6)
    - [节点级计算资源限制](#%E8%8A%82%E7%82%B9%E7%BA%A7%E8%AE%A1%E7%AE%97%E8%B5%84%E6%BA%90%E9%99%90%E5%88%B6)
    - [命名空间级计算资源限制](#%E5%91%BD%E5%90%8D%E7%A9%BA%E9%97%B4%E7%BA%A7%E8%AE%A1%E7%AE%97%E8%B5%84%E6%BA%90%E9%99%90%E5%88%B6)
    - [命名空间容器默认配额设置](#%E5%91%BD%E5%90%8D%E7%A9%BA%E9%97%B4%E5%AE%B9%E5%99%A8%E9%BB%98%E8%AE%A4%E9%85%8D%E9%A2%9D%E8%AE%BE%E7%BD%AE)
    - [容器级计算资源限制](#%E5%AE%B9%E5%99%A8%E7%BA%A7%E8%AE%A1%E7%AE%97%E8%B5%84%E6%BA%90%E9%99%90%E5%88%B6)
  - [参考文档](#%E5%8F%82%E8%80%83%E6%96%87%E6%A1%A3)

# 配额

## 相关概念

> `request`与`limits`

`Kubernetes`采用`request`和`limit`两种限制类型来对资源进行分配
- `request`(资源需求)：即运行`Pod`的节点必须满足运行`Pod`的最基本需求才能运行`Pod`
- `limits`(资源限额)：描述`Pod`运行期间，内存最大可申请大小

一个容器申请`0.5个CPU`，就相当于申请`1`个`CPU`的一半，加个后缀`m`表示千分之一的概念。
比如说`100m`的`CPU`，表示0.1个`cpu`

> 配额与`Pod`优先级关系

- `Request=Limit`: `Pod`类型为`Guaranted`（保证型），只有内存使用量超限（OOM）时才会被`kill`
- `Request<Limit`: `Pod`类型为`Burstable`(突发流量型)，节点计算资源不足时，可能会被`kill`回收
- 未设置`Request Limit`: `Pod`类型为`Best Effort`（尽最大努力型），节点计算资源不足时，会被首先`kill`

## 配额限制维度

### 节点级计算资源限制

- `Kubelet Node Allocatable`用来为`Kube`组件和`System`进程预留资源，
从而保证当节点出现满负荷时也能保证`k8s`系统服务和`System`宿主机守护进程有足够的资源

- `Node Capacity`: `Node`的所有硬件资源
- `kube-reserved`: `kube`组件预留的资源
- `system-reserved`: `System`进程预留的资源
- `eviction-threshold`（阈值）: `kubelet eviction`(回收)的阈值设定
- `allocatable`: 真正`scheduler`调度`Pod`时的参考值（保证`Node`上所有`Pods`的`request resource`不超过`Allocatable`）

> 查看当前节点的`Capacity`和`Allocatable`

    [root@node1 ~]# kubectl describe node node1
    ...
    Capacity:
      cpu:                4
      ephemeral-storage:  17394Mi
      hugepages-1Gi:      0
      hugepages-2Mi:      0
      memory:             4004944Ki
      pods:               300
    Allocatable:
      cpu:                3600m
      ephemeral-storage:  17394Mi
      hugepages-1Gi:      0
      hugepages-2Mi:      0
      memory:             3371721521
      pods:               300
      ...
      
> 查看`docker`驱动

`cgroup`驱动如果为`systemd`，则开启不了`Kubelet Node Allocatable`

    [root@node1 ~]# docker info | grep "Cgroup Driver"
     Cgroup Driver: systemd
     
> 调整`docker`驱动为`cgroupfs`

调整`/etc/docker/daemon.json`内容，添加/修改以下值（需升级内核）

    "exec-opts": ["native.cgroupdriver=cgroupfs"]

重启`docker`

    systemctl daemon-reload
    systemctl restart docker
     
> 调整`kubelet`参数配置

修改`/var/lib/kubelet/kubeadm-flags.env`，调整/增加以下参数：

    # 修改`kubelet cgroup`驱动`systemd`为`cgroupfs`
    --cgroup-driver=cgroupfs
    # 开启为kube组件和系统守护进程预留资源的功能
    --enforce-node-allocatable=pods,kube-reserved,system-reserved
    # 设置k8s组件的cgroup
    --kube-reserved-cgroup=/system.slice/kubelet.service
    # 设置系统守护进程的cgroup
    --system-reserved-cgroup=/system.slice
    # 配置为k8s组件预留资源的大小，CPU、MEM
    --kube-reserved=cpu=1,memory=1Gi
    # 配置为系统进程（诸如 sshd、udev 等系统守护进程）预留资源的大小，CPU、MEM
    --system-reserved=cpu=0.5,memory=1Gi
    # 驱逐pod的配置：硬阈值（保证95%的内存利用率)
    --eviction-hard=memory.available<5%,nodefs.available<10%,imagefs.available<10%
    # 驱逐pod的配置：软阈值
    --eviction-soft=memory.available<10%,nodefs.available<15%,imagefs.available<15%
    # 定义达到软阈值之后，持续时间超过多久才进行驱逐
    --eviction-soft-grace-period=memory.available=2m,nodefs.available=2m,imagefs.available=2m
    # 驱逐pod前最大等待时间=min(pod.Spec.TerminationGracePeriodSeconds, eviction-max-pod-grace-period)，单位秒
    --eviction-max-pod-grace-period=30
    # 至少回收多少资源，才停止驱逐
    --eviction-minimum-reclaim=memory.available=0Mi,nodefs.available=500Mi,imagefs.available=500Mi
    
> 调整`kubelet.service`

调整文件`/etc/systemd/system/kubelet.service`

修改前

    [Unit]
    Description=kubelet: The Kubernetes Node Agent
    Documentation=http://kubernetes.io/docs/
    
    [Service]
    ExecStart=/usr/local/bin/kubelet
    Restart=always
    StartLimitInterval=0
    RestartSec=10
    
    [Install]
    WantedBy=multi-user.target
    
修改后

    [Unit]
    Description=kubelet: The Kubernetes Node Agent
    Documentation=http://kubernetes.io/docs/
    
    [Service]
    ExecStartPre=/bin/mkdir -p /sys/fs/cgroup/cpuset/system.slice/kubelet.service
    ExecStartPre=/bin/mkdir -p /sys/fs/cgroup/hugetlb/system.slice/kubelet.service
    ExecStart=/usr/local/bin/kubelet
    Restart=always
    StartLimitInterval=0
    RestartSec=10
    
    [Install]
    WantedBy=multi-user.target
    
> 重启`kubelet`再次查看节点的`Capacity`和`Allocatable`

    [root@node1 ~]# systemctl daemon-reload
    [root@node1 ~]# systemctl restart kubelet
    [root@node1 ~]# kubectl describe node node1
    ...
    Capacity:
      cpu:                4
      ephemeral-storage:  17394Mi
      hugepages-1Gi:      0
      hugepages-2Mi:      0
      memory:             4004944Ki
      pods:               300
    Allocatable:
      cpu:                2500m
      ephemeral-storage:  14267554175
      hugepages-1Gi:      0
      hugepages-2Mi:      0
      memory:             1748525873
      pods:               300
    ...
    
> 官方的样例说明

这是一个用于说明节点可分配（`Node Allocatable`）计算方式的示例：
    
- 节点拥有`32Gi memeory`，`16 CPU`和`100Gi Storage`资源: 
    - `--kube-reserved`被设置为`cpu=1,memory=2Gi,ephemeral-storage=1Gi`
    - `--system-reserved`被设置为`cpu=500m,memory=1Gi,ephemeral-storage=1Gi`
    - `--eviction-hard`被设置为`memory.available<500Mi,nodefs.available<10%`
    
在这个场景下，`Allocatable`将会是`14.5 CPUs`、`28.5Gi`内存以及`88Gi`本地存储。 调度器保证这个节点上的所有`Pod`的内存`requests`总量不超过`28.5Gi`，存储不超过`88Gi`。 
当`Pod`的内存使用总量超过`28.5Gi`或者磁盘使用总量超过`88Gi`时， `kubelet`将会驱逐它们。
如果节点上的所有进程都尽可能多地使用`CPU`，则`Pod`加起来不能使用超过`14.5 CPUs`的资源。
    
当没有执行`kube-reserved`和/或`system-reserved`策略且系统守护进程 使用量超过其预留时，
如果节点内存用量高于`31.5Gi`或存储大于`90Gi`，`kubelet`将会驱逐`Pod`

### 命名空间级计算资源限制

> 设置限定对象数据的资源配额

指定命名空间`test01`生效

    cat <<EOF | kubectl -n test01 apply -f -
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: object-counts
    spec:
      hard:
        persistentvolumeclaims: "2" # 持久存储卷
        services.loadbalancers: "2" # 负载均衡器
        services.nodeports: "0" # NodePort 数量
    EOF

> 设置限定计算资源配额限制

指定命名空间`test01`生效

    cat <<EOF | kubectl -n test01 apply -f -
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: compute-resources
    spec:
      hard:
        pods: "4"
        requests.cpu: "1"
        requests.memory: 1Gi
        limits.cpu: "2"
        limits.memory: 2Gi
    EOF

### 命名空间容器默认配额设置

**缺省值**

> 创建测试命名空间

    kubectl create ns test01

> 创建命名空间容器默认配额设置

    cat <<EOF | kubectl -n test01 apply -f -
    apiVersion: v1 
    kind: LimitRange 
    metadata:  
      name: limitrange-memory 
    spec:  
      limits:  
      - default:
          memory: 512Mi # default limit
        defaultRequest:  
          memory: 256Mi # default request  
        max:      
          memory: 1Gi   # max limit
        min:      
          memory: 100Mi # min request   
        type: Container
    EOF
    
            
- 容器如果未声明`request`与`limits` -> 会根据命名空间下`LimitRange`策略对容器配额赋值
- 容器如果声明`limits`未声明`request` -> 则容器的内存`request`和`limits`值一致
- 容器如果声明`request`,未声明`limits` -> 容器`request`值被设置为声明的值，`limits`被设置成了`LimitRange`值

### 容器级计算资源限制

针对业务容器设置配额

    apiVersion: v1
    kind: Pod
    metadata:
      name: frontend
    spec:
      containers:
      - name: db
        image: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password"
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
      - name: wp
        image: wordpress
        resources:
          requests:
            memory: "64M"
            cpu: "0.25"
          limits:
            memory: "128M"
            cpu: "0.5"

## 参考文档

- [k8s 节点可分配资源限制 Node Allocatable](https://www.jianshu.com/p/703c3ad4991f)
- [k8s官方文档](https://kubernetes.io/zh/docs/tasks/administer-cluster/reserve-compute-resources/)
