## 配置合适的ulimit

### 描述

> 什么是`ulimit`

`ulimit`主要是用来限制进程对资源的使用情况的，它支持各种类型的限制，常用的有：

- 内核文件的大小限制
- 进程数据块的大小限制
- `Shell`进程创建文件大小限制
- 可加锁内存大小限制
- 常驻内存集的大小限制
- 打开文件句柄数限制
- 分配堆栈的最大大小限制
- `CPU`占用时间限制用户最大可用的进程数限制
- `Shell`进程所能使用的最大虚拟内存限制

### 隐患分析

`ulimit`提供对`shell`可用资源的控制。设置系统资源控制可以防止资源耗尽带来的问题，如`fork`炸弹。
有时候合法的用户和进程也可能过度使用系统资源，导致系统资源耗尽。
为`Docker`守护程序设置默认`ulimit`将强制执行所有容器的`ulimit`。
不需要单独为每个容器设置`ulimit`。 但默认的`ulimit`可能在容器运行时被覆盖。
因此，要控制系统资源，需要自定义默认的`ulimit`

### 审计

确保含有`--default-ulimit`参数

```bash
[root@localhost ~]# ps -ef|grep dockerd
root      65353      1  0 03:02 ?        00:00:00 /usr/bin/dockerd --tlsverify --tlscacert=/root/docker/ca.pem --tlscert=/root/docker/server-cert.pem --tlskey=/root/docker/server-key.pem -H unix:///var/run/docker.sock -H tcp://192.168.235.128:2375
```

### 修复建议

> 调整参数`LimitNOFILE`、`LimitNPROC`

```bash
$ sed -i "s#LimitNOFILE=infinity#LimitNOFILE=20480:40960#g" /etc/systemd/system/docker.service
$ sed -i "s#LimitNPROC=infinity#LimitNPROC=1024:2048#g" /etc/systemd/system/docker.service
```

> 重启

```bash
$ systemctl daemon-reload
$ systemctl restart docker
```

> 启动一个容器测试

```bash
[root@localhost ~]# docker run -idt --name ddd harbor.wl.com/public/alpine sh
15eebdabbb8bd59366348ae95a89d79100370b9c9381b070fdfbb0119b516400
```

> 查看容器`PID`

```bash
[root@localhost ~]# ps -ef|grep 15eebdabbb8bd59366348ae95a89d79100370b9c9381b070fdfbb0119b516400|grep -v grep|awk '{print $2}'
80060
```

> 查看`limit`

```bash
[root@localhost ~]# cat /proc/80060/limits
Limit                     Soft Limit           Hard Limit           Units
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             unlimited            unlimited            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        unlimited            unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             1024                 2048                 processes
Max open files            20480                40960                files
Max locked memory         65536                65536                bytes
Max address space         unlimited            unlimited            bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       3795                 3795                 signals
Max msgqueue size         819200               819200               bytes
Max nice priority         0                    0
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us
```

## 参考文档

- Docker容器最佳安全实践白皮书（V1.0）
- [Docker官方文档](https://docs.docker.com/)