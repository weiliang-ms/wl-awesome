<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [磁盘扩容](#%E7%A3%81%E7%9B%98%E6%89%A9%E5%AE%B9)
  - [逻辑卷组删除物理设备](#%E9%80%BB%E8%BE%91%E5%8D%B7%E7%BB%84%E5%88%A0%E9%99%A4%E7%89%A9%E7%90%86%E8%AE%BE%E5%A4%87)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 磁盘扩容

> 编辑虚拟机调整硬盘空间，重启虚拟机

![](./images/scaledisk.jpg)

> 查看分区后扩容后的大小

    fdisk -l
    
![](./images/fdisk.png)

已经扩到了100G（扩容前30G）

> 新建分区并设置分区为LVM格式

    fdisk /dev/sda
    
![](./images/fdisk_new_part.png)

最后键入w写入

![](./images/fdisk_new_lvm_part.png)

> 创建物理卷，并加入到卷组

    partprobe
    pvcreate /dev/sda3
    
![](./images/partprobe.png)
    
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

    