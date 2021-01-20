<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [安装harbor-ha](#%E5%AE%89%E8%A3%85harbor-ha)
- [同步](#%E5%90%8C%E6%AD%A5)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### 安装harbor-ha

初始化目录

    mkdir -p /data/harbor/cert/
    
    
[ssl证书生成](https://github.com/goharbor/harbor/blob/master/docs/configure_https.md)

下载文件

    curl -O -L https://github.com/goharbor/harbor/releases/download/v1.10.0/harbor-offline-installer-v1.10.0.tgz
    
解压

    tar zxvf harbor-offline-installer-v1.10.0.tgz
    
调整harbor/harbor.yml

    hostname: reg.mydomain.com
    certificate:
    private_key: 
    data_volume: /data
    
导入

    docker load -i harbor/harbor.v1.10.0.tar.gz
    
生成配置

    ./harbor/prepare
    
安装 
    
    ./install.sh
    
### 同步

配置容器内部解析

`harbor/docker-compose.yml`

增加

    ...
    core:
      ...
      volumes:
        - /etc/hosts:/etc/hosts
        ...
      ...
    ...
    
    ...
    jobservice:
      ...
      volumes:
        - /etc/hosts:/etc/hosts
        ...
      ...
    ...
    