## 技巧

### linux读取移动硬盘数据

> 安装`ntfs-3g`

```shell script
yum -y install ntfs-3g
```

或离线安装，[离线包下载地址](https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2017.3.23.tgz)

```shell script
yum -y install gcc
tar -zxvf ntfs-3g_ntfsprogs-2017.3.23.tgz
cd ntfs-3g_ntfsprogs-2017.3.23/
./configure && make && make install
```

> 查询移动硬盘所在设备接口

```shell script
[root@node3 windows]# fdisk -l | grep NTFS
WARNING: fdisk GPT support is currently new, and therefore in an experimental phase. Use at your own discretion.
/dev/sdl1            2048  3907026943  1953512448    7  HPFS/NTFS/exFAT
```

> 创建挂载点，挂载

```shell script
mkdir -p /ntfs
mount -t ntfs-3g /dev/sdl1 /ntfs
```