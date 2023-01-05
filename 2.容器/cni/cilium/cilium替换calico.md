###

```shell
kubectl -n kube-system delete ds calico-node
kubectl -n kube-system delete deploy calico-kube-controllers
kubectl -n kube-system delete sa calico-node
kubectl -n kube-system delete sa calico-kube-controllers
kubectl -n kube-system delete cm calico-config
kubectl -n kube-system delete secret calico-config
kubectl get crd | grep calico | awk '{print $1}' | xargs kubectl delete crd
```

```shell
helm install cilium devops/cilium --version 1.12.3 \
   --namespace kube-system\
   --set hubble.metrics.enabled="{dns:query;ignoreAAAA;destinationContext=pod-short,drop:sourceContext=pod;destinationContext=pod,tcp,flow,port-distribution,icmp,http}" \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true
```

```shell
[root@node1 ~]# kubectl -n kube-system get svc hubble-ui
NAME        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
hubble-ui   ClusterIP   10.233.21.93   <none>        80/TCP    18s
[root@node1 ~]# kubectl -n kube-system patch svc hubble-ui -p '{"spec": {"type": "NodePort"}}'
service/hubble-ui patched
[root@node1 ~]# kubectl -n kube-system get svc hubble-ui
NAME        TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
hubble-ui   NodePort   10.233.21.93   <none>        80:30065/TCP   28s
```


https://www.cnblogs.com/dudu/p/16269093.html

查看模式

```shell
$ kubectl exec -it -n kube-system ds/cilium -- cilium status | grep KubeProxyReplacement
```

查看服务列表

```shell
$ kubectl exec -it -n kube-system daemonset/cilium -- cilium service list
```

删除iptables

```shell
$ iptables-save | grep -v KUBE | iptables-restore
```

```shell
$ # 首先备份 kube-system ConfigMap
$ kubectl get cm kube-proxy -n kube-system -o yaml > kube-proxy-cm.yaml
$ kubectl -n kube-system delete ds kube-proxy
$ kubectl -n kube-system delete cm kube-proxy
```