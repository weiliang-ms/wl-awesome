## cap_fowner能力分析

- `cap_fowner`: 忽略文件属主`ID`必须与进程用户`ID`一致

简单来说就是：当进程/可执行文件拥有`cap_fowner`能力时，
如果用户`A`(非特权用户)对文件`F`（属主为`root`）执行写入后，该文件的属主会变为`A`。


那么让我们基于`CentOS7`，透过下面例子来理解`cap_fowner`的功能：

1. 创建用户`test`，用于测试

```shell
$ adduser test
```

2. 使用`root`身份创建一个文件

```shell
$ touch /home/test/ddd
$ ls -l /home/test/ddd
-rw-r--r-- 1 root root 0 Nov  4 13:52 /home/test/ddd
```

3. 对`vim`添加`cap_fowner`的功能

```shell
$ setcap cap_fowner=eip /usr/bin/vim
```

4. 切换至`test`用户对`/home/test/ddd`编辑写入

```shell
$ su - test
$ vim /home/test/ddd
$ exit
```

写入数据后`:wq!`保存退出，查看此时文件属主（已变为`test`）

```shell
$ ls -l /home/test/ddd
-rw-r--r-- 1 test test 16 Nov  4 13:54 /home/test/ddd
```

5. 查看`vim`的`CAP`

```shell
$ getcap /usr/bin/vim
/usr/bin/vim = cap_fowner+eip
```

清理`vim`的`CAP`

```shell
$ setcap -r /usr/bin/vim
```

清理测试用例

```shell
$ userdel -r test
```