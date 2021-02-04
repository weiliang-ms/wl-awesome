<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [vim升级](#vim%E5%8D%87%E7%BA%A7)
- [vim插件](#vim%E6%8F%92%E4%BB%B6)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## vim升级 ##

> 升级python

	yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel libffi-devel xz-devel gcc 

	wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0a1.tgz
	tar -xzvf Python-3.8.0a1.tgz
	cd Python-3.8.0a1
	./configure --prefix=/usr/local/python3 --enable-shared
	make && make install

	cp /usr/local/python3/lib/libpython3.8m.so.1.0 /usr/local/lib
	ldconfig

> 更改链接

	mv /usr/bin/python /usr/bin/python_bak
	ln -s /usr/local/python3/bin/python3 /usr/bin/python
	sed -i "s#/usr/bin/python#/usr/bin/python_bak#g" /usr/bin/yum
	sed -i "s#/usr/bin/python#/usr/bin/python_bak#g" /usr/libexec/urlgrabber-ext-down

> 卸载vim并安装依赖包

	yum remove vim -y
	yum install ncurses-devel -y

> 下载最新包，编译安装

	git clone https://github.com/vim/vim.git
	cd vim/src
	make
	make install

> 配置环境变量

	echo "export PATH=\$PATH:/usr/local/bin/vim" >> /etc/profile.d/path.sh
	. /etc/profile.d/path.sh

> 查看版本

	vim --version

![](images/vim_version.png)

## vim插件 ##


> 安装插件管理器

	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

> 创建目录

	mkdir ~/.vim/plugged

> 测试

	cat > ~/.vimrc <<EOF
	call plug#begin('~/.vim/plugged')
	Plug 'beanworks/vim-phpfmt' #添加要安装的插件
	call plug#end()
	EOF

	#测试安装
	vim
	:PlugInstall

> 安装vim-go

	#添加
	Plug 'gmarik/Vundle.vim'
	Plug 'fatih/vim-go'
	Plug  'Valloric/YouCompleteme'

> 安装vim-go下go的一些工具

	cd $GOPATH/src
	git clone https://github.com/golang/tools golang.org/x/tools

> 编译

	yum install -y build-essential cmake python3-dev
	cd ~/.vim/plugged/YouCompleteme

	

