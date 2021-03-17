### 禁止/允许调度


允许调度

    kubectl patch node <NodeName> -p "{\"spec\":{\"unschedulable\":false}}"
    
修改默认sc

    kubectl patch storageclass <sc-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

节点标签

    # kubectl label nodes <node-name> key=value
    kubectl label nodes ceph01 role=storage-node
    
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

    