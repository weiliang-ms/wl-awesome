<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [安装部署](#%E5%AE%89%E8%A3%85%E9%83%A8%E7%BD%B2)
  - [使用源码编译安装](#%E4%BD%BF%E7%94%A8%E6%BA%90%E7%A0%81%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85)
  - [使用预编译包安装](#%E4%BD%BF%E7%94%A8%E9%A2%84%E7%BC%96%E8%AF%91%E5%8C%85%E5%AE%89%E8%A3%85)
- [配置调优](#%E9%85%8D%E7%BD%AE%E8%B0%83%E4%BC%98)
- [安全加固](#%E5%AE%89%E5%85%A8%E5%8A%A0%E5%9B%BA)
- [相关文档](#%E7%9B%B8%E5%85%B3%E6%96%87%E6%A1%A3)
  - [keepalive及444状态码](#keepalive%E5%8F%8A444%E7%8A%B6%E6%80%81%E7%A0%81)
  - [nginx location匹配顺序](#nginx-location%E5%8C%B9%E9%85%8D%E9%A1%BA%E5%BA%8F)
  - [nginx重定向](#nginx%E9%87%8D%E5%AE%9A%E5%90%91)
  - [nginx http请求处理流程](#nginx-http%E8%AF%B7%E6%B1%82%E5%A4%84%E7%90%86%E6%B5%81%E7%A8%8B)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 配置为系统服务

> 生成文件

```shell
tee /usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
LimitNOFILE=65535
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/opt/nginx/sbin/nginx -t
ExecStart=/opt/nginx/sbin/nginx
ExecReload=/opt/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
```

> 启动

```shell
systemctl daemon-reload
systemctl enable nginx --now
```

> 查看nginx最大连接数

```shell
grep 'open files' /proc/$( cat /var/run/nginx.pid )/limits
```

> `nginx.conf`最大连接数配置

```shell
worker_rlimit_nofile 65535;
events {
use epoll;
worker_connections 65535;
}
```

## 安装部署
### 使用源码编译安装

**灵活性最高**

[官网下载地址](http://nginx.org/en/download.html)

[自用开源项目](https://github.com/weiliang-ms/wl-nginx)

### 使用预编译包安装

[参考地址](https://github.com/trimstray/nginx-admins-handbook/blob/master/doc/HELPERS.md#rhel7-or-centos-7)

**RHEL7 or CentOS 7**

`From EPEL`

	# Install epel repository:
	yum install epel-release
	# or alternative:
	#   wget -c https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	#   yum install epel-release-latest-7.noarch.rpm
	
	# Install NGINX:
	yum install nginx

`From Software Collections`

	# Install and enable scl:
	yum install centos-release-scl
	yum-config-manager --enable rhel-server-rhscl-7-rpms
	
	# Install NGINX (rh-nginx14, rh-nginx16, rh-nginx18):
	yum install rh-nginx16
	
	# Enable NGINX from SCL:
	scl enable rh-nginx16 bash

`From Official Repository`

	# Where:
	#   - <os_type> is: rhel or centos
	cat > /etc/yum.repos.d/nginx.repo << __EOF__
	[nginx]
	name=nginx repo
	baseurl=http://nginx.org/packages/<os_type>/$releasever/$basearch/
	gpgcheck=0
	enabled=1
	__EOF__
	
	# Install NGINX:
	yum install nginx

**Debian or Ubuntu**

`From Debian/Ubuntu Repository`

	# Install NGINX:
	apt-get install nginx

`From Official Repository`

	# Where:
	#   - <os_type> is: debian or ubuntu
	#   - <os_release> is: xenial, bionic, jessie, stretch or other
	cat > /etc/apt/sources.list.d/nginx.list << __EOF__
	deb http://nginx.org/packages/<os_type>/ <os_release> nginx
	deb-src http://nginx.org/packages/<os_type>/ <os_release> nginx
	__EOF__
	
	# Update packages list:
	apt-get update
	
	# Download the public key (or <pub_key> from your GPG error):
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <pub_key>
	
	# Install NGINX:
	apt-get update
	apt-get install nginx

## 配置调优

[nginx管理员手册](https://github.com/trimstray/nginx-admins-handbook)

[参考地址](https://www.jianshu.com/p/b649793191ee)

绑定cpu

	worker_processes     2;
	worker_cpu_affinity 01 10;
	
	#2核CPU,开启4个进程
	worker_processes     4;
	worker_cpu_affinity 01 10 01 10;
	
	#4核CPU，开户4个进程
	worker_processes     4;
	worker_cpu_affinity 0001 0010 0100 1000;

	#8核
	worker_processes 8;
	worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000;

打开文件数

	#与ulimit -n一致
	worker_rlimit_nofile 655350;

每个进程允许的最多连接数

	#ulimit -n / worker数量
	worker_connections 102400;

请求头部的缓冲区大小

	#与系统分页大小一致（getconf PAGESIZE获取分页大小）
	client_header_buffer_size 4k;

提高文件传输性能

	#开启高效文件传输模式，sendfile 指令指定 Nginx 是否调用sendfile 函数来输出文件，
	#对于普通应用设为 on，如果用来进行下载等应用磁盘 IO 重负载应用，可设置为 off，
	#以平衡磁盘与网络 I/O 处理速度，降低系统的负载。
	sendfile on;

小的数据包不等待直接传输

	tcp_nodelay on;

开启gzip压缩

	gzip on;
	gzip_min_length 1100;
	#对数据启用压缩的最少字节数,如:请求小于1K文件,不要压缩,压缩小数据会降低处理此请求的所有进程速度
	gzip_buffers 4 16k;
	gzip_proxied any;
	#允许或者禁止压缩基于请求和响应的响应流,若设置为any,将会压缩所有请求
	gzip_http_version 1.0;
	gzip_comp_level 9;
	#gzip压缩等级在0-9内,数值越大压缩率越高,CPU消耗也就越大
	gzip_types text/plain text/css application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript application/json image/jpeg image/gif image/png;
	#压缩类型
	gzip_vary on;
	#varyheader支持,让前端的缓存服务器识别压缩后的文件,代理


	open_file_cache max=65535 inactive=20s;
	#这个将为打开文件指定缓存,max 指定缓存数量.建议和打开文件数一致.inactive 是指经过多长时间文件没被请求后删除缓存
	open_file_cache_valid 30s;
	#这个是指多长时间检查一次缓存的有效信息,例如我一直访问这个文件,30秒后检查是否更新,反之更新
	open_file_cache_min_uses 2;
	#定义了open_file_cache中指令参数不活动时间期间里最小的文件数
	open_file_cache_errors on;
	#NGINX可以缓存在文件访问期间发生的错误,这需要设置该值才能有效,如果启用错误缓存.则在访问资源（不查找资源）时.NGINX会报告相同的错误

关闭404日志记录

	log_not_found off;

## 安全加固

隐藏版本号

	server_tokens off;

修改server名
	
	more_set_headers "Server: web";

配置host白名单

	#结合开源项目，定期更新IP黑名单

[项目地址](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker)

	#结合lua维护白名单
	-- 校验Host合法性
	function host_check(host)
	    if tableFind(host,valid_hosts) == false
	      then
		record_attack_log("BadHost")
		ngx.exit(444)
	    end
	end

配置refer黑白名单

	#结合开源项目，定期更新refer黑名单

[项目地址](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker)

	#结合lua维护白名单
	-- 校验Referer合法性
	function referer_check(refer,host)
	    if refer ~= nil and string.find(refer,host) == nil 
	      then 
	        if tableFind(refer,valid_referers) == false
	          then
		    record_attack_log("BadRefer")
	            ngx.exit(444)
	        end
	    end
	end

拦截sql注入

[naxsi](https://github.com/nbs-system/naxsi)

	结合naxsi模块

拦截XSS攻击

[naxsi](https://github.com/nbs-system/naxsi)

	结合naxsi模块

[SSL/TLS](https://github.com/trimstray/nginx-admins-handbook/blob/master/doc/RULES.md#beginner-keep-only-tls-13-and-tls-12)

	ssl_protocols TLSv1.3 TLSv1.2;

> 使用tls时关闭gzip

`Some attacks are possible (e.g. the real BREACH attack is a complicated) because of gzip (HTTP compression not TLS compression) being enabled on SSL requests. In most cases, the best action is to simply disable gzip for SSL.`

	gzip off;

> 降低XSS劫持配置

	add_header Content-Security-Policy "default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self';" always;
	add_header X-XSS-Protection "1; mode=block" always;

> 配置Referrer-Policy

**refer介绍**

[https://scotthelme.co.uk/a-new-security-header-referrer-policy/](https://scotthelme.co.uk/a-new-security-header-referrer-policy/)
	
	#http请求分为请求行，请求头以及请求体，而请求头又分为general，request headers，此字段设置与general中，用来约定request headers中的referer

	#任何情况下都不发送referer
	add_header Referrer-Policy "origin";

**可选值**

	"no-referrer",                     #任何情况下都不发送referer
	"no-referrer-when-downgrade",      #在同等安全等级下（例如https页面请求https地址），发送referer，但当请求方低于发送方（例如https页面请求http地址），不发送referer
	"same-origin",                     #当双方origin相同时发送
	"origin",                          #仅仅发送origin，即protocal+host
	"strict-origin",                   #当双方origin相同且安全等级相同时发送
	"origin-when-cross-origin",        #跨域时发送origin
	"strict-origin-when-cross-origin",
	"unsafe-url"                       #任何情况下都显示完整的referer

> 配置X-Frame-Option

	add_header X-Frame-Options "SAMEORIGIN" always;

> 配置Feature-Policy

Feature Policy是一个新的http响应头属性，允许一个站点开启或者禁止一些浏览器属性和API，来更好的确保站点的安全性和隐私性。 可以严格的限制站点允许使用的属性是很愉快的，而可以对内嵌在站点中的iframe进行限制则更加增加了站点的安全性。

**W3C标准**

[https://w3c.github.io/webappsec-feature-policy/](https://w3c.github.io/webappsec-feature-policy/)

	add_header Feature-Policy "geolocation 'none'; midi 'none'; notifications 'none'; push 'none'; sync-xhr 'none'; microphone 'none'; camera 'none'; magnetometer 'none'; gyroscope 'none'; speaker 'none'; vibrate 'none'; fullscreen 'none'; payment 'none'; usb 'none';";

## 相关文档

### keepalive及444状态码 ###

**keepalive**

该配置官方文档给出的默认值为75s

[官方文档地址](http://nginx.org/en/docs/http/ngx_http_core_module.html#variables)

> 1、nginx keepalive配置方便起见配置为30s

	#配置于nginx.conf 中的 http{}内
	keepalive_timeout 30s;

![](imageseepalive_30.png)

> 2、nginx server配置

	server {
        listen 8089;
        location /123 {
                proxy_pass http://192.168.1.145:8080;
        }
        location / {
                index html/index.html;
        }
	}

> 3、开启wireshark监听虚拟网卡（nginx部署于本地vmware上的虚机，nat模式）

![](imagesireshark_01.png)

> 4、使用POSTMAN发送请求

![](imagesostman.png)

> 5、wireshark过滤观察

![](imageseepalive_01.png)

keepalive与断开连接

![](imageseepalive_02.png)

**444状态码**

适用于屏蔽非安全请求或DDOS防御

> 1、nginx server配置

	server {
        listen 8089;
        location /123 {
                proxy_pass http://192.168.1.145:8080;
        }
        location / {
                index html/index.html;
        }

		location /abc {
                return 444;
        }
	}

> 2、开启wireshark监听虚拟网卡（nginx部署于本地vmware上的虚机，nat模式）

![](imagesireshark_01.png)

> 3、发送请求

![](imagesostman2.png)

> 4、wireshark过滤观察

![](imagesireshark_02.png)

### nginx http请求处理流程 ###

**参考文章**

[https://github.com/trimstray/nginx-admins-handbook#introduction](https://github.com/trimstray/nginx-admins-handbook#introduction "参考文章")

[https://blog.51cto.com/wenxi123/2296295?source=dra](https://blog.51cto.com/wenxi123/2296295?source=dra)

**nginx处理一个请求共分为11个阶段**

> 阶段一，NGX_HTTP_POST_READ_PHASE

	获取请求头信息
	#相关模块: ngx_http_realip_module

> 阶段二，NGX_HTTP_SERVER_REWRITE_PHASE

	实现在server{}块中定义的重写指令:
	使用PCRE正则表达式更改请求uri，返回重定向uri；
	#相关模块: ngx_http_rewrite_module

> 阶段三，NGX_HTTP_FIND_CONFIG_PHASE

	**仅nginx核心模块可以参与**
	根据阶段二的uri匹配location

> 阶段四，NGX_HTTP_REWRITE_PHASE

	由阶段三匹配到location，并在location{}块中再次进行uri转换
	#相关模块: ngx_http_rewrite_module

> 阶段五，NGX_HTTP_POST_REWRITE_PHASE

	**仅nginx核心模块可以参与**
	请求地址重写提交阶段，防止递归修改uri造成死循环，（一个请求执行10次就会被nginx认定为死循环）
	#相关模块: ngx_http_rewrite_module

> 阶段六，NGX_HTTP_PREACCESS_PHASE

	访问控制阶段一：
	验证预处理请求限制，访问频率、连接数限制（访问限制）
	#相关模块：ngx_http_limit_req_module, ngx_http_limit_conn_module, ngx_http_realip_module

> 阶段七，NGX_HTTP_ACCESS_PHASE

	访问控制阶段二：
	客户端验证(源IP是否合法，是否通过HTTP认证)
	#相关模块：ngx_http_access_module, ngx_http_auth_basic_module

> 阶段八，NGX_HTTP_POST_ACCESS_PHASE

	**仅nginx核心模块可以参与**
	访问控制阶段三：
	访问权限检查提交阶段；如果请求不被允许访问nginx服务器，该阶段负责向用户返回错误响应；
	#相关模块：ngx_http_access_module, ngx_http_auth_basic_module

> 阶段九，NGX_HTTP_PRECONTENT_PHASE

	**仅nginx核心模块可以参与**
	如果http请求访问静态文件资源，try_files配置项可以使这个请求顺序地访问多个静态文件资源，直到某个静态文件资源符合选取条件
	#相关模块：ngx_http_try_files_module

> 阶段十，NGX_HTTP_CONTENT_PHASE

	内容产生阶段，大部分HTTP模块会介入该阶段，是所有请求处理阶段中最重要的阶段，因为这个阶段的指令通常是用来生成HTTP响应内容的；

	#相关模块：ngx_http_index_module, ngx_http_autoindex_module, ngx_http_gzip_module

> 阶段十一，NGX_HTTP_LOG_PHASE

	记录日志阶段
	#相关模块：ngx_http_log_module

> 示例图

![request-flow.png](https://upload-images.jianshu.io/upload_images/1967881-0f25f669eea357c2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)