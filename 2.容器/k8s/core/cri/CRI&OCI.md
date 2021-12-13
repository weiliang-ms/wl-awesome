
## docker组件介绍

- `docker`: `dockerd`客户端工具
- `dockerd`: 即`docker daemon`，`docker`守护进程
- `containerd`: 工业级标准的容器运行时，主要功能：
  - 管理容器的生命周期(从创建容器到销毁容器)
  - 拉取/推送容器镜像
  - 存储管理(管理镜像及容器数据的存储)
  - 调用`runC`运行容器(与`runC`等容器运行时交互)
  - 管理容器网络接口及网络
`ctr`: `containerd`的客户端工具
- `runC`: `runC`是一个符合`OCI`规范的命令行工具，用来运行容器。
- 

## kubelet创建容器流程

### 运行时为docker时

1. `kubelet`通过`CRI`远程调用内部的`dockershim`套接字（`/var/run/dockershim.sock`）
2. `dockershim`远程调用`dockerd`套接字（`/var/run/docker.sock`）
3. `dockerd`守护进程调用`containerd`守护进程套接字（`/run/containerd/containerd.sock`）
4. `containerd`进程`fork`出一个`container-shim`进程，通过调用`runc`命令行启动、管理容器，并作为容器进程的父进程。

```
+--------------------+
|                    |
|                    |  CRI gRPC
|   kubelet          +-----+                                                  +---------------+     +--------------+
|                    |     |                                                  |               |     |              |
|                    |     |   +---------------+       +--------------+ fork  |container-shim +----->  container   |
|      +-------------+     |   |               |       |              +------->               |     |              |
|      |             |     |   |               |       |              |       +---------------+     +--------------+
|      |            A+<----+   |               |       |              |                      runc(OCI)
|      | dockershim  |         |    dockerd    |       |  containerd  |       +---------------+     +--------------+
|      |             +--------->B              +------->C             |       |               |     |              |
|      |             |         |               |       |              +------->container-shim +----->  container   |
|      |             |         |               |       |              |       |               |     |              |
+------+-------------+         +---------------+       +--------------+       +---------------+     +--------------+
                                                                      |
                    A:unix:///var/run/dockershim.sock                 +------> ......

                                                        C:/run/containerd/containerd.sock
                                B:/var/run/docker.sock

```

> `container-shim`有什么作用?

- 兼容多种`OCI`运行时：为了能够支持多种`OCI Runtime`，`containerd`内部使用`containerd-shim`，
每启动一个容器都会创建一个新的`containerd-shim`进程，指定容器`ID`、`Bundle`目录、运行时的二进制（比如`runc`）
- 作为容器进程的父进程：避免`containerd`进程意外退出导致所有容器进程退出。而`containerd`进程又是所有`containerd-shim`进程父进程
    - 在`containerd`运行的情况下，杀死`containerd-shim`进程，容器进程会退出。
    - 在`containerd`运行的情况下，杀死容器进程，`conainerd-shim`进程主动退出，`containerd`触发`exit`事件以清理该容器。
    - 

进程关系
```shell
$ pstree 2762
containerd─┬─6*[containerd-shim─┬─sh───java───21*[{java}]]
           │                    └─9*[{containerd-shim}]]
           ├─6*[containerd-shim─┬─java───48*[{java}]]
           │                    └─9*[{containerd-shim}]]
           ├─163*[containerd-shim─┬─pause]
           │                      └─9*[{containerd-shim}]]
           ├─13*[containerd-shim─┬─redis-server───3*[{redis-server}]]
           │                     └─11*[{containerd-shim}]]
           ├─containerd-shim─┬─java───69*[{java}]
           │                 └─9*[{containerd-shim}]
           └─577*[{containerd}]
```

## 参考文章
[容器运行时笔记](https://gobomb.github.io/post/container-runtime-note/)
[containerd、containerd-shim和runc的依存关系](https://fankangbest.github.io/2017/11/24/containerd-containerd-shim%E5%92%8Crunc%E7%9A%84%E4%BE%9D%E5%AD%98%E5%85%B3%E7%B3%BB/)

https://xuanwo.io/2019/08/06/oci-intro/