# 

v3.3.1

## kubesphere-system

### ks-console 启动异常

异常信息：

```shell
$ kubectl logs -f ks-console-695ccff5f9-v9jsm -n kubesphere-system

<--- Last few GCs --->


<--- JS stacktrace --->


#
# Fatal process OOM in insufficient memory to create an Isolate
#
```

解决方式 -> 本地编译运行

流程如下：

1. 下载源码

```shell
$ git clone --branch v3.3.1 https://github.com/kubesphere/console.git
```

2. 修改 build/Dockerfile

```shell
$ cd console
$ vim build/Dockerfile
```

调整内容：构建基础镜像、设置 yarn 源、调整目录权限等

```dockerfile

```


3. 编译

```shell
$ docker buildx build --platform linux/arm64 -t kubesphere/ks-console:v3.3.1 -f build/Dockerfile .
```

4. 重启服务

```shell
$ kubectl rollout restart deploy ks-console -n kubesphere-system
```

## kubesphere-logging-system

logsidecar-injector-deploy 启动异常

![](images/logsidecar-injector-deploy.png)

更换镜像版本

```shell
$ kubectl set image deployment/logsidecar-injector-deploy \
    logsidecar-injector=kubesphere/log-sidecar-injector:v1.2.0 -n kubesphere-logging-system
```

elasticsearch-logging-discovery、 启动异常

![](images/elasticsearch-oss.png)

更换镜像版本

```shell
$ kubectl set image sts/elasticsearch-logging-discovery \
    chown=kubesphere/elasticsearch-oss:6.7.0-1-arm64 -n kubesphere-logging-system
$ kubectl set image sts/elasticsearch-logging-discovery \
    elasticsearch=kubesphere/elasticsearch-oss:6.7.0-1-arm64 -n kubesphere-logging-system
    
$ kubectl set image sts/elasticsearch-logging-data \
    chown=kubesphere/elasticsearch-oss:6.7.0-1-arm64 -n kubesphere-logging-system
$ kubectl set image sts/elasticsearch-logging-data \
    elasticsearch=kubesphere/elasticsearch-oss:6.7.0-1-arm64 -n kubesphere-logging-system
```

强制重启

```shell
$ kubectl delete pod elasticsearch-logging-discovery-0 -n kubesphere-logging-system --force
$ kubectl delete pod elasticsearch-logging-data-0 -n kubesphere-logging-system --force
```


## istio-system

```shell
$ kubectl set image deploy/kiali-operator \
    operator=kubesphere/kiali-operator:v1.50.1 -n istio-system
```

```shell
$ kubectl set image deploy/istiod-1-11-2 \
    discovery=istio/pilot:1.15.6 -n istio-system
```



