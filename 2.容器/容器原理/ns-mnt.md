# MNT命名空间

## 概念

> `mnt namespace`有什么能力？

`mnt`(`mount`缩写) 命名空间提供了隔离`mount point`能力。

每个`mnt namespace`内的文件结构可以单独修改，互不影响。

## 隔离性验证

### 查看挂载信息

> 查看当前进程挂载点信息

```bash
[root@localhost ns]# ll /proc/$$/mount*
-r--r--r-- 1 root root 0 Jul 14 22:21 /proc/88929/mountinfo
-r--r--r-- 1 root root 0 Jul 14 22:21 /proc/88929/mounts
-r-------- 1 root root 0 Jul 14 22:21 /proc/88929/mountstats
```

> 查看`mountinfo`内容

```bash
23 46 0:22 / /sys rw,nosuid,nodev,noexec,relatime shared:6 - sysfs sysfs rw
24 46 0:5 / /proc rw,nosuid,nodev,noexec,relatime shared:5 - proc proc rw
25 46 0:6 / /dev rw,nosuid shared:2 - devtmpfs devtmpfs rw,size=1985460k,nr_inodes=496365,mode=755
26 23 0:7 / /sys/kernel/security rw,nosuid,nodev,noexec,relatime shared:7 - securityfs securityfs rw
27 25 0:23 / /dev/shm rw,nosuid,nodev shared:3 - tmpfs tmpfs rw
28 25 0:24 / /dev/pts rw,nosuid,noexec,relatime shared:4 - devpts devpts rw,gid=5,mode=620,ptmxmode=000
29 46 0:25 / /run rw,nosuid,nodev shared:23 - tmpfs tmpfs rw,mode=755
30 23 0:26 / /sys/fs/cgroup ro,nosuid,nodev,noexec shared:8 - tmpfs tmpfs ro,mode=755
31 30 0:27 / /sys/fs/cgroup/systemd rw,nosuid,nodev,noexec,relatime shared:9 - cgroup cgroup rw,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd
32 23 0:28 / /sys/fs/pstore rw,nosuid,nodev,noexec,relatime shared:21 - pstore pstore rw
33 30 0:29 / /sys/fs/cgroup/cpu,cpuacct rw,nosuid,nodev,noexec,relatime shared:10 - cgroup cgroup rw,cpu,cpuacct
34 30 0:30 / /sys/fs/cgroup/memory rw,nosuid,nodev,noexec,relatime shared:11 - cgroup cgroup rw,memory
35 30 0:31 / /sys/fs/cgroup/devices rw,nosuid,nodev,noexec,relatime shared:12 - cgroup cgroup rw,devices
36 30 0:32 / /sys/fs/cgroup/freezer rw,nosuid,nodev,noexec,relatime shared:13 - cgroup cgroup rw,freezer
37 30 0:33 / /sys/fs/cgroup/perf_event rw,nosuid,nodev,noexec,relatime shared:14 - cgroup cgroup rw,perf_event
38 30 0:34 / /sys/fs/cgroup/pids rw,nosuid,nodev,noexec,relatime shared:15 - cgroup cgroup rw,pids
39 30 0:35 / /sys/fs/cgroup/hugetlb rw,nosuid,nodev,noexec,relatime shared:16 - cgroup cgroup rw,hugetlb
40 30 0:36 / /sys/fs/cgroup/net_cls,net_prio rw,nosuid,nodev,noexec,relatime shared:17 - cgroup cgroup rw,net_cls,net_prio
41 30 0:37 / /sys/fs/cgroup/blkio rw,nosuid,nodev,noexec,relatime shared:18 - cgroup cgroup rw,blkio
42 30 0:38 / /sys/fs/cgroup/rdma rw,nosuid,nodev,noexec,relatime shared:19 - cgroup cgroup rw,rdma
43 30 0:39 / /sys/fs/cgroup/cpuset rw,nosuid,nodev,noexec,relatime shared:20 - cgroup cgroup rw,cpuset
44 23 0:40 / /sys/kernel/config rw,relatime shared:22 - configfs configfs rw
46 1 8:3 / / rw,relatime shared:1 - xfs /dev/sda3 rw,attr2,inode64,logbufs=8,logbsize=32k,noquota
22 24 0:21 / /proc/sys/fs/binfmt_misc rw,relatime shared:24 - autofs systemd-1 rw,fd=23,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=711
47 25 0:42 / /dev/hugepages rw,relatime shared:25 - hugetlbfs hugetlbfs rw,pagesize=2M
48 25 0:20 / /dev/mqueue rw,relatime shared:26 - mqueue mqueue rw
49 23 0:8 / /sys/kernel/debug rw,relatime shared:27 - debugfs debugfs rw
51 46 8:1 / /boot rw,relatime shared:28 - xfs /dev/sda1 rw,attr2,inode64,logbufs=8,logbsize=32k,noquota
52 46 0:44 / /var/lib/nfs/rpc_pipefs rw,relatime shared:29 - rpc_pipefs sunrpc rw
203 46 0:46 / /var/lib/docker/231072.231072/overlay2/6979cabf2db354126e61163ddc90b5738c600797fefbf0c41c9b56600f011d1f/merged rw,relatime shared:173 - overlay overlay rw,lowerdir=/var/lib/docker/231072.231072/overlay2/l/67CHEM5VH4RUKAJ7YJQWRBNVJE:/var/lib/docker/231072.231072/overlay2/l/GOFSE7LF6JYPQUVKRKRQFETASF,upperdir=/var/lib/docker/231072.231072/overlay2/6979cabf2db354126e61163ddc90b5738c600797fefbf0c41c9b56600f011d1f/diff,workdir=/var/lib/docker/231072.231072/overlay2/6979cabf2db354126e61163ddc90b5738c600797fefbf0c41c9b56600f011d1f/work
310 29 0:4 net:[4026532689] /run/docker/netns/bae6cec20525 rw shared:181 - nsfs nsfs rw
333 29 0:45 / /run/user/1000 rw,nosuid,nodev,relatime shared:217 - tmpfs tmpfs rw,size=400496k,mode=700,uid=1000,gid=1000
343 333 0:59 / /run/user/1000/gvfs rw,nosuid,nodev,relatime shared:227 - fuse.gvfsd-fuse gvfsd-fuse rw,user_id=1000,group_id=1000
353 23 0:60 / /sys/fs/fuse/connections rw,relatime shared:237 - fusectl fusectl rw
522 29 0:63 / /run/user/0 rw,nosuid,nodev,relatime shared:440 - tmpfs tmpfs rw,size=400496k,mode=700
``` 

> 查看`mount`内容

```bash
[root@localhost 88929]# cat /proc/$$/mounts
sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
devtmpfs /dev devtmpfs rw,nosuid,size=1985460k,nr_inodes=496365,mode=755 0 0
securityfs /sys/kernel/security securityfs rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /dev/shm tmpfs rw,nosuid,nodev 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,nodev,mode=755 0 0
tmpfs /sys/fs/cgroup tmpfs ro,nosuid,nodev,noexec,mode=755 0 0
cgroup /sys/fs/cgroup/systemd cgroup rw,nosuid,nodev,noexec,relatime,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd 0 0
pstore /sys/fs/pstore pstore rw,nosuid,nodev,noexec,relatime 0 0
cgroup /sys/fs/cgroup/cpu,cpuacct cgroup rw,nosuid,nodev,noexec,relatime,cpu,cpuacct 0 0
cgroup /sys/fs/cgroup/memory cgroup rw,nosuid,nodev,noexec,relatime,memory 0 0
cgroup /sys/fs/cgroup/devices cgroup rw,nosuid,nodev,noexec,relatime,devices 0 0
cgroup /sys/fs/cgroup/freezer cgroup rw,nosuid,nodev,noexec,relatime,freezer 0 0
cgroup /sys/fs/cgroup/perf_event cgroup rw,nosuid,nodev,noexec,relatime,perf_event 0 0
cgroup /sys/fs/cgroup/pids cgroup rw,nosuid,nodev,noexec,relatime,pids 0 0
cgroup /sys/fs/cgroup/hugetlb cgroup rw,nosuid,nodev,noexec,relatime,hugetlb 0 0
cgroup /sys/fs/cgroup/net_cls,net_prio cgroup rw,nosuid,nodev,noexec,relatime,net_cls,net_prio 0 0
cgroup /sys/fs/cgroup/blkio cgroup rw,nosuid,nodev,noexec,relatime,blkio 0 0
cgroup /sys/fs/cgroup/rdma cgroup rw,nosuid,nodev,noexec,relatime,rdma 0 0
cgroup /sys/fs/cgroup/cpuset cgroup rw,nosuid,nodev,noexec,relatime,cpuset 0 0
configfs /sys/kernel/config configfs rw,relatime 0 0
/dev/sda3 / xfs rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota 0 0
systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=23,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=711 0 0
hugetlbfs /dev/hugepages hugetlbfs rw,relatime,pagesize=2M 0 0
mqueue /dev/mqueue mqueue rw,relatime 0 0
debugfs /sys/kernel/debug debugfs rw,relatime 0 0
/dev/sda1 /boot xfs rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota 0 0
sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw,relatime 0 0
overlay /var/lib/docker/231072.231072/overlay2/6979cabf2db354126e61163ddc90b5738c600797fefbf0c41c9b56600f011d1f/merged overlay rw,relatime,lowerdir=/var/lib/docker/231072.231072/overlay2/l/67CHEM5VH4RUKAJ7YJQWRBNVJE:/var/lib/docker/231072.231072/overlay2/l/GOFSE7LF6JYPQUVKRKRQFETASF,upperdir=/var/lib/docker/231072.231072/overlay2/6979cabf2db354126e61163ddc90b5738c600797fefbf0c41c9b56600f011d1f/diff,workdir=/var/lib/docker/231072.231072/overlay2/6979cabf2db354126e61163ddc90b5738c600797fefbf0c41c9b56600f011d1f/work 0 0
nsfs /run/docker/netns/bae6cec20525 nsfs rw 0 0
tmpfs /run/user/1000 tmpfs rw,nosuid,nodev,relatime,size=400496k,mode=700,uid=1000,gid=1000 0 0
gvfsd-fuse /run/user/1000/gvfs fuse.gvfsd-fuse rw,nosuid,nodev,relatime,user_id=1000,group_id=1000 0 0
fusectl /sys/fs/fuse/connections fusectl rw,relatime 0 0
tmpfs /run/user/0 tmpfs rw,nosuid,nodev,relatime,size=400496k,mode=700 0 0
```

> 查看`mountstats`

挂载状态

```bash
[root@localhost ~]# cat /proc/$$/mountstats
device sysfs mounted on /sys with fstype sysfs
device proc mounted on /proc with fstype proc
device devtmpfs mounted on /dev with fstype devtmpfs
device securityfs mounted on /sys/kernel/security with fstype securityfs
device tmpfs mounted on /dev/shm with fstype tmpfs
device devpts mounted on /dev/pts with fstype devpts
device tmpfs mounted on /run with fstype tmpfs
device tmpfs mounted on /sys/fs/cgroup with fstype tmpfs
device cgroup mounted on /sys/fs/cgroup/systemd with fstype cgroup
device pstore mounted on /sys/fs/pstore with fstype pstore
device cgroup mounted on /sys/fs/cgroup/cpu,cpuacct with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/memory with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/devices with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/freezer with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/perf_event with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/pids with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/hugetlb with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/net_cls,net_prio with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/blkio with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/rdma with fstype cgroup
device cgroup mounted on /sys/fs/cgroup/cpuset with fstype cgroup
device configfs mounted on /sys/kernel/config with fstype configfs
device /dev/sda3 mounted on / with fstype xfs
device systemd-1 mounted on /proc/sys/fs/binfmt_misc with fstype autofs
device hugetlbfs mounted on /dev/hugepages with fstype hugetlbfs
device mqueue mounted on /dev/mqueue with fstype mqueue
device debugfs mounted on /sys/kernel/debug with fstype debugfs
device /dev/sda1 mounted on /boot with fstype xfs
device sunrpc mounted on /var/lib/nfs/rpc_pipefs with fstype rpc_pipefs
device overlay mounted on /var/lib/docker/231072.231072/overlay2/6979cabf2db354126e61163ddc90b5738c600797fefbf0c41c9b56600f011d1f/merged with fstype overlay
device nsfs mounted on /run/docker/netns/bae6cec20525 with fstype nsfs
device tmpfs mounted on /run/user/1000 with fstype tmpfs
device gvfsd-fuse mounted on /run/user/1000/gvfs with fstype fuse.gvfsd-fuse
device fusectl mounted on /sys/fs/fuse/connections with fstype fusectl
device tmpfs mounted on /run/user/0 with fstype tmpfs
```

### 隔离性验证

关于`mount namespace`记住以下三点:

- a.每个`mount namespace`都有一份自己的挂载点列表

- b.当使用`clone`函数或`unshare`函数并传入`CLONE_NEWNS`标志创建新的`mount namespace`时，
新`mount namespace`中的挂载点其实是从调用者所在的`mount namespace`中拷贝的。

- c.在新的`mount namespace`创建之后，这两个`mount namespace`及其挂载点基本无任何关系，
两个`mount namespace`是相互隔离的。

> 安装`mkisofs`演示`mnt namespace`

```bash
yum install mkisofs -y
```

> 创建演示用`iso`文件

```bash
hostnamectl set-hostname vm
mkdir -p ~/iso/{A,B}
echo "A" > ~/iso/A/a.txt
echo "B" > ~/iso/B/b.txt
cd ~/iso
mkisofs -o ./A.iso ./A
mkisofs -o ./B.iso ./B
exec bash
```

> 创建用于挂载的目录

```bash
mkdir -p /mnt/{isoA,isoB}
```

> 在当前`mnt namepace`下挂载`~/iso/A.iso`至`/mnt/isoA`

查看当前`mnt namepace`编号

```bash
[root@vm iso]# readlink /proc/$$/ns/mnt
mnt:[4026531840]
```

挂载

```bash
[root@vm iso]# mount ~/iso/A.iso /mnt/isoA
mount: /dev/loop0 is write-protected, mounting read-only
[root@vm iso]# cat /mnt/isoA/a.txt
A
```

查看挂载状态

```bash
[root@vm iso]# mount |grep A.iso
/root/iso/A.iso on /mnt/isoA type iso9660 (ro,relatime,nojoliet,check=s,map=n,blocksize=2048)
```

> 创建并进入新的`mount`和`uts namespace`

```bash
unshare --mount --uts /bin/bash
hostnamectl set-hostname container-A
exec bash
```

> 查看新的`mount namespace`挂载信息

查看`mnt`命名空间编号

```bash
[root@vm iso]# readlink /proc/$$/ns/mnt
mnt:[4026532765]
```

查看挂载信息
```bash
[root@vm iso]# mount|grep A.iso
/root/iso/A.iso on /mnt/isoA type iso9660 (ro,relatime,nojoliet,check=s,map=n,blocksize=2048)
```

`b.`内容验证成功

> 新的`mount namespace`内挂载`~/iso/B.iso`至`/mnt/isoB`

挂载

```bash
[root@vm iso]# mount ~/iso/B.iso /mnt/isoB
mount: /dev/loop1 is write-protected, mounting read-only
```

查看挂载状态

```bash
[root@vm iso]# mount |grep B.iso
/root/iso/B.iso on /mnt/isoB type iso9660 (ro,relatime,nojoliet,check=s,map=n,blocksize=2048)
```

> 新的`mount namespace`内卸载`/mnt/isoA`

```bash
[root@vm iso]# umount /mnt/isoA
[root@vm iso]# ls /mnt/isoA
```

> 返回第一个mnt命名空间

通过新建`session`实现，并执行以下命令确认`mnt`命名空间(4026531840)

```bash
readlink /proc/$$/ns/mnt
```

查看挂载信息

```bash
[root@container-a ~]# cat /mnt/isoA/a.txt
A
[root@container-a ~]# mount |grep iso
/root/iso/A.iso on /mnt/isoA type iso9660 (ro,relatime,nojoliet,check=s,map=n,blocksize=2048)
```

`c.`验证成功

## 参考文献

- [liunx mnt命名空间](https://www.cnblogs.com/caonw/p/11935104.html)
- [Docker 学习笔记11 容器技术原理 Mount Namespace](https://blog.csdn.net/xundh/article/details/106759934)