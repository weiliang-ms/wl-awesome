## golang配置 ##

### 配置代理-windows ###

[goproxy](https://goproxy.io/)

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
	$env:GOPROXY="https://goproxy.io"


> 过滤不经过代理的仓储

如果你使用的 Go 版本>=1.13, 你可以通过设置 GOPRIVATE 环境变量来控制哪些私有仓库和依赖(公司内部仓库)不通过 proxy 来拉取，直接走本地，设置如下

	go env -w GOPROXY=https://goproxy.io,direct
	# 设置不走 proxy 的私有仓库，多个用逗号相隔
	go env -w GOPRIVATE=*.corp.example.com

> 其他代理地址

	https://athens.azurefd.net/

	#国内的比较快
	#$env:GOPROXY="https://goproxy.cn"
	https://goproxy.cn

[项目地址](https://github.com/goproxy/goproxy.cn)

