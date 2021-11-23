# pause容器解析

## 前言

当您在`Kubernetes`集群的节点上执行，`docker ps`时，您会发现一些名为`pause`的容器正在运行:
```shell
$ docker ps
CONTAINER ID        IMAGE                           COMMAND ...
...
3b45e983c859        gcr.io/google_containers/pause-amd64:3.0    "/pause" ...
...
dbfc35b00062        gcr.io/google_containers/pause-amd64:3.0    "/pause" ...
...
c4e998ec4d5d        gcr.io/google_containers/pause-amd64:3.0    "/pause" ...
...
508102acf1e7        gcr.io/google_containers/pause-amd64:3.0    "/pause" ...
```

> 您可能很好奇：这些`pause`容器是什么? 为什么会有这么多这样的容器?

为了回答这些问题，您需要了解`Kubernetes`中的`pod`是如何实现的（尤其是基于常用的容器运行时：`Docker/containerd`），
如果您对`pod`的实现原理不是很了解，请参考[What are Kubernetes Pods Anyway?](https://www.ianlewis.org/en/what-are-kubernetes-pods-anyway)

我们都知道利用`Docker`启动运行单一进程的容器很简单， 然而当您想要同时运行多个软件组件时，这个模型可能会变得有点麻烦。
当开发人员创建`Docker`映像时，您经常会看到这种情况，这些映像使用`entrypoint`作为入口点来启动和管理多个进程。
对于生产系统，许多人发现将这些应用程序部署在部分隔离且部分共享环境的容器组中更为有用。

`Kubernetes`针对上述场景的需求，提供了一个称为`pods`的抽象。
它屏蔽了`Docker`标志的复杂性（如启动个容器可能需要传递多个标识: `docker run -itd --name ddd -v /etc/hosts:/etc/hosts nginx`），以及管理容器、共享卷等操作。
它还隐藏了容器运行时之间的差异，例如，`rkt`原生支持`pod`，因此`Kubernetes`要做的工作较少，但作为`Kubernetes`的用户，您不必担心这一点。

> 事实上，`Docker`原生就具备控制容器组之间的共享级别的能力——通过创建一个父容器，例如：

1. 创建容器`A`，作为父容器，容器`ID`假设为`A-ID`
2. 创建容器`B`，作为子容器，容器`ID`假设为`B-ID`，启动时指定`PID`命名空间标识为`--pid=container:A-ID`
3. 创建容器`C`，作为子容器，容器`ID`假设为`C-ID`，启动时指定`PID`命名空间标识为`--pid=container:A-ID`

此时，容器`B`与容器`C`共享相同的`PID`命名空间(即容器`A`的`PID`命名空间)

通过上面的例子我们发现，使用原生的容器运行时实现起来比较繁琐，因为首先您得了解创建流程、所使用的标识，并管理这些容器的生命周期。

而在`Kubernetes`中，`pause`容器作为您`pod`中所有容器的`父容器`。
`pause`容器有两个核心职责：
- 首先，它作为在`pod`中共享`Linux`名称空间的基础容器。
- 其次，启用`PID`(进程`ID`)名称空间共享后，它将作为每个`pod`的`PID 1`进程（根进程），并获取僵尸进程。


接下来我们针对`pause`容器的职责逐一解析

## 关于共享命名空间

在`Linux`中，当运行一个新进程时，该进程从父进程继承其名称空间。
在新的命名空间中运行进程的方法是通过与父进程`取消共享`命名空间，从而创建一个新的命名空间。

下面是使用`unshare`工具在新的`PID、UTS、IPC`和`mount`名称空间中运行`shell`的示例。

```shell
$ sudo unshare --pid --uts --ipc --mount -f chroot rootfs /bin/sh
```

一旦进程运行，您可以将其他进程添加到进程的名称空间中，以形成一个`pod`。可以使用`setns`系统调用将新的进程添加到现有的命名空间中。

而`pod`的容器之间共享名称空间也是基于这个原理实现的。

`Docker`的实现则是将这个过程自动化一些，所以让我们看一个例子，看看如何通过使用`pause`容器和共享名称空间从头创建一个`pod`。

1. 首先，我们需要使用`Docker`启动`pause`容器，并作端口映射，以便我们可以将容器添加到`pod`中。

```shell
$ docker run -d --name pause -p 8080:80 gcr.io/google_containers/pause-amd64:3.0
```

2. 接下来为我们的`pod`容器，首先我们运行一个`nginx`容器，调整`nginx`的代理配置：监听80请求，并将请求转发至本地`2368`端口。

```shell
$ cat <<EOF >> nginx.conf
> error_log stderr;
> events { worker_connections  1024; }
> http {
>     access_log /dev/stdout combined;
>     server {
>         listen 80 default_server;
>         server_name example.com www.example.com;
>         location / {
>             proxy_pass http://127.0.0.1:2368;
>         }
>     }
> }
> EOF
$ docker run -d --name nginx -v `pwd`/nginx.conf:/etc/nginx/nginx.conf --net=container:pause --ipc=container:pause --pid=container:pause nginx
```

3. 接下来创建一个`ghost`博客应用容器，作为服务端，端口监听为`2368`

```shell
$ docker run -d --name ghost --net=container:pause --ipc=container:pause --pid=container:pause ghost
```

通过上面的操作，我们将`pause`容器`Network`、`PID`、`IPC`命名空间共享给`nginx`与`ghost`容器，即三个容器共享相同`Network`、`PID`、`IPC`命名空间。
此时，当您访问`http://localhost:8080/`，实际被代理至`ghost`服务，流程如下:

a. 容器宿主机访问`http://localhost:8080/`
b. 请求被转发至`pause`容器`80`端口，即`nginx`容器`80`端口
c. `nginx`将请求转发至本地`2368`端口，即`ghost`容器`2368`端口

![](images/pause_container.png)

显然，原生实现的流程还是比较复杂的（这还没有包括监控、管理这些容器生命周期）
