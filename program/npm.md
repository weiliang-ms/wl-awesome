<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [npm环境安装](#npm%E7%8E%AF%E5%A2%83%E5%AE%89%E8%A3%85)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### npm环境安装

下载

    curl -O https://nodejs.org/dist/v12.14.0/node-v12.14.0-linux-x64.tar.xz

解压
    
    sudo tar xvf node-v12.14.0-linux-x64.tar.xz -C /usr/local/
   
加入PATH
    
    echo "export PATH=\$PATH:/usr/local/node-v12.14.0-linux-x64/bin/" >> ~/.bashrc
    . ~/.bashrc
    
修改镜像源

    npm config set registry https://registry.npm.taobao.org
