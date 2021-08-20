## 磁盘扩容

> 编辑虚拟机调整硬盘空间，重启虚拟机

![](images/scaledisk.jpg)

> 查看分区后扩容后的大小

    fdisk -l
    
![](images/fdisk.png)

已经扩到了100G（扩容前30G）

> 新建分区并设置分区为LVM格式

    fdisk /dev/sda
    
![](images/fdisk_new_part.png)

最后键入w写入

![](images/fdisk_new_lvm_part.png)

> 创建物理卷，并加入到卷组

    partprobe
    pvcreate /dev/sda3
    
![](images/partprobe.png)
    
扩展vg卷组大小

    vgs
    vgextend /dev/centos /dev/sda3
    vgs

![](images/extend_vgs.png)


> 使用lvextend命令来扩容lv逻辑卷空间大小

    lvs
    lvextend -L +69.9G /dev/centos/root
    
![](images/extend_lvs.png)

查看文件系统

    df -lhT

![](images/fstype.jpg)
    
重新加载逻辑卷的大小

- xfs


    xfs_growfs /dev/centos/root
    
- ext2、ext3、ext4


    resize2fs /dev/centos/root
    
> 查看磁盘大小

    df -h    
    
![](images/extended_disk.jpg)
    

### 逻辑卷组删除物理设备

https://www.linuxprobe.com/delete-physical-volume.html

    