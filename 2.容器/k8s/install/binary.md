# 二进制安装

## 编译源码

### 安装golang

> 下载解压配置

```bash
tar zxvf go1.16.5.linux-amd64.tar.gz -C /usr/local/
cat >> ~/.bash_profile <<EOF
export GOPROOT=/usr/local/go
export PATH=\$PATH:\$GOPROOT/bin
EOF
. ~/.bash_profile
```

### 编译全部组件

```bash
unzip kubernetes-1.18.6.zip
cd kubernetes-1.18.6
yum install -y rsync
rm -rf _output
make -j4
```

## 安装k8s主节点

### 安装etcd

> 下载解压`etcd`

- [etcd-v3.3.9-linux-amd64.tar.gz](https://github.com/etcd-io/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz)

```bash
tar -zxvf etcd-v3.3.9-linux-amd64.tar.gz
sudo cp etcd-v3.3.9-linux-amd64/{etcd,etcdctl}  /usr/bin/
```

> 配置服务

```bash
sudo tee /usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/etcd
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/bin/etcd

[Install]
WantedBy=multi-user.target
EOF
```

> 创建目录

```bash
mkdir /var/lib/etcd
```

> 启动

```bash
sudo systemctl daemon-reload
sudo systemctl enable etcd.service --now
```

> 查看集群状态

```bash
[root@localhost ~]# etcdctl cluster-health
member 8e9e05c52164694d is healthy: got healthy result from http://localhost:2379
cluster is healthy
```

### 

> 上传启动






