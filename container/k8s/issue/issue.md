- [cgroups导致的内存泄露](https://www.cnblogs.com/zhangmingcheng/p/14309962.html)
- []()

## 网络

### calico

> 1.异常: `calico/node is not ready: BIRD is not ready: BGP not established with x.x.x.x`

此时状态为: 运行中但未`READY`
```shell
[root@k8s-master ~]# kubectl get pod -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-578894d4cd-gxfw2   1/1     Running   0          82m
kube-system   calico-node-jzjj5                          0/1     Running   0          15s
kube-system   calico-node-vwfrr                          0/1     Running   0          15s
```

解决方式

```shell
kubectl edit ds -n kube-system calico-node
```

`spec.template.spec.containers`下新增如下环境变量（注意缩进不能用`tab`）

```shell
- name: IP_AUTODETECTION_METHOD
  value: interface=ens.*
```
