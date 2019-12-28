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
    