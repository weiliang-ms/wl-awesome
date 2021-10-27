### 描述

`Docker`软件频繁发布更新，旧版本可能存在安全漏洞

### 审计

查看[release](https://github.com/moby/moby/releases) 与本地版本比较

```bash
$ docker version
```

### 隐患分析

不要盲目升级`docker`版本，评估升级是否会对现有系统产生影响，充分测试其兼容性（如与`k8s kubeadm`兼容性）

### 修复建议

```bash
#安装一些必要的系统工具
$ yum -y install yum-utils device-mapper-persistent-data lvm2

#添加软件源信息
$ yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#更新 yum 缓存
$ yum makecache fast

#安装docker-ce
$ yum -y install docker-ce
# 或更新
$ yum -y update docker-ce
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/) 