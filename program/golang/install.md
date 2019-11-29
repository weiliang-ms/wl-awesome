### golang安装配置
> unix

下载安装
    
    wget https://studygolang.com/dl/golang/go1.13.4.linux-amd64.tar.gz
    tar zxvf go1.13.4.linux-amd64.tar.gz -C /opt
    
配置

    mkdir -p /usr/local/golang/{src,bin,pkg}
    cat >> ~/.bash_profile <<EOF
    # Enable the go modules feature
    export GO111MODULE=on
    # Set the GOPROXY environment variable
    export GOPROXY=https://goproxy.cn
    export GOROOT=/opt/go
    export GOPATH=/usr/local/golang
    export PATH=\$PATH:\$GOROOT/bin
    EOF
    
    . ~/.bash_profile