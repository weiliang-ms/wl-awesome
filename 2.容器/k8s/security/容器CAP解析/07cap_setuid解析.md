## cap_setuid能力分析

- `cap_setuid`: 允许普通用户使用`setuid`函数

> 让我们通过下面的例子了解`cap_setuid`

1. 创建用户`test`，用于测试

```shell
$ adduser test
```

2. `root`身份创建文件`/tmp/ddd`

```shell
$ whoami
root
$ echo "123" > /tmp/ddd
$ chmod 640 /tmp/ddd
```

4. 编写一个`c`程序来使用`setuid()`函数

函数说明：`setuid()`用来重新设置执行目前进程的用户识别码。
不过, 要让此函数有作用, 其有效的用户识别码必须为0(`root`). 在`Linux`下, 当`root`使用`setuid()`来变换成其他用户识别码时, `root`权限会被抛弃, 完全转换成该用户身份。
也就是说, 该进程往后将不再具有可`setuid()`的权利, 如果只是想暂时抛弃`root`权限, 稍后想重新取回权限, 则必须使用`seteuid()`.

```shell
$ su - test
$ tee ~/demo.c <<EOF
#include <unistd.h>
int main ()
{
    gid_t uid = 0;
    setuid(uid);
    system("/bin/cat /tmp/ddd");
    return 0;
}
EOF
```

5. 以`test`用户执行`demo`程序

```shell
$ whoami
test
$ gcc demo.c -o demo
$ ./demo
/bin/cat: /tmp/ddd: Permission denied
```

显然默认情况下不具备调用`setuid()`函数的权限

6. 切换`root`用户，授予`/home/test/demo`以`CAP_SETUID`能力

```shell
$ whoami
root
$ setcap cap_setuid=eip /home/test/demo
```

7. 切换至`test`用户再次执行`/home/test/demo`

```shell
$ whoami
test
$ /home/test/demo
123
```

此时`test`用户通过执行`demo`程序，拥有了读取`/tmp/ddd`文件内容的权限，而`test`用户依旧不具备该权限:

```shell
$ whoami
test
$ cat /tmp/ddd
cat: /tmp/ddd: Permission denied
```

这是因为通过对`/home/test/demo`程序授予了`cap_setuid`的能力，允许程序可以使用`setuid()`函数。而通过`setuid()`函数，`/home/test/demo`修改了进程属主为`root`（修改前为`test`）
进而拥有了对`/tmp/ddd`文件的读权限。

清理测试用例

```shell
$ userdel -r test
```
