## cap_kill能力分析

- `cap_kill`: 允许对不属于自己的进程发送信号

举个简单的例子：

默认情况下普通用户是不能`kill`根用户进程的，但如果我们赋予`/bin/kill`以`cap_kill`能力后，普通用户就会拥有`kill`其他用户（包括`root`）进程的权限。

> 让我们通过下面的例子加深理解

1. 创建用户`test`，用于测试

```shell
$ adduser test
```

2. 以`root`身份运行一个进程

```shell
$ python -m SimpleHTTPServer 9099
```

3. 新建会话，获取进程`Pid`，并以`test`身份`kill`掉

```shell
$ su - test
$ /bin/kill -9 `ps -ef|grep "python -m SimpleHTTPServer 9099" | grep -v grep|awk '{print $2}'`
kill: sending signal to 62220 failed: Operation not permitted
```

显然不具备权限

4. 切换至`root`用户对`kill`指令添加`CAP_KILL`能力

```shell
$ setcap cap_kill=eip /bin/kill 
```

5. 切换至`test`用户再次执行`kill`

```shell
$ su - test
$ /bin/kill -9 `ps -ef|grep "python -m SimpleHTTPServer 9099" | grep -v grep|awk '{print $2}'`
```

此时`test`用户`kill`掉了属主为`root`的进程

**注意：** 必须为`/bin/kill`绝对路径引用，否则不生效

6. 清理测试用例

```shell
$ setcap -r /bin/kill
$ userdel -r test 
```
