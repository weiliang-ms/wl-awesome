```shell
sudo rm -rvf $HOME/.kube
sudo rm -rvf ~/.kube/
sudo rm -rvf /etc/kubernetes/
sudo rm -rvf /etc/systemd/system/kubelet.service.d
sudo rm -rvf /etc/systemd/system/kubelet.service
sudo rm -rvf /usr/bin/kube*
sudo rm -rvf /etc/cni
sudo rm -rvf /opt/cni
sudo rm -rvf /var/lib/etcd
sudo rm -rvf /var/etcd

docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi -f $(docker images -q)

yum remove docker-ce -y
rm -rf /var/lib/docker*
rm -f /usr/bin/docker

rm -rf /var/lib/kubelet
mount | grep '/var/lib/kubelet'| awk '{print $3}'|xargs sudo umount
sudo iptables -F && sudo iptables -X && sudo iptables -F -t nat && sudo iptables -X -t nat

 
```

