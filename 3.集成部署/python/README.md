## Python3.6

    yum install -y python36 python36-pip python36-devel

## Python3.7

1.下载源码包：https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz

2. 安装编译依赖

```shell
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
```

3. 编译安装

```shell
tar zxvf Python-3.9.18.tgz
cd Python-3.9.18
./configure
make && make install
make altinstall
```
