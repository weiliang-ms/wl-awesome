# 设置docker容器存储空间限额

适用 docker 场景
```
Storage Driver: overlay2
Backing Filesystem: xfs
```

## 环境准备

1. 测试机安装 docker
2. 测试机添加数据盘，用于模拟 docker 持久化目录

初始化环境信息如下:

```shell
$ df -Th
Filesystem              Type      Size  Used Avail Use% Mounted on
devtmpfs                devtmpfs  7.8G     0  7.8G   0% /dev
tmpfs                   tmpfs     7.8G     0  7.8G   0% /dev/shm
tmpfs                   tmpfs     7.8G  8.9M  7.8G   1% /run
tmpfs                   tmpfs     7.8G     0  7.8G   0% /sys/fs/cgroup
/dev/mapper/centos-root xfs        49G  1.9G   48G   4% /
/dev/sda1               xfs      1014M  195M  820M  20% /boot
tmpfs                   tmpfs     1.6G     0  1.6G   0% /run/user/0
/dev/sdb1               xfs       100G   33M  100G   1% /xfs
$ cat /etc/docker/daemon.json
{
     "registry-mirrors":[
        "https://pee6w651.mirror.aliyuncs.com",
        "https://docker.mirrors.ustc.edu.cn",
        "http://hub-mirror.c.163.com"
     ],
"insecure-registries":["gcr.azk8s.cn","dockerhub.azk8s.cn","quay.azk8s.cn","5twf62k1.mirror.aliyuncs.com","registry.docker-cn.com","registry-1.docker.io"],
     "max-concurrent-downloads":3,
     "log-driver":"json-file",
     "log-opts":{
         "max-size":"100m",
         "max-file":"1"
     },
     "max-concurrent-uploads":3,
     "storage-driver":"overlay2",
     "storage-opts": [
     "overlay2.override_kernel_check=true"
   ],
  "live-restore": true
}
```
docker 持久化目录文件系统类型必须为 xfs

### 调整docker持久化目录

1. 修改 /etc/docker/daemon.json 文件内容，调整 docker 持久化目录为 xfs 分区下，调整后配置如下

```shell
$ cat /etc/docker/daemon.json
{
     "registry-mirrors":[
        "https://pee6w651.mirror.aliyuncs.com",
        "https://docker.mirrors.ustc.edu.cn",
        "http://hub-mirror.c.163.com"
     ],
"insecure-registries":["gcr.azk8s.cn","dockerhub.azk8s.cn","quay.azk8s.cn","5twf62k1.mirror.aliyuncs.com","registry.docker-cn.com","registry-1.docker.io"],
     "max-concurrent-downloads":3,
     "log-driver":"json-file",
     "log-opts":{
         "max-size":"100m",
         "max-file":"1"
     },
     "data-root": "/xfs/docker",
     "max-concurrent-uploads":3,
     "storage-driver":"overlay2",
     "storage-opts": [
     "overlay2.override_kernel_check=true"
   ],
  "live-restore": true
}
```

即以下配置内容

```
"data-root": "/xfs/docker",
```

2. 重载配置以生效

```shell
$ systemctl daemon-reload
$ systemctl restart docker 
```

3. 启动测试容器，创建`40G`文件

```shell
$ docker run -idt --name ddd alpine:latest
$ docker exec -it ddd sh
/ # dd if=/dev/zero of=test.file bs=1M count=40960
40960+0 records in
40960+0 records out
/ # du -sh test.file
40.0G   test.file
```

4. 查看容器磁盘使用量

```shell
$   |grep "alpine:latest"
a8c777259823  alpine:latest  "/bin/sh" 0 42.9GB 27 minutes ago  Up 27 minutes  ddd
```

5. 清理掉测试容器

```shell
$ docker rm -f ddd
```

6. 修改 /etc/fstab 挂载参数，开启磁盘配额功能

否则配置容器存储限额后，启动会报如下异常

```
Jan 03 10:14:01 localhost dockerd[52920]: failed to start daemon: error initializing graphdriver: Storage option overlay2.size not supported. Filesystem does not support Project Quota: Filesystem does not support, or has not enabled quotas
```

修改前，挂载参数

```shell
$ mount |grep sdb1
/dev/sdb1 on /xfs type xfs (rw,relatime,attr2,inode64,noquota)
```

修改 /etc/fstab 内 /xfs 挂载点挂载参数，以开启磁盘配额功能

```shell
$ cat /etc/fstab|grep sdb1
/dev/sdb1 /xfs xfs defaults,usrquota,prjquota 0 0
```

刷新挂载信息

```shell
$ mount -av
/                        : ignored
/boot                    : already mounted
/xfs                     : successfully mounted
```

此时挂载参数（已生效）

```shell
$ mount |grep sdb1
/dev/sdb1 on /xfs type xfs (rw,relatime,attr2,inode64,usrquota,prjquota)
```

7. 配置 docker 容器存储配额为 20G

```shell
$ cat /etc/docker/daemon.json
{
     "registry-mirrors":[
        "https://pee6w651.mirror.aliyuncs.com",
        "https://docker.mirrors.ustc.edu.cn",
        "http://hub-mirror.c.163.com"
     ],
"insecure-registries":["gcr.azk8s.cn","dockerhub.azk8s.cn","quay.azk8s.cn","5twf62k1.mirror.aliyuncs.com","registry.docker-cn.com","registry-1.docker.io"],
     "max-concurrent-downloads":3,
     "log-driver":"json-file",
     "log-opts":{
         "max-size":"100m",
         "max-file":"1"
     },
     "data-root": "/xfs/docker",
     "max-concurrent-uploads":3,
     "storage-driver":"overlay2",
     "storage-opts": [
     "overlay2.override_kernel_check=true",
     "overlay2.size=20G"
   ],
  "live-restore": true
}
```

即添加如下内容

```json
"storage-opts": [
   "overlay2.size=20G"
],
```

重载以生效

```shell
$ systemctl daemon-reload
$ systemctl restart docker 
```

8. 再次启动测试容器，创建 40G 文件

```shell
$ docker run -idt --name ddd alpine:latest
$ docker exec -it ddd sh
/ # dd if=/dev/zero of=test.file bs=1M count=40960
40960+0 records in
40960+0 records out
/ # du -sh test.file
20.0G   test.file
```

通过添加容量配额后，当我们尝试创建 40G 文件，只能创建出 20G 大小的文件，即我们配置里所限制的大小。
上面结果表明容器配额已生效。

9. 清理掉测试容器

```shell
$ docker rm -f ddd
```