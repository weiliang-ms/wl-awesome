### 禁止/允许调度


允许调度

    kubectl patch node <NodeName> -p "{\"spec\":{\"unschedulable\":false}}"
    
修改默认sc

    kubectl patch storageclass <sc-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
