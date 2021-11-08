## cap_dac_override能力分析

- `cap_dac_override`: 忽略对文件的`DAC`访问权限限制

> 首先我们需要了解：`DAC`是什么？

`DAC`全称`Discretinoary Access Control`，即自主访问控制。

它是传统的`Linux`访问控制方式。资源所有者负责管理访问控制权限，并通过`ACL`(`Acess Control List`)管理非所有者权限。

例：

```shell
$ ls -l /etc/passwd
-rw-r--r-- 1 root root 988 Mar 18  2021 /etc/passwd
```

即通过`-rw-r--r--`控制用户对`/etc/passwd`的访问

> `cap_dac_override`能做什么？

赋予进程/可执行文件`cap_dac_override`后，可无视`DAC`访问权限限制

那么让我们基于`CentOS7`，透过下面例子来验证`cap_dac_override`的功能：

1. 创建用户`test`，用于测试

```shell
$ adduser test
```

2. 切换至`test`用户尝试向`/etc/passwd`追加内容

```shell
$ su - test
$ vim /etc/passwd
$ exit
```

写入数据后并不能保存，显然`test`不具备对`/etc/passwd`的写权限

```shell
$ ls -l /etc/passwd
-rw-r--r--    1 root     root          1223 Nov  4 02:16 /etc/passwd
```

3. 对`vim`添加`cap_dac_override`的功能

````shell
$ setcap cap_dac_override=eip /usr/bin/vim
````

4. 再次切换至`test`用户尝试向`/etc/passwd`追加内容

```shell
$ su - test
$ vim /etc/passwd
```

写入以下内容保存(:wq!)，保存成功

```
ddd:x:1001:1001::/home/ddd:/bin/bash
```

```shell
$ cat /etc/passwd
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
nobody:x:99:99:Nobody:/:/sbin/nologin
systemd-network:x:192:192:systemd Network Management:/:/sbin/nologin
dbus:x:81:81:System message bus:/:/sbin/nologin
polkitd:x:999:997:User for polkitd:/:/sbin/nologin
postfix:x:89:89::/var/spool/postfix:/sbin/nologin
chrony:x:998:996::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
test:x:1000:1000::/home/test:/bin/bash
ddd:x:1001:1001::/home/ddd:/bin/bash
```

5. 查看`vim`的`CAP`

```shell
$ getcap /usr/bin/vim
/usr/bin/vim = cap_dac_override+eip
```

清理`vim`的`CAP`

```shell
$ setcap -r /usr/bin/vim
```

清理测试用例

```shell
$ userdel -r test
$ sed -i '/ddd/d' /etc/passwd
```