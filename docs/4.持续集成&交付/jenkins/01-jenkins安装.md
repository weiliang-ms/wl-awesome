### jenkins安装

**方便起见我们假设`jenkins`宿主机IP为** `192.168.1.2`

> 1.环境依赖

- 系统要求 
    - 最低推荐配置:
	
	256MB可用内存,1GB可用磁盘空间(作为一个Docker容器运行jenkins的话推荐10GB)
	
	- 为小团队推荐的硬件配置:
	`1GB+`可用内存,`50GB+`可用磁盘空间
	
	- 软件配置:
	`Java8`—无论是`Java`运行时环境（JRE）还是`Java`开发工具包（`JDK`）都可以。

> 2.安装jdk1.8

```shell
yum install -y java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64
```

> 3.安装jenkins

```shell
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y
```

> 4.调整默认配置

```shell
sed -i "s#JENKINS_PORT=\"8080\"#JENKINS_PORT=\"8081\"#g" /etc/sysconfig/jenkins
sed -i "s#JENKINS_ARGS=\"\"#s#JENKINS_ARGS=\"--prefix=/jenkins\"#g" /etc/sysconfig/jenkins
```

> 5.启动并开机自启动

```shell
systemctl enable jenkins --now
```

> 6.初始化`jenkins`账号

- 浏览器访问`http://192.168.1.2:8081/jenkins`

- 根据提示获取管理员初始密码

```shell
cat /var/lib/jenkins/secrets/initialAdminPassword
```

- 根据提示安装默认插件（默认即可，后续更改插件源地址，按需下载）

![](images/jenkins-init.jpg)

- 根据提示创建新用户