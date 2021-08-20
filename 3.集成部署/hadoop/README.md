## hadoop

### 准备离线资源

[mysql-connector-java-5.1.48.tar.gz](https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-5.1.48.tar.gz)

### linux节点配置

假设节点IP为：

- 主：192.168.1.12

- 从：192.168.1.13

- 从：192.168.1.14

> 设置hostname

节点一执行

    cat >> /etc/sysconfig/network <<EOF
    HOSTNAME=hadoop1
    EOF
    echo hadoop1 >/proc/sys/kernel/hostname
    
节点二执行
    
    cat >> /etc/sysconfig/network <<EOF
    HOSTNAME=hadoop2
    EOF
    echo hadoop2 >/proc/sys/kernel/hostname
    
节点三执行

    cat >> /etc/sysconfig/network <<EOF
    HOSTNAME=hadoop3
    EOF
    echo hadoop3 >/proc/sys/kernel/hostname
    
配置host解析（三个节点均执行，注意IP替换为实际IP）

    cat >> /etc/hosts <<EOF
    192.168.1.12 hadoop1
    192.168.1.13 hadoop2
    192.168.1.14 hadoop3
    EOF

> 关闭防火墙、selinux

    systemctl stop firewalld --now
    setenforce 0
    sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config

> 节点主机互信

master节点执行

    ssh-keygen -t rsa -n '' -f ~/.ssh/id_rsa
    # 根据提示输入对应节点root口令
    ssh-copy-id hadoop1
    ssh-copy-id hadoop2
    ssh-copy-id hadoop3
    
安装oracle jdk（1.8）并配置软链接(oracle jdk安装至/opt/java下)

    mkdir -p /usr/java
    ln -s /opt/java /usr/java/jdk1.8
    
 调整文件句柄数
 
    echo "* soft nofile 655350" >> /etc/security/limits.conf
    echo "* hard nofile 655350" >> /etc/security/limits.conf
    echo "* soft nproc 65535" >> /etc/security/limits.conf
    echo "* hard nproc 65535" >> /etc/security/limits.conf
    ulimit -n 655350


### 主节点安装Mysql

yum安装Marbidb

    yum install mariadb mariadb-server -y
    
启动

    systemctl enable mariadb --now
    
初始化用户、数据库

    mysql -u root <<EOF
    SET PASSWORD FOR 'root'@'localhost'=PASSWORD('root');
    CREATE DATABASE scm_db;
    CREATE USER 'scm_server'@'127.0.0.1' IDENTIFIED BY 'scm_server'; 
    GRANT ALL PRIVILEGES ON scm_db.* TO 'scm_server'@'127.0.0.1';
    FLUSH PRIVILEGES; 
    EOF
    
上传[mysql-connector-java-5.1.48.tar.gz](https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-5.1.48.tar.gz)
至`/tmp`目录下，执行以下命令

    mkdir -p /usr/share/java
    tar zxvf mysql-connector-java-5.1.48.tar.gz
    cp mysql-connector-java-5.1.48/mysql-connector-java-5.1.48.jar /usr/share/java/mysql-connector-java.jar
    
初始化CM Server数据库

    /usr/share/cmf/schema/scm_prepare_database.sh mysql scm_db scm_server scm_server -h 127.0.0.1
    
### 创建cloudera-manager本地镜像源（主节点）

安装repo工具

    yum install yum-utils createrepo yum-plugin-priorities -y
    
创建/cm目录，上传安装介质,结构如下

    /cm
    ├── cloudera-manager-agent-5.7.0-1.cm570.p0.76.el7.x86_64.rpm
    ├── cloudera-manager-daemons-5.7.0-1.cm570.p0.76.el7.x86_64.rpm
    ├── cloudera-manager-server-5.7.0-1.cm570.p0.76.el7.x86_64.rpm
    ├── cloudera-manager-server-db-2-5.7.0-1.cm570.p0.76.el7.x86_64.rpm
    ├── enterprise-debuginfo-5.7.0-1.cm570.p0.76.el7.x86_64.rpm
    ├── jdk-6u31-linux-amd64.rpm
    ├── oracle-j2sdk1.7-1.7.0+update67-1.x86_64.rpm
    └── RPM-GPG-KEY-cloudera
    
创建repo源文件

    cd /cm && createrepo ./
    
配置本地cloudera-manager源

    cat > /etc/yum.repos.d/cm.repo <<EOF
    [cloudera-manager]
    name=cm
    baseurl=file:///cm
    gpgkey=file:///cm/RPM-GPG-KEY-cloudera
    enable = 1
    gpgcheck = 1
    EOF
    
### 主节点上传CDH文件

创建目录(server节点、agent节点均需执行)

    mkdir -p /opt/cloudera/parcel-repo
   
上传以下文件至主节点`/opt/cloudera/parcel-repo`下

- [CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel]()
- [CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel.sha1]()
- [manifest.json]()

生成CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel.torrent.sha

    cd /opt/cloudera/parcel-repo
    sha1sum CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel.torrent | awk '{print $1}'> CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel.torrent.sha
    
修改`CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel.sha1`名

    cd /opt/cloudera/parcel-repo
    mv CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel.sha1 CDH-5.7.2-1.cdh5.7.2.p0.18-el7.parcel.sha
   
分发至agent节点

    scp /opt/cloudera/parcel-repo/* hadoop2:/opt/cloudera/parcel-repo/
    scp /opt/cloudera/parcel-repo/* hadoop3:/opt/cloudera/parcel-repo/

###安装Cloudera Manager Server端

yum安装cloudera-manager

    yum install cloudera-manager-daemons cloudera-manager-server -y
    
    
### 安装Cloudera Manager Agent端（所有agent节点）

> 拷贝资源文件

主节点拷贝以下内容至agent节点

    scp -r /cm hadoop2:/
    scp -r /cm hadoop3:/
    
    scp /etc/yum.repos.d/cm.repo hadoop2:/etc/yum.repos.d/
    scp /etc/yum.repos.d/cm.repo hadoop3:/etc/yum.repos.d/
    
> 安装agent（agent节点运行）

    yum install cloudera-manager-agent -y
    
> 修改agent配置文件

修改文件`/etc/cloudera-scm-agent/config.ini`以下内容

    server_host=localhost
    # listening_ip
    # listening_hostname=
 
> 启动agent

    systemctl start cloudera-scm-agent
    

### 启动CM Server端

> 启动

    systemctl start cloudera-scm-server
    
> 访问WEB UI （主节点7180端口）

**登录账号：admin/admin**

![](./images/cdh_login.jpg)    

接受协议

![](./images/cdh_accept.jpg) 

部署免费版本

![](./images/cdh_free_version.jpg) 

确认部署应用，点击**继续**

![](./images/cdh_entry_deploy_soft.jpg) 

添加部署节点，点击搜索

![](./images/cdh_input_hosts.jpg)

选取节点，继续

![](./images/cdh_choose_hosts.jpg)

确认cdh版本，继续

![](./images/cdh_entry_cdh_version.png)