### 本地yum源配置

**适用于**

`主机不可以直连外网、且不可以通过代理访问外网`

> 1、查看操作系统

```shell
cat /etc/system-release
```

> 2、获取系统安装镜像

- 1、获取方式一：找系统运维管理员提供，推荐

- 2、获取方式二：自己下载，不推荐，文件大小一般`4G`左右。下载版本>=当前系统版本，建议下载最新小版本（如操作系统为`7.4.1708`，则下载`7.4.1708`以上）

方便下载，推荐以下两个版本（`CentOS6、CentOS7`）：

- [CentOS-6.10-x86_64-bin-DVD1.iso](http://mirrors.sohu.com/centos/6.10/isos/x86_64/CentOS-6.10-x86_64-bin-DVD1.iso)
- [CentOS-7-x86_64-DVD-2009.iso](https://mirrors.tuna.tsinghua.edu.cn/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso)

> 3、上传挂载

注意路径、文件名需要替换，以下命令相当于将`CentOS-7-x86_64-DVD-2009.iso`，解压`iso`文件至`/media`

```shell
mount -o loop ~/CentOS-7-x86_64-DVD-2009.iso /media
```

> 4、卸载、拷贝、删除

这一步主要为了重启后不用重新挂载，当然多主机情况建议利用`nginx`等配置内网源`server`，以便其他服务器可以配置。

优势：减少无用的冗余数据占用存储空间。

```shell
mkdir -p /yum && cp -r /media/* /yum/
umout /media
```

> 5、删除原有yum源repo文件

````shell
rm -f /etc/yum.repos.d/*.repo
````

> 6、新建yum repo文件

```shell
tee /etc/yum.repos.d/c7.repo <<EOF
[c7repo]
name=c7repo
baseurl=file:///yum
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
```

> 7、测试

```shell
yum clean all && yum makecache
yum install -y telnet vim
```

> 8.更新

更新系统&软件（可选）

```shell
yum update -y 
```

> 9.删除因更新产生的配置文件

新产生的配置文件需联网使用，内网环境无法访问，需要删除，

```shell
rm -f /etc/yum.repos.d/CentOS-*.repo
```