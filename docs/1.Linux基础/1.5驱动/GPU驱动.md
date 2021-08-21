### 安装Gpu驱动

> 1.查看Gpu版本

```shell
lspci | grep NVIDIA
```

执行结果如下

```shell
00:08.0 3D controller: NVIDIA Corporation GV100GL [Tesla V100 SXM2 32GB] (rev a1)
```

说明版本为`Tesla V100`

> 2.安装驱动

```shell
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum install nvidia-x11-drv nvidia-x11-drv-32bit -y
```