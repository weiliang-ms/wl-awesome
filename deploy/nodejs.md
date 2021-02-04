## nodejs环境安装

下载

    curl -O https://nodejs.org/dist/v12.14.0/node-v12.14.0-linux-x64.tar.xz

解压
    
    sudo tar xvf node-v12.14.0-linux-x64.tar.xz -C /usr/local/
   
加入PATH
    
    echo "export PATH=\$PATH:/usr/local/node-v12.14.0-linux-x64/bin/" >> ~/.bashrc
    . ~/.bashrc
    
修改镜像源

    npm config set registry https://registry.npm.taobao.org