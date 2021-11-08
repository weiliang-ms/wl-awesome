## cap_mknod解析

- `cap_mknod`: 允许使用`mknod()`系统调用

> 首先我们需要了解：`mknod()`是用来干什么？

`mknod()`主要用于创建块设备，`mknod`指令是其具体实现。

接下来我们了解下`mknod`指令。

### mknod指令

指令格式

```shell
$ mknod [选项] [名称] [类型] [主设备号] [次设备号]
```

1. 创建用户`test`，用于测试

```shell
$ adduser test
```

2. `root`用户创建一个块设备

```shell
$ mknod /dev/sdb b 8 0
$ ls /dev/sdb
brw-r--r--. 1 root root 8, 0 Nov  6 07:02 /dev/sdb
```

3. `test`用户创建一个块设备

```shell
$ whoami
test
$ mknod /tmp/tnod1 c 1 5
mknod: ‘/tmp/tnod1’: Permission denied
```

4. `root`用户为`/usr/bin/mknod`授予`cap_mknod`能力

```shell
$ whoami
root
$ setcap cap_mknod=eip /usr/bin/mknod
```

5. 切换`test`用户再次创建一个块设备

```shell
$ whoami
test
$ mknod /tmp/tnod1 c 1 5
```

6. 清理测试用例

```shell
$ userdel -r test
$ setcap -r /usr/bin/mknod
```