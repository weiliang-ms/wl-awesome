### 操作用户 ###

> 1.root下创建用户neusoft

	#创建neusoft用户，且初始化密码为1234%^&*
	useradd -m neusoft  && echo "1234%^&*" | passwd --stdin neusoft

> 2.删除用户及该用户HOME目录

	#删除neusoft用户及该用户HOME目录(/home/neusoft)
	userdel -r neusoft

> 3.切换用户

**千万不要用 su neusoft这种形式切换用户**

**会导致环境变量无法被切换**

	su - neusoft

### 操作目录 ###

> 1.查看当前目录路径

	pwd
	#或
	dir
	
> 2.切换工作目录

	#切换到某个目录
	cd /usr/local
	
	#进入当前目录下的src目录
	cd ./src
	
	#进入当前目录上一级目录下的src目录
	cd ../src
	
	#进入当前用户主目录
	cd ~

	#返回上一次执行cd命令的目录
	cd -
	
> 3.删除某一目录及目录下的子目录及子文件

	rm -rf /usr/local/src/test

> 4.创建目录

	#如果不存在就创建
	mkdir -p src/bin

> 5.移动目录

	#移动文件：mv 目录 目标目录
	mv ./src /root/

> 6.重命名目录

	mv src src_2018

### 操作文件 ###

> 1.将文件内容输出到控制台

	cat app-start.sh

> 2.实时输出文件内容

	#实时输出~/log/app.log的最后200行
	tail -200f ~/log/app.log

> 3.删除文件rm
	
	#-f表示强制（force）
	rm -f app-start.sh

> 4.查看文件md5

	md5sum filename

> 5.编辑文件

	vi filename

> 6.vi用法(英文输入法下)

	#1.关闭保存
	:wq!
	#2.强制退出
	:q!
	#3.进入编辑模式,英文输入法下输入
	i 或者 o 或者 a 或者 insert
	#4.匹配关键字，英文输入法下
	/关键字
	
	#5.光标移动到行尾
	
	shift + 4
	
	#6.光标移动到第一段
	
	shift + h
	
	#7.光标移动到最后一段

	shift + g
	
	#8.将当前行找到的所有str1替换为str2
	
	:s/str1/str2/g

### 操作进程　　　　

> 1.查看进程信息

	#ps -ef|grep 进程关键字
	ps -ef|grep redis

> 2.杀死进程kill

	#暴力杀
	kill -9 PID
	#PID由 ps -ef|grep 进程关键字   获取（第二列内容）

### 操作网络 ###

> 1.查看端口占用

	netstat -apn |grep 8080
	ss -aln |grep 8080

> 2.查看端口是否可以访问

**主要用以检测网络连通性及服务可用性**

	#需要安装telnet（yum install -y telnet）
	telnet 192.168.1.1 8080

	#推荐这种测试方法
	curl 192.168.1.1:8080

### 高阶用法 ###

> 开启tcp端口监听（测试网络连通性）

    python -m SimpleHTTPServer 9099

> 文件切割

	split -d -b 100m enterprise.log  enterprise-

> 磁盘占用异常排查

	https://www.cnblogs.com/paul8339/p/6381946.html

	#查找
	du -m --max-depth=1 |sort -gr

	lsof |grep delete

	#删除
	lsof |grep delete|awk '{print $2}'|xargs -n1 kill -9

	#恢复删除文件（句柄未释放）
	https://segmentfault.com/a/1190000000461077

> yum下载依赖到本地

	yum install -y yum-utils
	yumdownloader --resolve --destdir=/root/gcc gcc