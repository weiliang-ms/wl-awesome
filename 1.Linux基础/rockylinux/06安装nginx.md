## 基于源代码编译安装

**该种方式跨平台**

1. 下载源码包：

http://nginx.org/download/nginx-1.22.0.tar.gz

2. 安装编译依赖

```shell
$ yum install -y gcc pcre-devel zlib-devel
```

3. 编译安装

```shell
$ tar zxvf nginx-1.22.0.tar.gz
$ cd nginx-1.22.0
$ ./configure --prefix=/etc/nginx
$ make && make install
```

4. 启动

```shell
$ /etc/nginx/sbin/nginx
$ ps -ef|grep nginx
root       11230       1  0 09:36 ?        00:00:00 nginx: master process /etc/nginx/sbin/nginx
nobody     11231   11230  0 09:36 ?        00:00:00 nginx: worker process
root       11237    2920  0 09:37 pts/1    00:00:00 grep --color=auto nginx
```