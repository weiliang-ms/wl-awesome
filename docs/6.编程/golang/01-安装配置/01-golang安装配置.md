### linux

> 下载安装

```shell
wget https://studygolang.com/dl/golang/go1.13.4.linux-amd64.tar.gz
sudo tar zxvf go1.13.4.linux-amd64.tar.gz -C /usr/local 
```

> 配置

```shell
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
```