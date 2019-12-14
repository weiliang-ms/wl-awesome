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
    
### 清理镜像

    echo "y" | docker image prune -a