### 磁盘扩容

> 1.编辑虚拟机调整硬盘空间，重启虚拟机

![](images/scaledisk.jpg)

> 2.查看分区后扩容后的大小

```shell
fdisk -l
```
    
![](images/fdisk.png)

已经扩到了`100G`（扩容前30G）

> 3.新建分区并设置分区为LVM格式

```shell
fdisk /dev/sda
```
    
![](images/fdisk_new_part.png)

最后键入w写入

![](images/fdisk_new_lvm_part.png)

> 4.创建物理卷，并加入到卷组

```shell
partprobe
pvcreate /dev/sda3
```
    
![](images/partprobe.png)
    
扩展vg卷组大小

```shell
vgs
vgextend /dev/centos /dev/sda3
vgs
```

![](images/extend_vgs.png)


> 5.使用`lvextend`命令来扩容`lv`逻辑卷空间大小

```shell
lvs
lvextend -L +69.9G /dev/centos/root
```
    
![](images/extend_lvs.png)

查看文件系统

```shell
df -lhT
```

![](images/fstype.jpg)
    
重新加载逻辑卷的大小

- `xfs`类型文件系统执行

```shell
xfs_growfs /dev/centos/root
```
    
- `ext2、ext3、ext4`类型文件系统执行

```shell
resize2fs /dev/centos/root
```
    
> 6.查看磁盘大小

```shell
df -h
```
    
![](images/extended_disk.jpg)

    