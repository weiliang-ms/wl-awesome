<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [golang配置](#golang%E9%85%8D%E7%BD%AE)
  - [配置代理-windows](#%E9%85%8D%E7%BD%AE%E4%BB%A3%E7%90%86-windows)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## golang配置 ##

### 配置代理-windows ###

[项目地址](https://github.com/goproxy/goproxy.cn)s

> 介绍

	解决依赖被墙

> 类unix配置goproxy

	cat >> ~/.bash_profile <<EOF
	# Enable the go modules feature
	export GO111MODULE=on
	# Set the GOPROXY environment variable
	export GOPROXY=https://goproxy.cn
	EOF

	. ~/.bash_profile

> windwos配置goproxy

打开powershell执行

	# Enable the go modules feature
	$env:GO111MODULE="on"
	# Set the GOPROXY environment variable
	$env:GOPROXY="https://goproxy.cn"


> 过滤不经过代理的仓储

如果你使用的 Go 版本>=1.13, 你可以通过设置 GOPRIVATE 环境变量来控制哪些私有仓库和依赖(公司内部仓库)不通过 proxy 来拉取，直接走本地，设置如下

	go env -w GOPROXY=https://goproxy.io,direct
	# 设置不走 proxy 的私有仓库，多个用逗号相隔
	go env -w GOPRIVATE=*.corp.example.com

