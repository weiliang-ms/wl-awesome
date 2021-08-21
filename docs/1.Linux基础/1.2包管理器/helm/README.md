## helm

`Kubernetes`的软件包管理工具

### 版本说明

`Helm 2` 是 `C/S` 架构，主要分为客户端 `helm` 和服务端 `Tiller`; 
`Helm 3` 中移除了 `Tiller`, 版本相关的数据直接存储在了 `Kubernetes` 中

### Helm 组件及相关术语

- `helm`

`Helm` 是一个命令行下的客户端工具。主要用于 `Kubernetes` 应用程序 `Chart` 的创建、打包、发布以及创建和管理本地和远程的 `Chart` 仓库。

- `Chart`

`Helm` 的软件包，采用 `TAR` 格式。类似于 `APT` 的 `DEB` 包或者 `YUM` 的 `RPM` 包，其包含了一组定义 `Kubernetes` 资源相关的 `YAML` 文件。

- `Repoistory`

`Helm` 的软件仓库，`Repository` 本质上是一个 `Web` 服务器，该服务器保存了一系列的 `Chart` 软件包以供用户下载，并且提供了一个该 `Repository` 的 `Chart` 包的清单文件以供查询。`Helm` 可以同时管理多个不同的 `Repository`。

- `Release`

使用 `helm install` 命令在 `Kubernetes` 集群中部署的 `Chart` 称为 `Release`。可以理解为 `Helm` 使用 `Chart` 包部署的一个应用实例

### helm安装

> 下载`helm release`压缩包

- [release版本](https://github.com/helm/helm/releases)

> 解压，添加到PATH

### 创建应用

> 初始化

```shell
[root@node3 cloud]# helm create redis
  Creating redis
```
    
> 应用目录结构

```shell
[root@node3 cloud]# tree redis/
    redis/
    ├── charts
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── _helpers.tpl
    │   ├── hpa.yaml
    │   ├── ingress.yaml
    │   ├── NOTES.txt
    │   ├── serviceaccount.yaml
    │   ├── service.yaml
    │   └── tests
    │       └── test-connection.yaml
    └── values.yaml
```
