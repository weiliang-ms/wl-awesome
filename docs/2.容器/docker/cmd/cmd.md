<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [清理容器](#%E6%B8%85%E7%90%86%E5%AE%B9%E5%99%A8)
- [清理镜像](#%E6%B8%85%E7%90%86%E9%95%9C%E5%83%8F)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 普通用户访问`docker`


```shell
sudo groupadd docker     #添加docker用户组
usermod -aG docker $USER
newgrp docker     #更新用户组
docker ps
```

### 清理容器

- 方式一：

显示所有的容器，过滤出Exited状态的容器，取出这些容器的ID，

    sudo docker ps -a|grep Exited|awk '{print $1}'

查询所有的容器，过滤出Exited状态的容器，列出容器ID，删除这些容器

    sudo docker rm `docker ps -a|grep Exited|awk '{print $1}'`

- 方式二： 

删除所有未运行的容器（已经运行的删除不了，未运行的就一起被删除了）

    sudo docker rm $(sudo docker ps -a -q)

- 方式三：

根据容器的状态，删除Exited状态的容器
    
    sudo docker rm $(sudo docker ps -qf status=exited)
    
### 清理docker垃圾

    docker image prune -a -f

    