{% raw %}
## 不使用Docker的默认网桥docker0

### 描述

不要使用`Docker`的默认`bridge docker0`。 使用`Docker`的用户定义的网络进行容器联网

###  隐患分析

`Docker`将以桥模式创建的虚拟接口连接到名为`docker0`的公共桥。
这种默认网络模型易受`ARP`欺骗和`MAC`洪泛攻击的攻击，因为没有应用过滤

### 审计方式

运行以下命令，并验证容器是否在用户定义的网络上，而不是默认的`docker0`网桥

```shell script
[root@localhost ~]# docker network ls --quiet|xargs docker network inspect --format='{{.Name}}.{{.Options}}'|grep docker0
bridge.map[com.docker.network.bridge.default_bridge:true com.docker.network.bridge.enable_icc:true com.docker.network.bridge.enable_ip_masquerade:true com.docker.network.bridge.host_binding_ipv4:0.0.0.0 com.docker.network.bridge.name:docker0 com.docker.network.driver.mtu:1500]
```

若返回值不为空，说明使用`docker0`网桥

### 修复建议

**使用自定义网桥**

> 关于自定义网桥与默认docker0网桥的主要区别

1. 自定义网桥自动提供容器间的`DNS`解析

默认网桥通过`IP`地址实现容器间的寻址，也可通过`--link`参数实现容器`DNS`解析（容器A名称->容器A IP地址），但不推荐`--link`方式

2. 自定义网桥提供更好的隔离

如果宿主机上所有容器没有指定`--network`参数，那它们将使用默认网桥`docker0`，并可以无限制的互相通信，存在一定安全隐患。

而自定义网桥提供了的网络隔离，只有相同网络域（network）内的容器才能相互访问

> 创建自定义网桥

```shell script
docker network create nginx-net
```

> 运行测试用例

```shell script
[root@localhost ~]# docker run -idt --name=nginx --network=nginx-net nginx:1.14-alpine
[root@localhost ~]# docker run -idt --name=box --network=nginx-net busybox:1.31.1
[root@localhost ~]# docker exec box wget nginx -S
Connecting to nginx (172.18.0.2:80)
  HTTP/1.1 200 OK
  Server: nginx/1.14.2
  Date: Sat, 01 May 2021 07:06:59 GMT
  Content-Type: text/html
  Content-Length: 612
  Last-Modified: Wed, 10 Apr 2019 01:08:42 GMT
  Connection: close
  ETag: "5cad421a-264"
  Accept-Ranges: bytes
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)

{% endraw %}