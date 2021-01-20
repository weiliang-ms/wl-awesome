<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [docker multi-stage](#docker-multi-stage)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## docker multi-stage

创建目录

	mkdir -p /docker/multi-stage
	
创建golang程序

	cat > /docker/multi-stage/rancher.go <<EOF
	package main

	import (
	        "time"
	)
	
	func main()  {
	        for {
	                println(time.Now().Format("2006-01-02 15:04:05.999999999 -0700 MST"))
	                time.Sleep(time.Second)
	        }
	}

	EOF

创建dockerfile

[参考官方样例](https://docs.docker.com/develop/develop-images/multistage-build/)

	cat > /docker/multi-stage/Dockerfile <<EOF
	FROM golang
	WORKDIR /go/src/github.com/alexellis/href-counter/
	ADD rancher.go .
	RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o rancher .
	
	FROM alpine
	RUN apk --no-cache add ca-certificates
	WORKDIR /root/
	COPY --from=0 /go/src/github.com/alexellis/href-counter/rancher .
	ENTRYPOINT ["./rancher"]

	EOF

构建镜像

	docker build -t rancher-demo .

构建信息

![](images/docker-01-build.png)

镜像大小
	
![](images/docker-01-image-size.png)

运行容器

	docker run --rm --name rancher -idt rancher-demo

查看日志

	docker logs -f rancher

![](images/docker01-logging.png)

11/16/2019 1:19:36 PM 