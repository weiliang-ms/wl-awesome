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

```bash
for ns in `kubectl get ns | awk 'NR>1{print $1}'`
do
  kubectl get pods -n ${ns} | grep Evicted | awk '{print $1}' | xargs kubectl delete pod -n ${ns}
done
```
    
### 配置

> 修改`kubernetes`限制节点`pod`数量

**默认100**

编辑

```shell
vim /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
```
    
调整修改

    Environment="KUBELET_NODE_MAX_PODS=--max-pods=600"
    ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS $KUBELET_NODE_MAX_PODS

重启kubelet

```shell
systemctl daemon-reload
systemctl restart kubelet
```

> 删除命名空间
[reason](https://www.yuque.com/imroc/kubernetes-troubleshooting/pnl1nf)
ceph-csi注意替换

    curl -H "Content-Type: application/json" -XPUT -d '{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"ceph-csi"},"spec":{"finalizers":[]}}' http://localhost:8001/api/v1/namespaces/ceph-csi/finalize
    
> [变更default StorageClass](https://blog.csdn.net/engchina/article/details/88529380)
```shell
kubectl patch storageclass <your-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```
- 检查证书是否过期


```shell
kubeadm alpha certs check-expiration
```
      
或

```shell
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text |grep ' Not '
```
      
![](images/outofdate.jpg)

- 手动更新证书

```shell
kubeadm alpha certs renew all
docker ps | grep -v pause | grep -E "etcd|scheduler|controller|apiserver" | awk '{print $1}' | awk '{print "docker","restart",$1}' | bash
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

> 删除孤儿`Pod`

```shell
#!/bin/sh

orphanedPods=`cat /var/log/messages|grep 'orphaned pod'|awk -F '"' '{print $2}'|uniq`;
orphanedPodsNum=`echo $orphanedPods|awk -F ' ' '{print NF}'`;
echo -e "orphanedPods: $orphanedPodsNum \n$orphanedPods";

for i in $orphanedPods
do
echo "Deleting Orphaned pod id: $i";
rm -rf /var/lib/kubelet/pods/$i;
done
```

```shell
+-----------------------------------------------------------------------+------------------+-------------------+---------------+-----------+
|                             CONTROL NAME                              | FAILED RESOURCES | WARNING RESOURCES | ALL RESOURCES | % SUCCESS |
+-----------------------------------------------------------------------+------------------+-------------------+---------------+-----------+
| Allow privilege escalation                                            | 0                | 0                 | 267           | 100%      |
| Allowed hostPath                                                      | 103              | 0                 | 267           | 61%       |
| Applications credentials in configuration files                       | 13               | 0                 | 499           | 97%       |
| Automatic mapping of service account                                  | 72               | 0                 | 72            | 0%        |
| CVE-2021-25741 - Using symlink for arbitrary host file system access. | 2                | 0                 | 274           | 99%       |
| Cluster-admin binding                                                 | 12               | 0                 | 851           | 98%       |
| Container hostPort                                                    | 2                | 0                 | 267           | 99%       |
| Control plane hardening                                               | 0                | 0                 | 267           | 100%      |
| Dangerous capabilities                                                | 1                | 0                 | 267           | 99%       |
| Exec into container                                                   | 13               | 0                 | 851           | 98%       |
| Exposed dashboard                                                     | 0                | 0                 | 336           | 100%      |
| Host PID/IPC privileges                                               | 1                | 0                 | 267           | 99%       |
| Immutable container filesystem                                        | 267              | 0                 | 267           | 0%        |
| Ingress and Egress blocked                                            | 267              | 0                 | 267           | 0%        |
| Insecure capabilities                                                 | 0                | 0                 | 267           | 100%      |
| Linux hardening                                                       | 265              | 0                 | 267           | 0%        |
| Network policies                                                      | 26               | 0                 | 26            | 0%        |
| Non-root containers                                                   | 7                | 0                 | 267           | 97%       |
| Privileged container                                                  | 1                | 0                 | 267           | 99%       |
| Resource policies                                                     | 189              | 0                 | 267           | 29%       |
| hostNetwork access                                                    | 3                | 0                 | 267           | 98%       |
+-----------------------------------------------------------------------+------------------+-------------------+---------------+-----------+
|                                  21                                   |       1244       |         0         |     6647      |    81%    |
+-----------------------------------------------------------------------+------------------+-------------------+---------------+-----------+

```