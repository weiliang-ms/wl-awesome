# golang
## golang安装配置
> unix

下载安装
    
    wget https://studygolang.com/dl/golang/go1.13.4.linux-amd64.tar.gz
    sudo tar zxvf go1.13.4.linux-amd64.tar.gz -C /usr/local
    
配置

    sudo mkdir -p $HOME/{src,bin,pkg}
    cat >> ~/.bash_profile <<EOF
    # Enable the go modules feature
    export GO111MODULE=on
    # Set the GOPROXY environment variable
    export GOPROXY=https://goproxy.cn
    export GOROOT=/usr/local/go
    export GOPATH=$HOME
    export PATH=\$PATH:\$GOROOT/bin
    EOF
    
    . ~/.bash_profile
## golang配置 

### 配置代理-windows

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
## go包管理器

[mod](https://github.com/golang/go/wiki/Modules)

## 日志管理

[logrus项目地址](https://github.com/sirupsen/logrus)

> 添加

	go get github.com/sirupsen/logrus

> 默认输出格式

样例如下入参为 `/opt/nginx/sbin/nginx`

	package process

	import (
		"bytes"
		log "github.com/sirupsen/logrus"
		"os/exec"
	)
	
	var(
		exitCode = 0
		out bytes.Buffer
	)
	
	func Shell(shell string) (stdout string,exitCode int){
	
		cmd := exec.Command("/bin/bash", "-c", shell + " 2>&1")
		log.Info("执行命令为" + shell)
	
		cmd.Stdout = &out
		if err := cmd.Start();err != nil {
			println(err.Error())
		}
		if err := cmd.Wait();err != nil {
			exitCode = 1
		}
		return out.String(),exitCode
	}

输出如下

![](images/logrus_default_format.png)

> 引入格式包

	go get github.com/antonfisher/nested-logrus-formatter

> 格式化日志输出

	package utils

	import (
		nested "github.com/antonfisher/nested-logrus-formatter"
		"github.com/sirupsen/logrus"
		"time"
	)
	
	
	type Formatter struct {
		FieldsOrder     []string // by default fields are sorted alphabetically
		TimestampFormat string   // by default time.StampMilli = "Jan _2 15:04:05.000" is used
		HideKeys        bool     // to show only [fieldValue] instead of [fieldKey:fieldValue]
		NoColors        bool     // to disable all colors
		NoFieldsColors  bool     // to disable colors only on fields and keep levels colored
		ShowFullLevel   bool     // to show full level (e.g. [WARNING] instead of [WARN])
		TrimMessages    bool     // to trim whitespace on messages
	}
	
	func Logger(format string, args ...interface{})  {
		logrus.SetFormatter(&logrus.TextFormatter{ForceColors: true})
		logrus.SetLevel(logrus.InfoLevel)
		logrus.SetFormatter(&nested.Formatter{
			HideKeys:    true,
			NoColors:    false,
			TrimMessages:false,
			TimestampFormat: time.RFC3339,
			FieldsOrder: []string{"component", "category"},
		})
	}

输出信息如下

![](images/logrus_custom_format.png)
	
### go框架类库等

[awesome](https://github.com/avelino/awesome-go)

