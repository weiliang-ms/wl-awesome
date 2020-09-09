> 1.[安装docker](https://github.com/weiliang-ms/wl-awesome/blob/master/container/docker/docker-install.md)

> 2.拉群镜像

    docker pull registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g

> 3.
    
docker run -itd -p 11521:1521 --restart=always --name oracle11g registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g