### 本地yum源

**适用于**

`主机不可以直连外网、且不可以通过代理访问外网`


> 1、查看操作系统

```shell
cat /etc/system-release
```

> 2、获取系统安装镜像

- 1、获取方式一：找系统运维管理员提供，推荐

- 2、获取方式二：自己下载，不推荐，文件大小一般`4G`左右，小版本一定要匹配！

官方下载地址：https://mirrors.aliyun.com/centos-vault/

> 3、上传挂载

注意路径、文件名需要替换，以下命令相当于将`CentOS-7-x86_64-DVD-1511.iso`，解压到`/media`

```shell
mount -o loop ~/CentOS-7-x86_64-DVD-1511.iso /media
```

> 4、卸载、拷贝、删除

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

```shell
yum update -y 
```