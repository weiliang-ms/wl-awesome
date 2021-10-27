## Docker守护进程配置TLS身份认证

### 描述

可以让`Docker`守护进程监听特定的`IP`和端口以及除默认`Unix`套接字以外的任何其他`Unix`套接字。
配置`TLS`身份验证以限制通过`IP`和端口访问`Docker`守护进程。

### 隐患分析

默认情况下，`Docker`守护程序绑定到非联网的`Unix`套接字，并以`root`权限运行。
如果将默认的`Docker`守护程序更改为绑定到`TCP`端口或任何其他`Unix`套接字，那么任何有权访问该端口或套接字的人都可以完全访问`Docker`守护程序，进而可以访问主机系统。

因此，不应该将`Docker`守护程序绑定到另一个`IP`/端口或`Unix`套接字。
如果必须通过网络套接字暴露`Docker`守护程序，请为守护程序配置`TLS`身份验证

### 审计方法

```bash
[root@localhost ~]# systemctl status docker|grep /usr/bin/dockerd
           ├─1061 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
```

### 修复建议

生产环境下避免开启`tcp`监听，若避免不了，执行以下操作。

> 生成`CA`私钥和公共密钥

```bash
$ mkdir -p /root/docker
$ cd /root/docker
$ openssl genrsa -aes256 -out ca-key.pem 4096
$ openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
```

> 创建一个服务端密钥和证书签名请求(`CSR`)

`192.168.235.128`为当前主机`IP`地址

```bash
$ openssl genrsa -out server-key.pem 4096
$ openssl req -subj "/CN=192.168.235.128" -sha256 -new -key server-key.pem -out server.csr
```

> 用`CA`来签署公共密钥

```bash
$ echo subjectAltName = DNS:192.168.235.128,IP:192.168.235.128 >> extfile.cnf
$ echo extendedKeyUsage = serverAuth >> extfile.cnf
```

> 生成`key`

```bash
$ openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -extfile extfile.cnf
```

> 创建客户端密钥和证书签名请求

```bash
$ openssl genrsa -out key.pem 4096
$ openssl req -subj '/CN=client' -new -key key.pem -out client.csr
```

> 修改`extfile.cnf`

```bash
$ echo extendedKeyUsage = clientAuth > extfile-client.cnf
```

> 生成签名私钥

```bash
$ openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out cert.pem -extfile extfile-client.cnf
```

> 将`Docker`服务停止，然后修改`docker`服务文件

停服务

```bash
$ systemctl stop docker
```

编辑配置文件

```bash
$ vi /etc/systemd/system/docker.service
```

替换`ExecStart=/usr/bin/dockerd`为以下

```
ExecStart=/usr/bin/dockerd --tlsverify --tlscacert=/root/docker/ca.pem --tlscert=/root/docker/server-cert.pem --tlskey=/root/docker/server-key.pem -H unix:///var/run/docker.sock -H tcp://192.168.235.128:2375
```

重启

```bash
$ systemctl daemon-reload
$ systemctl start docker
```

> 测试`tls`

```bash
$ docker --tlsverify --tlscacert=/root/docker/ca.pem --tlscert=/root/docker/cert.pem --tlskey=/root/docker/key.pem -H=192.168.235.128:2375 version
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)