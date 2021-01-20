<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [安docker-compose](#%E5%AE%89docker-compose)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 安docker-compose ##

> 下载

	sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose


> 授权

	chmod +x /usr/local/bin/docker-compose

> 查看docker-compose

	#查看版本信息
	docker-compose --version

![](./images/docker-compose_version.jpg)


> 多副本集样例

创建5个实例、每个实例限制最多使用50M内存、CPU单核10%的时间

	version: "3"
	services:
	  web:
	    # replace username/repo:tag with your name and image details
	    image: username/repo:tag
	    deploy:
	      replicas: 5
	      resources:
	        limits:
	          cpus: "0.1"
	          memory: 50M
	      restart_policy:
	        condition: on-failure
	    ports:
	      - "4000:80"
	    networks:
	      - webnet
	networks:
	  webnet: