### 阿里yum源

> 1、配置`DNS`解析

```shell
echo "nameserver 114.114.114.114" >> /etc/resolv.conf
```

> 2、删除原有`yum`源`repo`文件

```shell
rm -f /etc/yum.repos.d/*.repo
```

> 3、下载阿里`yum`源文件

- `CentOS 6`

```shell
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

```
- `CentOS 7`

```shell
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
```