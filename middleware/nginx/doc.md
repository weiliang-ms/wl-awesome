<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [nginx](#nginx)
    - [keepalive及444状态码](#keepalive%E5%8F%8A444%E7%8A%B6%E6%80%81%E7%A0%81)
    - [nginx location匹配顺序](#nginx-location%E5%8C%B9%E9%85%8D%E9%A1%BA%E5%BA%8F)
    - [nginx重定向](#nginx%E9%87%8D%E5%AE%9A%E5%90%91)
    - [nginx http请求处理流程](#nginx-http%E8%AF%B7%E6%B1%82%E5%A4%84%E7%90%86%E6%B5%81%E7%A8%8B)
- [nginx调优](#nginx%E8%B0%83%E4%BC%98)
    - [安全加固](#%E5%AE%89%E5%85%A8%E5%8A%A0%E5%9B%BA)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# nginx #

### keepalive及444状态码 ###

**keepalive**

该配置官方文档给出的默认值为75s

[官方文档地址](http://nginx.org/en/docs/http/ngx_http_core_module.html#variables)

> 1、nginx keepalive配置方便起见配置为30s

	#配置于nginx.conf 中的 http{}内
	keepalive_timeout 30s;

![](./images/keepalive_30.png)

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

![](./images/wireshark_01.png)

> 4、使用POSTMAN发送请求

![](./images/postman.png)

> 5、wireshark过滤观察

![](./images/keepalive_01.png)

keepalive与断开连接

![](./images/keepalive_02.png)

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

![](./images/wireshark_01.png)

> 3、发送请求

![](./images/postman2.png)

> 4、wireshark过滤观察

![](./images/wireshark_02.png)
	

### nginx location匹配顺序 ###

**例子来源以下地址**

[https://github.com/trimstray/nginx-admins-handbook#introduction](https://github.com/trimstray/nginx-admins-handbook#introduction)

> 假设配置如下

	server {

	 listen           80;
	 server_name      xyz.com www.xyz.com;
	
	 location ~ ^/(media|static)/ {
	  root            /var/www/xyz.com/static;
	  expires         10d;
	 }
	
	 location ~* ^/(media2|static2) {
	  root            /var/www/xyz.com/static2;
	  expires         20d;
	 }
	
	 location /static3 {
	  root            /var/www/xyz.com/static3;
	 }
	
	 location ^~ /static4 {
	  root            /var/www/xyz.com/static4;
	 }
	
	 location = /api {
	  proxy_pass      http://127.0.0.1:8080;
	 }
	
	 location / {
	  proxy_pass      http://127.0.0.1:8080;
	 }
	
	 location /backend {
	  proxy_pass      http://127.0.0.1:8080;
	 }
	
	 location ~ logo.xcf$ {
	  root            /var/www/logo;
	  expires         48h;
	 }
	
	 location ~* .(png|ico|gif|xcf)$ {
	  root            /var/www/img;
	  expires         24h;
	 }
	
	 location ~ logo.ico$ {
	  root            /var/www/logo;
	  expires         96h;
	 }
	
	 location ~ logo.jpg$ {
	  root            /var/www/logo;
	  expires         48h;
	 }
	
	}

> 匹配规则如下

<table>
<thead>
<tr>
<th align="center"><b>请求URL</b></th>
<th align="center"><b>相匹配的location</b></th>
<th align="center"><b>最终匹配</b></th>
</tr>
</thead>
<tbody>
<tr>
<td align="left"><code>/</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code></td>
<td align="left"><code>/</code></td>
</tr>
<tr>
<td align="left"><code>/css</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code></td>
<td align="left"><code>/</code></td>
</tr>
<tr>
<td align="left"><code>/api</code></td>
<td align="left"><sup>1)</sup> exact match for <code>/api</code></td>
<td align="left"><code>/api</code></td>
</tr>
<tr>
<td align="left"><code>/api/</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code></td>
<td align="left"><code>/</code></td>
</tr>
<tr>
<td align="left"><code>/backend</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> prefix match for <code>/backend</code></td>
<td align="left"><code>/backend</code></td>
</tr>
<tr>
<td align="left"><code>/static</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code></td>
<td align="left"><code>/</code></td>
</tr>
<tr>
<td align="left"><code>/static/header.png</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case sensitive regex match for <code>^/(media|static)/</code></td>
<td align="left"><code>^/(media|static)/</code></td>
</tr>
<tr>
<td align="left"><code>/static/logo.jpg</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case sensitive regex match for <code>^/(media|static)/</code></td>
<td align="left"><code>^/(media|static)/</code></td>
</tr>
<tr>
<td align="left"><code>/media2</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case insensitive regex match for <code>^/(media2|static2)</code></td>
<td align="left"><code>^/(media2|static2)</code></td>
</tr>
<tr>
<td align="left"><code>/media2/</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case insensitive regex match for <code>^/(media2|static2)</code></td>
<td align="left"><code>^/(media2|static2)</code></td>
</tr>
<tr>
<td align="left"><code>/static2/logo.jpg</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case insensitive regex match for <code>^/(media2|static2)</code></td>
<td align="left"><code>^/(media2|static2)</code></td>
</tr>
<tr>
<td align="left"><code>/static2/logo.png</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case insensitive regex match for <code>^/(media2|static2)</code></td>
<td align="left"><code>^/(media2|static2)</code></td>
</tr>
<tr>
<td align="left"><code>/static3/logo.jpg</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/static3</code><br><sup>2)</sup> prefix match for <code>/</code><br><sup>3)</sup> case sensitive regex match for <code>logo.jpg$</code></td>
<td align="left"><code>logo.jpg$</code></td>
</tr>
<tr>
<td align="left"><code>/static3/logo.png</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/static3</code><br><sup>2)</sup> prefix match for <code>/</code><br><sup>3)</sup> case insensitive regex match for <code>.(png|ico|gif|xcf)$</code></td>
<td align="left"><code>.(png|ico|gif|xcf)$</code></td>
</tr>
<tr>
<td align="left"><code>/static4/logo.jpg</code></td>
<td align="left"><sup>1)</sup> priority prefix match for <code>/static4</code><br><sup>2)</sup> prefix match for <code>/</code></td>
<td align="left"><code>/static4</code></td>
</tr>
<tr>
<td align="left"><code>/static4/logo.png</code></td>
<td align="left"><sup>1)</sup> priority prefix match for <code>/static4</code><br><sup>2)</sup> prefix match for <code>/</code></td>
<td align="left"><code>/static4</code></td>
</tr>
<tr>
<td align="left"><code>/static5/logo.jpg</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case sensitive regex match for <code>logo.jpg$</code></td>
<td align="left"><code>logo.jpg$</code></td>
</tr>
<tr>
<td align="left"><code>/static5/logo.png</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case insensitive regex match for <code>.(png|ico|gif|xcf)$</code></td>
<td align="left"><code>.(png|ico|gif|xcf)$</code></td>
</tr>
<tr>
<td align="left"><code>/static5/logo.xcf</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case sensitive regex match for <code>logo.xcf$</code></td>
<td align="left"><code>logo.xcf$</code></td>
</tr>
<tr>
<td align="left"><code>/static5/logo.ico</code></td>
<td align="left"><sup>1)</sup> prefix match for <code>/</code><br><sup>2)</sup> case insensitive regex match for <code>.(png|ico|gif|xcf)$</code></td>
<td align="left"><code>.(png|ico|gif|xcf)$</code></td>
</tr>
</tbody>
</table>

> 匹配顺序说明

`nginx根据uri进行最优匹配`

<ol>
<li>
<p>基于前缀的NGINX位置匹配(没有正则表达式)。每个位置都将根据请求URI进行检查</p>
</li>
<li>
<p>NGINX搜索精确的匹配。如果=修饰符与请求URI完全匹配，则立即选择此特定位置块</p>
</li>
<li>
<p>如果没有找到精确的位置块(即没有相应的=修饰符)，NGINX将继续使用非精确的前缀。它从这个URI的最长匹配前缀位置开始，方法如下:</p>
<ul>
<li>
<p>如果最长匹配前缀位置有^~修饰符，NGINX将立即停止搜索并选择该位置。</p>
</li>
<li>
<p>假设最长匹配前缀位置不使用^~修饰符，匹配将被临时存储，并继续执行。</p>
</li>
</ul>
</li>
<li>
<p>一旦选择并存储了最长匹配前缀位置，NGINX就会继续计算区分大小写和不敏感的正则表达式位置。第一个适合URI的正则表达式位置将立即被选中来处理请求</p>
</li>
<li>
<p>如果没有找到匹配请求URI的正则表达式位置，则选择先前存储的前缀位置来服务请求</p>
</li>
</ol>

### nginx重定向 ###

**实现方式**

`rewrite && return`



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

# nginx调优 #

> 1、upstream 配置 keepalive

	upstream backend-server {
	server 192.168.1.2:8080;
	keepalive 16;
	}

	server {
		listen 8080;
		location / {
			# Default is HTTP/1, keepalive is only enabled in HTTP/1.1:
		    proxy_http_version  1.1;
		    # Remove the Connection header if the client sends it,
		    # it could be "close" to close a keepalive connection:
		    proxy_set_header    Connection "";
			proxy_pass http://backend-server;
		}
	}

	#nginx upstream{}默认与上游服务以HTTP1.0进行通信，不具备keepalive能力

### 安全加固 ###

**原文地址**

[https://github.com/trimstray/nginx-admins-handbook#hardening](https://github.com/trimstray/nginx-admins-handbook#hardening)

> 非root用户运行

	nginx.conf -> user xxx;

> 不间断的更新版本

	由于新版本会解决旧版本Bug等，建议每次官方稳定版出来一周后进行nginx升级。

> 隐藏版本信息

	#以防被攻击者利用该版本nginx漏洞进行攻击
	nginx.conf中
	http {
	...
	server_tokens off;	
	...
	}

> 敏感文件禁止访问

	#如.git .svn等
	server {
	...
	location ~* ^.*(\.(?:git|svn|htaccess))$ {
  		return 403;
	}
	...
	}

> 剔除无用模块

	源码编译时剔除
	./configure --without-http_autoindex_module

> 修改nginx server标识

**原因说明**

[https://www.troyhunt.com/shhh-dont-let-your-response-headers/](https://www.troyhunt.com/shhh-dont-let-your-response-headers/)

	#nginx.conf中添加（需要编译时引入ngx_headers_more模块）
	http {
	...
	more_set_headers "Server: Unknown";
	...
	}

> 剔除不安全HEADER

[https://veggiespam.com/headers/](https://veggiespam.com/headers/)

	location / {
	proxy_hide_header X-Powered-By;
	proxy_hide_header X-AspNetMvc-Version;
	proxy_hide_header X-AspNet-Version;
	proxy_hide_header X-Drupal-Cache;
	proxy_pass http://backend-server;
	}

> 配置TLS

	https

> 使用最新版openssl

[https://www.openssl.org/policies/releasestrat.html](https://www.openssl.org/policies/releasestrat.html)

	#系统自带的一般版本不是最新的，建议自己编译安装

**关于openssl版本维护信息**

<ul>
<li>the next version of OpenSSL will be 3.0.0</li>
<li>version 1.1.1 will be supported until 2023-09-11 (LTS)
<ul>
<li>last minor version: 1.1.1c (May 23, 2019)</li>
</ul>
</li>
<li>version 1.1.0 will be supported until 2019-09-11
<ul>
<li>last minor version: 1.1.0k (May 28, 2018)</li>
</ul>
</li>
<li>version 1.0.2 will be supported until 2019-12-31 (LTS)
<ul>
<li>last minor version: 1.0.2s (May 28, 2018)</li>
</ul>
</li>
<li>any other versions are no longer supported</li>
</ul>

> https安全配置

	#一般配置tls证书时需要用到以下配置
	ssl_protocols TLSv1.3 TLSv1.2;
	ssl_prefer_server_ciphers on;

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

> 禁用不安全HTTP方法

	if ($request_method !~ ^(GET|POST|HEAD)$) {

  		return 405;

	}

> 禁止缓存敏感数据

	expires 0;
    add_header Cache-Control "no-cache, no-store";

> 防止缓冲区溢出攻击

	client_max_body_size    100m;

	client_body_buffer_size 128k;

	client_header_buffer_size 512k;

	large_client_header_buffers 4 512k