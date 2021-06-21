- [安全加固](#%E5%AE%89%E5%85%A8%E5%8A%A0%E5%9B%BA)
  - [禁Ping、Traceroute配置](#%E7%A6%81pingtraceroute%E9%85%8D%E7%BD%AE)
  - [升级openssl](#%E5%8D%87%E7%BA%A7openssl)
  - [升级openssh](#%E5%8D%87%E7%BA%A7openssh)
  - [探测到SSH服务器支持的算法](#%E6%8E%A2%E6%B5%8B%E5%88%B0ssh%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%94%AF%E6%8C%81%E7%9A%84%E7%AE%97%E6%B3%95)
  - [ICMP timestamp请求响应漏洞](#icmp-timestamp%E8%AF%B7%E6%B1%82%E5%93%8D%E5%BA%94%E6%BC%8F%E6%B4%9E)
  - [隐藏Linux版本信息](#%E9%9A%90%E8%97%8Flinux%E7%89%88%E6%9C%AC%E4%BF%A1%E6%81%AF)
  - [锁定系统关键文件](#%E9%94%81%E5%AE%9A%E7%B3%BB%E7%BB%9F%E5%85%B3%E9%94%AE%E6%96%87%E4%BB%B6)
  - [中间件版本信息泄露](#%E4%B8%AD%E9%97%B4%E4%BB%B6%E7%89%88%E6%9C%AC%E4%BF%A1%E6%81%AF%E6%B3%84%E9%9C%B2)
  - [SSH 支持弱加密算法漏洞](#ssh-%E6%94%AF%E6%8C%81%E5%BC%B1%E5%8A%A0%E5%AF%86%E7%AE%97%E6%B3%95%E6%BC%8F%E6%B4%9E)

# 安全加固

## 漏洞扫描

- [nessus下载地址](https://www.tenable.com/products/nessus/select-your-operating-system)
- [nessus注册地址](https://www.tenable.com/products/nessus-home)



## 禁Ping、Traceroute配置

	echo "net.ipv4.icmp_echo_ignore_all=1"  >> /etc/sysctl.conf
	sysctl -p
    
## [升级openssl](/os/upgrade/README.md#openssl)

## [升级openssh](/os/upgrade/README.md#openssh)

## 探测到SSH服务器支持的算法 ##

描述：本插件用来获取SSH服务器支持的算法列表

处理：无法处理。ssh协议协商过程就是服务端要返回其支持的算法列表。

## ICMP timestamp请求响应漏洞 ##

描述：远程主机会回复ICMP_TIMESTAMP查询并返回它们系统的当前时间。 这可能允许攻击者攻击一些基于时间认证的协议。

处理：调整防火墙规则

	iptables -I INPUT -p ICMP --icmp-type timestamp-request -m comment --comment "deny ICMP timestamp" -j DROP
	iptables -I INPUT -p ICMP --icmp-type timestamp-reply -m comment --comment "deny ICMP timestamp" -j DROP

## 隐藏Linux版本信息

	> /etc/issue
	> /etc/issue.net 

## 锁定系统关键文件

防止被篡改

	chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/inittab


## 中间件版本信息泄露

**nginx**

	#需要安装headers-more-nginx-module-master模块
	#（默认错误页也会爆露server信息，后续添加）
	nginx.conf -> http {... server_tokens off; more_set_headers "Server: Unknown"; ...}

**ftp**

	echo "ftpd_banner=this is vsftpd" >> /etc/vsftpd/vsftpd.conf
	service vsftp restart

**tomcat**

	由于一般作为nginx的上游服务器，隐藏方式后续添加

## SSH 支持弱加密算法漏洞 ##

- [升级openssh添加新的加密算法](https://blog.csdn.net/qq_40606798/article/details/86512610)



    