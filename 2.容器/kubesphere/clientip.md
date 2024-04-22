## 
获取 client ip

## 环境说明

all in one

kubesphere 版本：v3.4.1

kubernetes 版本: v1.23.17

client_ip: 192.168.1.2

cni: cilium

cilium_host ip 10.233.64.175

server ip 10.8.0.2
gateway ip 10.8.0.2


## 程序代码片段

非常简单的一个 RESTFUL 接口，返回调用者 Request 头相关值信息

```golang
package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/ppp", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"remote_addr":     c.RemoteIP(),
			"client_ip":       c.ClientIP(),
			"X-Forwarded-For": c.GetHeader("X-Forwarded-For"),
		})
	})
	r.Run() // listen and serve on 0.0.0.0:8080
}

```

### 调用链路

browser -> ks gateway -> svc -> pod

## 默认方式访问: 获取的客户端地址为node节点ip





