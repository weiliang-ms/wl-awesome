## lvm架构  

![](lvm.png)

### 创建lvm

1. 创建pv

```shell
pvcreate /dev/sdb
```

2. 创建vg

```shell
vgcreate data-volume /dev/sdb
```

3. 创建lv（逻辑卷）

```shell
lvcreate -n data-lv -l 100%free data-volume
```

4. 格式化lv

```shell
mkfs.ext4 /dev/data-volume/data-lv
```

5. 挂载使用

```shell
mkdir /data
mount /dev/data-volume/data-lv /data
```

6. 设置自动挂载

```shell
echo "/dev/data-volume/data-lv /data ext4 defaults        0 0" >> /etc/fstab
```