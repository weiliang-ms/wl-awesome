
- [包管理器](#%E5%8C%85%E7%AE%A1%E7%90%86%E5%99%A8)
  - [yum](#yum)
    - [阿里yum源](#%E9%98%BF%E9%87%8Cyum%E6%BA%90)
    - [本地yum源](#%E6%9C%AC%E5%9C%B0yum%E6%BA%90)
    - [导出依赖与使用](#%E5%AF%BC%E5%87%BA%E4%BE%9D%E8%B5%96%E4%B8%8E%E4%BD%BF%E7%94%A8)
    - [安装加速插件](#%E5%AE%89%E8%A3%85%E5%8A%A0%E9%80%9F%E6%8F%92%E4%BB%B6)
  - [apt](#apt)
    - [配置清华源](#%E9%85%8D%E7%BD%AE%E6%B8%85%E5%8D%8E%E6%BA%90)
  - [pip](#pip)
    - [配置pip](#%E9%85%8D%E7%BD%AEpip)
  - [gem](#gem)
    - [gem源配置](#gem%E6%BA%90%E9%85%8D%E7%BD%AE)


# 包管理器

管理安装软件及其依赖

## yum
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
	
### 本地yum源

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
	
### 导出依赖与使用

导出（yum源可用）

    yum install yum-plugin-downloadonly -y
    yum install --downloadonly --downloaddir=./gcc gcc

生成repo依赖关系

    yum install -y createrepo
    createrepo ./gcc

压缩

    tar zcvf gcc.tar.gz gcc
    
使用（yum源不可用）

    tar zxvf gcc.tar.gz -C /
    
    cat > /etc/yum.repos.d/gcc.repo <<EOF
    [gcc]
    name=python-repo
    baseurl=file:///gpc
    gpgcheck=0
    enabled=1
    EOF
    
    yum install -y gcc

### 安装加速插件

    yum install yum-plugin-fastestmirror -y
    
## apt
### 配置清华源

> 清理已有源

```bash
rm -f /etc/apt/sources.list.d/*
```    

> 添加清华源

```bash
cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
EOF
```

> 更新

```bash
sudo apt-get update
```

## pip
### 配置pip

> 配置源

    mkdir ~/.pip
    cat >> ~/.pip/pip.conf <<EOF
    [global] 
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple
    #proxy=http://xxx.xxx.xxx.xxx:8080
    [install]
    trusted-host = pypi.tuna.tsinghua.edu.cn
    EOF
    
> 下载包（只下载不安装）

    pip download -d <directory> -r requirement.txt
    
`requirement.txt`格式内容

    scipy
    numpy
    jupyter
    ipython
    easydict
    Cython
    h5py
    numpy
    mahotas
    requests
    bs4
    lxml
    pillow
    redis
    torch
    torchvision
    paramiko
    pycrypto
    uliengineering
    matplotlib
    keras==2.1.5
    web.py==0.40.dev0
    scikit-image==0.15.0
    lmdb
    pandas
    opencv-contrib-python==4.0.0.21
    tensorflow-gpu==1.8
    
> 安装（离线导出）包

    pip3 install --no-index --find-links=./pip -r requirement.txt

## gem
### gem源配置

> 查看默认源

```bash
gem sources -l
```    
> 配置代理

修改文件`/usr/bin/gem`

```bash
begin
  args += ['--http-proxy','http://x.x.x.x:port']
  Gem::GemRunner.new.run args
rescue Gem::SystemExitException => e
  exit e.exit_code
end
```
> 修改默认源

```bash
gem sources -r https://rubygems.org/ -a https://gems.ruby-china.com/
bundle config mirror.https://rubygems.org https://gems.ruby-china.com
```