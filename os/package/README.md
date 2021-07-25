- [包管理器](#%E5%8C%85%E7%AE%A1%E7%90%86%E5%99%A8)
  - [yum](#yum)
    - [阿里yum源](#%E9%98%BF%E9%87%8Cyum%E6%BA%90)
    - [本地yum源](#%E6%9C%AC%E5%9C%B0yum%E6%BA%90)
    - [导出依赖与使用](#%E5%AF%BC%E5%87%BA%E4%BE%9D%E8%B5%96%E4%B8%8E%E4%BD%BF%E7%94%A8)
    - [安装加速插件](#%E5%AE%89%E8%A3%85%E5%8A%A0%E9%80%9F%E6%8F%92%E4%BB%B6)
    - [rpm制作](#rpm%E5%88%B6%E4%BD%9C)
  - [apt](#apt)
    - [配置清华源](#%E9%85%8D%E7%BD%AE%E6%B8%85%E5%8D%8E%E6%BA%90)
  - [pip](#pip)
    - [配置pip](#%E9%85%8D%E7%BD%AEpip)
  - [gem](#gem)
    - [gem源配置](#gem%E6%BA%90%E9%85%8D%E7%BD%AE)
  - [helm](#helm)
    - [版本说明](#%E7%89%88%E6%9C%AC%E8%AF%B4%E6%98%8E)
    - [Helm 组件及相关术语](#helm-%E7%BB%84%E4%BB%B6%E5%8F%8A%E7%9B%B8%E5%85%B3%E6%9C%AF%E8%AF%AD)
    - [helm安装](#helm%E5%AE%89%E8%A3%85)
    - [创建应用](#%E5%88%9B%E5%BB%BA%E5%BA%94%E7%94%A8)

# 包管理器

管理安装软件及其依赖

## choco

管理员运行`cmd`，执行

```shell script
@powershell -NoProfile -ExecutionPolicy Bypass -Command 
       "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=
       %PATH
       %;
       %ALLUSERSPROFILE
       %\chocolatey\bin
```

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
    
### rpm制作

> 安装rpmbuild

    yum install rpm-build -y

> 创建目录

    mkdir ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

> 编写`~/rpmbuild/SPECS/nginx.spec`

样例

    %define realname nginx
    
    %define orgnize neu
    
    %define realver 1.18.0
    
    %define srcext tar.gz
    
    %define opensslVersion openssl-1.0.2r
    
    # Common info
    
    Name: %{realname}
    
    Version: %{realver}
    
    Release: %{orgnize}%{?dist}
    
    Summary:Nginx is a web server software
    
    License:GPL
    
    URL:http://nginx.org
    
    Source0: %{realname}-%{realver}%{?extraver}.%{srcext}
    
    Source1: %{opensslVersion}.tar.gz
    
    Source2: headers-more-nginx-module-master.tar.gz
    
    Source3: naxsi-0.56.tar.gz
    
    Source4: nginx_upstream_check_module-master.tar.gz
    
    Source5: ngx-fancyindex-master.tar.gz
    
    Source6: ngx_cache_purge-2.3.tar.gz
    
    Source11: nginx.logrotate
    
    #Source12: nginx.conf
    
    Source13: conf
    
    Source14: nginx
    
    Source21: pcre-8.44.tar.gz
    
    Source22: zlib-1.2.11.tar.gz
    
    Source23: LuaJIT-2.0.5.tar.gz
    
    Source24: lua-nginx-module-0.10.13.tar.gz
    
    Source25: ngx_devel_kit-0.3.0.tar.gz
    
    #Patch:         nginx-memset_zero.patch
    
    # Install-time parameters
    Provides:      httpd http_daemon webserver %{?suse_version:suse_help_viewer}
    Requires:      logrotate
    
    #BuildRequires: gcc zlib-devel pcre-devel
    
    %description
    
    nginx [engine x] is an HTTP and reverse proxy server
    
    %post
    
    chkconfig nginx on
    
    sed -i "/* soft nofile 655350/d" /etc/security/limits.conf
    echo "* soft nofile 655350" >> /etc/security/limits.conf
    
    sed -i "/* hard nofile 655350/d" /etc/security/limits.conf
    echo "* hard nofile 655350" >> /etc/security/limits.conf
    
    sed -i "/* soft nproc 65535/d" /etc/security/limits.conf
    echo "* soft nproc 65535" >> /etc/security/limits.conf
    
    sed -i "/* hard nproc 65535/d" /etc/security/limits.conf
    echo "* hard nproc 65535" >> /etc/security/limits.conf
    
    #sed -i '/\/etc\/logrotate.d\/nginx/d' /etc/crontab
    #echo "0 0 * * * root bash /usr/sbin/logrotate -f /etc/logrotate.d/nginx" >> /etc/crontab
    mkdir -p ~/.vim
    cp -r -v /opt/nginx/vim ~/.vim/
    cat > ~/.vim/filetype.vim <<EOF
    au BufRead,BufNewFile /opt/nginx/conf/conf.d/*.conf set ft=nginx
    EOF
    
    chmod +x /opt/nginx/lj2/lib/*
    
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/nginx/lj2/lib
    ldconfig
    
    # Preparation step (unpackung and patching if necessary)
    
    %prep
    %setup -q -n %{realname}-%{realver}%{?extraver} -a1 -a2 -a3 -a4 -a5 -a6 -a21 -a22 -a23 -a24 -a25
    #%patch -p1
    
    %build
    
    # pcre-devel
    
    #cd pcre-8.44
    #./configure --prefix=/usr/local/pcre-devel
    #make -j $(nproc)
    #make install
    
    # lua
    cd LuaJIT-2.0.5 && make -j $(nproc) && \
      make install PREFIX=%{_builddir}/%{realname}-%{realver}%{?extraver}/lj2
    
    cd ../
    ls
    ls ./lua-nginx-module-0.10.13
    export LUAJIT_LIB=%{_builddir}/%{realname}-%{realver}%{?extraver}/lj2/lib
    export LUAJIT_INC=%{_builddir}/%{realname}-%{realver}%{?extraver}/lj2/include/luajit-2.0
    
    #./configure --prefix=/opt/nginx --with-stream --pid-path=/var/run/nginx.pid --add-module=%{_builddir}/%{realname}-%{realver}%{?extraver}/ngx_devel_kit-0.3.0 --add-module=%{_builddir}/%{realname}-%{realver}%{?extraver}/lua-nginx-module-0.10.13
    ./configure --prefix=/opt/nginx --with-stream \
    	--pid-path=/var/run/nginx.pid \
    	--with-openssl=%{_builddir}/%{realname}-%{realver}%{?extraver}/%{opensslVersion} \
            --with-pcre=%{_builddir}/%{realname}-%{realver}%{?extraver}/pcre-8.44 \
    	--with-zlib=%{_builddir}/%{realname}-%{realver}%{?extraver}/zlib-1.2.11 \
    	--with-stream_ssl_preread_module --with-stream_ssl_module \
    	--with-http_stub_status_module --with-http_ssl_module \
    	--with-http_gzip_static_module \
    	--add-module=./ngx_cache_purge-2.3 \
            --add-module=./headers-more-nginx-module-master \
    	--add-module=./naxsi-0.56/naxsi_src \
    	--add-module=./ngx-fancyindex-master \
    	--add-module=./ngx_devel_kit-0.3.0 \
            --add-module=./lua-nginx-module-0.10.13
    
    make -j $(nproc)
    
    %install
    %__make install DESTDIR=%{buildroot}
    iconv -f koi8-r CHANGES.ru > c && %__mv -f c CHANGES.ru
    %__install -d %{buildroot}~/.vim
    %__install -D -m755 %{S:11} %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
    %__install -D -m755 %{S:14} %{buildroot}%{_sysconfdir}/init.d/%{name}
    %__cp -r -v %{_builddir}/%{realname}-%{realver}%{?extraver}/lj2 %{buildroot}/opt/nginx/
    %__cp -r -v %{_builddir}/%{realname}-%{realver}%{?extraver}/contrib/vim %{buildroot}/opt/nginx/
    %__cp -r -v %{S:13}/* %{buildroot}/opt/nginx/conf/
    
    %clean
    [ "%{buildroot}" != "/" ] && rm -rf %{buildroot}
    
    %files
    %config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
    %config(noreplace) %{_sysconfdir}/init.d/%{name}
    %doc
    /opt/nginx/*
    %changelog

> 构建

    rpmbuild -ba ~/rpmbuild/SPECS/nginx.spec
    
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

## helm

`Kubernetes`的软件包管理工具

### 版本说明

`Helm 2` 是 `C/S` 架构，主要分为客户端 `helm` 和服务端 `Tiller`; 
`Helm 3` 中移除了 `Tiller`, 版本相关的数据直接存储在了 `Kubernetes` 中

### Helm 组件及相关术语

- helm

`Helm` 是一个命令行下的客户端工具。主要用于 `Kubernetes` 应用程序 `Chart` 的创建、打包、发布以及创建和管理本地和远程的 `Chart` 仓库。

- Chart

`Helm` 的软件包，采用 `TAR` 格式。类似于 `APT` 的 `DEB` 包或者 `YUM` 的 `RPM` 包，其包含了一组定义 `Kubernetes` 资源相关的 `YAML` 文件。

- Repoistory

`Helm` 的软件仓库，`Repository` 本质上是一个 `Web` 服务器，该服务器保存了一系列的 `Chart` 软件包以供用户下载，并且提供了一个该 `Repository` 的 `Chart` 包的清单文件以供查询。`Helm` 可以同时管理多个不同的 `Repository`。

- Release

使用 `helm install` 命令在 `Kubernetes` 集群中部署的 `Chart` 称为 `Release`。可以理解为 `Helm` 使用 `Chart` 包部署的一个应用实例

### helm安装

> 下载`helm release`压缩包

- [release版本](https://github.com/helm/helm/releases)

> 解压，添加到PATH

### 创建应用

> 初始化

    [root@node3 cloud]# helm create redis
    Creating redis
    
> 应用目录结构

    [root@node3 cloud]# tree redis/
    redis/
    ├── charts
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── _helpers.tpl
    │   ├── hpa.yaml
    │   ├── ingress.yaml
    │   ├── NOTES.txt
    │   ├── serviceaccount.yaml
    │   ├── service.yaml
    │   └── tests
    │       └── test-connection.yaml
    └── values.yaml
