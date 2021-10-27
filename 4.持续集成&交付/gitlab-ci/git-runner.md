## 离线安装

- [下载地址](https://mirrors.tuna.tsinghua.edu.cn/gitlab-runner/yum/el7/)

> 安装

```shell
yum localinstall gitlab-runner-13.11.0-1.x86_64.rpm -y
```

> 启动

```shell
systemctl enable gitlab-runner --now
```

> 编译安装git-cli

```bash
curl -L https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.xz -o ./git-2.9.5.tar.xz -k
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker -y
tar xvf git-2.9.5.tar.xz

cd git-2.9.5
./configure --prefix=/usr/local/git
make && make install

cat >> ~/.bash_profile <<EOF
PATH=\$PATH:/usr/local/git/bin
EOF

. ~/.bash_profile
```

> 安装docker

```shell
groupadd docker
gpasswd -a gitlab-runner docker
newgrp docker
```
重启docker

> 配置

- 注册

```shell
gitlab-runner register
# 键入gitlab地址
```

## 配置

### 1.集成`k8s`集群

> 1.获取`api-server`地址

```shell
kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}'
```

> 2.获取ca证书

```shell
caTokenName=`kubectl get secrets|grep default-token|awk '{print $1}'`
kubectl get secret $caTokenName -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
```

> 3.获取用户`token`

创建用户

```shell
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: gitlab
    namespace: kube-system
EOF
```

获取`token`

```shell
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')
```