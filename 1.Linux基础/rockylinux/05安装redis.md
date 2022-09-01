## 基于源代码编译安装

**该种方式跨平台**

1. 下载源码包：

https://download.redis.io/releases/redis-5.0.14.tar.gz

2. 安装编译依赖

```shell
$ yum install -y gcc
```

3. 编译安装

```shell
$ tar zxvf redis-5.0.14.tar.gz
$ cd redis-5.0.14
$ make && make install
```

4. 启动

```shell
$ /usr/local/bin/redis-server redis.conf
7181:C 17 Aug 2022 09:30:39.730 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
7181:C 17 Aug 2022 09:30:39.730 # Redis version=5.0.12, bits=64, commit=00000000, modified=0, pid=7181, just started
7181:C 17 Aug 2022 09:30:39.730 # Configuration loaded
7181:M 17 Aug 2022 09:30:39.731 * Increased maximum number of open files to 10032 (it was originally set to 1024).
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 5.0.14 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 7181
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

7181:M 17 Aug 2022 09:30:39.732 # Server initialized
7181:M 17 Aug 2022 09:30:39.732 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
7181:M 17 Aug 2022 09:30:39.732 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
7181:M 17 Aug 2022 09:30:39.732 * Ready to accept connections
```