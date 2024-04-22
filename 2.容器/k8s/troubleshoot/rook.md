## 挂载Pvc失败提示已被占用

错误描述：

```shell
image replicapool/csi-vol-1d14612c-6e37-11ee-a86b-5a729ca4e4e3 is still being used
```

**解决流程：**

查询rbd对象管理端Pod

```shell
for pod in `kubectl -n rook-ceph get pods|grep rbdplugin|grep -v provisioner|awk '{print $1}'`; do echo $pod; kubectl exec -it -n rook-ceph $pod -c csi-rbdplugin -- rbd device list; done|grep csi-vol-1d14612c-6e37-11ee-a86b-5a729ca4e4e3 -C 3
```

连接rbd csi-rbdplugin

```shell
kubectl exec -it csi-rbdplugin-8w8wx -n rook-ceph -c csi-rbdplugin -- bash
```

确认

```shell
rbd device list|grep csi-vol-1d14612c-6e37-11ee-a86b-5a729ca4e4e3
0   replicapool             csi-vol-1d14612c-6e37-11ee-a86b-5a729ca4e4e3  -     /dev/rbd0
```

强制卸载映射

```shell
rbd unmap  -o force /dev/rbd0
```

恢复使用