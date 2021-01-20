<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [golang安装配置](#golang%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### golang安装配置
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