## cap_fsetid能力分析

- `cap_fsetid`: 确保在文件被修改后不修改`setuid/setgid`位

简单来说就是：当进程/可执行文件拥有`cap_fsetid`能力时，当用户对文件`F`（含有`setuid/setgid`位）执行写操作后，该文件的`setuid/setgid`位不会发生变化。

首先我们先了解下什么是`setuid/setgid`位

### SUID是什么？

1. 我们先看一下不带`setuid`位的文件权限

```shell
$ touch /tmp/ddd
$ ls -l /tmp/ddd
-rw-r--r-- 1 root root 0 Nov  4 14:29 /tmp/ddd
```

- `-rw-r--r--`中的第一位`-`表示`/tmp/ddd`类型为文件
- `-rw-r--r--`中的第`2-4`位`rw-`表示`/tmp/ddd`文件属主拥有的权限为: 读写
- `-rw-r--r--`中的第`5-7`位`r--`表示`/tmp/ddd`文件所属用户组（root）下其他用户对其拥有的权限为: 读
- `-rw-r--r--`中的第`5-7`位`r--`表示其他用户组（非`root`）下用户对其拥有的权限为: 读
- 第一个`root`表示该文件属主为`root`
- 第二个`root`表示该文件所属用户组为`root`

2. 当我们对其追加`suid/`时：

```shell
$ chmod u+s /tmp/ddd
$ ls -l /tmp/ddd
-rwSr--r-- 1 root root 0 Nov  4 14:49 /tmp/ddd
```

当我们再追加`+x`可执行权限时，`S`变为了`s`

```shell
$ chmod u+x /tmp/ddd
$ ls -l /tmp/ddd
-rwsr--r-- 1 root root 0 Nov  4 14:49 /tmp/ddd
```

`setuid`的使用场景为：对归属`root`的程序/可执行文件（二进制）进行`setuid`，普通用户运行该程序时，是以程序所属的用户的身份(`root`)运行。

### SGID是什么？

`SGID`和`SUID`的不同之处就在于，`SUID`赋予用户的是文件所有者的权限，而`SGID`赋予用户的是文件所属组的权限。

对比一下：

- 设置`SUID`的文件权限

```shell
$ ls -l /tmp/ddd
-rwsr--r-- 1 root root 0 Nov  4 14:49 /tmp/ddd
```

- 设置`SGID`的文件权限

```shell
$ ls -l /tmp/ddd
-rw-r-sr-- 1 root root 0 Nov  4 14:53 /tmp/ddd
```

### cap_fsetid应用样例

那么让我们基于`CentOS7`，透过下面两个例子来理解`cap_fsetid`的功能：

> 测试不设置`cap_fsetid`情况下对含有`SUID/SGID`位的文件进行修改

1. 创建用户`test`，用于测试

```shell
$ adduser test
```

2. 使用`root`身份创建一个文件

```shell
$ touch /tmp/123
$ chmod 6777 /tmp/123
$ ls -l /tmp/123
-rwsrwsrwx 1 root root 0 Nov  4 15:02 /tmp/123
```

3. 切换至`test`用户对`/tmp/123`编辑写入

```shell
$ su - test
$ vim /tmp/123
$ ls -l /tmp/123
-rwxrwxrwx 1 root root 5 Nov  4 15:03 /tmp/123
```

此时我们发现，在对`/tmp/123`写入后，文件权限已然发生变化。（无`SUID/SGID`）

清理测试用例

```shell
$ rm -f /tmp/123
$ userdel -r test
```

> 测试设置`cap_fsetid`情况下对含有`SUID/SGID`位的文件进行修改

1. 创建用户`test`，用于测试

```shell
$ adduser test
```

2. 使用`root`身份创建一个文件

```shell
$ touch /tmp/123
$ chmod 6777 /tmp/123
$ ls -l /tmp/123
-rwsrwsrwx 1 root root 0 Nov  4 15:02 /tmp/123
```

3. 对`vim`添加`cap_fsetid`的功能

```shell
$ setcap cap_fsetid=eip /usr/bin/vim
```

4. 切换至`test`用户对`/tmp/123`编辑写入

```shell
$ su - test
$ vim /tmp/123
$ ls -l /tmp/123
-rwsrwsrwx 1 root root 24 Nov  4 15:07 /tmp/123
```

此时我们发现，在对`/tmp/123`写入后，文件权限并未发生变化。

清理测试用例

```shell
$ userdel -r test
$ setcap -r /usr/bin/vim
```