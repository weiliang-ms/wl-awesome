### 禁止/允许调度


允许调度

    kubectl patch node <NodeName> -p "{\"spec\":{\"unschedulable\":false}}"
    
修改默认sc

    kubectl patch storageclass <sc-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

节点标签

    # kubectl label nodes <node-name> key=value
    kubectl label nodes ceph01 role=storage-node
    
> 驱逐业务容器

    kubectl drain --ignore-daemonsets --delete-local-data <node name>
    
> 清理`Evicted`状态`pod`

```shell script

for ns in `kubectl get ns | awk 'NR>1{print $1}'`
do
  kubectl get pods -n ${ns} | grep Evicted | awk '{print $1}' | xargs kubectl delete pod -n ${ns}
done
```
    
### 配置

> 修改`kubernetes`限制节点`pod`数量

**默认100**

编辑

    vim /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
    
调整修改

    Environment="KUBELET_NODE_MAX_PODS=--max-pods=600"
    ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS $KUBELET_NODE_MAX_PODS

重启kubelet

    systemctl daemon-reload
    systemctl restart kubelet

> 删除命名空间
[reason](https://www.yuque.com/imroc/kubernetes-troubleshooting/pnl1nf)
ceph-csi注意替换

    curl -H "Content-Type: application/json" -XPUT -d '{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"ceph-csi"},"spec":{"finalizers":[]}}' http://localhost:8001/api/v1/namespaces/ceph-csi/finalize
    
> [变更default StorageClass](https://blog.csdn.net/engchina/article/details/88529380)
  
    kubectl patch storageclass <your-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

- 检查证书是否过期


      kubeadm alpha certs check-expiration
      
![](images/outofdate.jpg)

- 手动更新证书


      kubeadm alpha certs renew