### 阿里yum源

> 1、配置DNS解析

	echo "nameserver 114.114.114.114" >> /etc/resolv.conf

> 2、删除原有yum源repo文件

	rm -f /etc/yum.repos.d/*.repo
	
> 3、下载阿里yum源文件

CentOS 6
	
	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

CentOS 7

	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
	
### 本地yumy源

**适用于**

`主机不可以直连外网、且不可以通过代理访问外网`


> 1、查看操作系统

	cat /etc/system-release


> 2、获取系统安装镜像

	#DVD版或Everything版本

	#1、获取方式一：找系统运维管理员提供，推荐
	让系统管理员帮挂载到/media 或 上传至 /root下

	#2、获取方式二：自己下载，不推荐，文件大小一般4G左右，小版本一定要匹配！
	官方下载地址：https://wiki.centos.org/Download

> 3、上传挂载

	#注意路径、文件名需要替换，以下命令相当于将CentOS-7-x86_64-DVD-1511.iso，解压到/media
	mount -o loop ~/CentOS-7-x86_64-DVD-1511.iso /media

> 4、卸载、拷贝、删除

	mkdir -p /yum && cp -r /media/* /yum/
	unmout /media

> 5、删除原有yum源repo文件

	rm -f /etc/yum.repos.d/*.repo

> 6、新建yum repo文件

	cat >> /etc/yum.repos.d/c7.repo <<EOF
	[c7repo]
	
	name=c7repo
	
	baseurl=file:///yum
	
	enabled=1
	
	gpgcheck=0
	
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
	EOF

> 7、测试

	yum clean all && yum makecache
	yum install -y telnet vim