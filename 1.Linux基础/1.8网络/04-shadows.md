### 服务端

```shell
yum -y install wget
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr.sh \
&& chmod +x ssr.sh && bash ssr.sh
```

### shadowsocks客户端

[项目地址](https://www.cnblogs.com/milton/p/6366916.html)

> 1.下载安装包

[windows](https://github.com/shadowsocks/shadowsocks-windows/releases/download/4.1.7.1/Shadowsocks-4.1.7.1.zip)

> 2.解压，运行

加压到本地目录

![](images/unzip.png)

> 3.配置

配置服务端IP、端口、加密算法、服务端口

![](images/config.png)

> 4、配置系统模式

在任务栏找到 Shadowsocks 图标，选取PAC模式

[其他使用说明](https://github.com/shadowsocks/shadowsocks-windows/wiki/Shadowsocks-Windows-%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

> 5、测试是否可用

[twitter](https://twitter.com/)
