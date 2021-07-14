## trafodion

### CDH集群部署

**主机列表**

- 192.168.1.11

- 192.168.1.12

- 192.168.1.13

**操作系统（必须）**

- CentOS6

### 环境初始化

> 1.设置hostname，并配置host解析

192.168.1.11主机执行：

    cat >> /etc/sysconfig/network <<EOF
    HOSTNAME=hadoop1
    EOF
    echo hadoop1 >/proc/sys/kernel/hostname
    
    cat >> /etc/hosts <<EOF
    192.168.1.11 hadoop1
    192.168.1.12 hadoop2
    192.168.1.13 hadoop3
    EOF
    
192.168.1.12主机执行：

    cat >> /etc/sysconfig/network <<EOF
    HOSTNAME=hadoop2
    EOF
    echo hadoop2 >/proc/sys/kernel/hostname
    
    cat >> /etc/hosts <<EOF
    192.168.1.11 hadoop1
    192.168.1.12 hadoop2
    192.168.1.13 hadoop3
    EOF
   
192.168.1.13主机执行：

    cat >> /etc/sysconfig/network <<EOF
    HOSTNAME=hadoop3
    EOF
    echo hadoop3 >/proc/sys/kernel/hostname
    
    cat >> /etc/hosts <<EOF
    192.168.1.11 hadoop1
    192.168.1.12 hadoop2
    192.168.1.13 hadoop3
    EOF
    
> 2.安装必要软件

    yum install -y openssh-clients yum-utils createrepo yum-plugin-priorities
    
> 3.实现主机互信（hadoop1节点执行）

hadoop1节点执行以下命令，生成ssh密钥

    ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
     
分发密钥完成互信（依次输入各节点密码）

    ssh-copy-id hadoop1
    ssh-copy-id hadoop2
    ssh-copy-id hadoop3
    
> 4.调整系统参数（三个节点均执行）

    # 调整文件句柄数
    echo "* soft nofile 655350" >> /etc/security/limits.conf
    echo "* hard nofile 655350" >> /etc/security/limits.conf
    echo "* soft nproc 65535" >> /etc/security/limits.conf
    echo "* hard nproc 65535" >> /etc/security/limits.conf
    ulimit -n 655350

    # 关闭防火墙
    service iptables stop
    chkconfig iptables off
    
    # 关闭selinux
    setenforce 0
    sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
    
> 5.安装oracle jdk1.8（所有节点）

[安装oracle jdk1.8](https://github.com/weiliang-ms/deploy/blob/master/jdk/oraclejdk.md),并配置软链接
   
    mkdir -p /usr/java
    ln -s /opt/java /usr/java/jdk1.8
        
> 6.安装mysql，初始化用户

[mysql部署文档](https://github.com/weiliang-ms/deploy/blob/master/mysql/README.md)

创建scm_server用户

    mysql -uroot -proot <<EOF
    create user 'scm_server'@'%' identified by 'scm_server';
    create database scm_server_db DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
    grant all privileges on scm_server_db.* to 'scm_server'@'%' with grant option;
    create user 'hive'@'%' identified by 'hive';
    create database hive DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
    grant all privileges on hive.* to 'hive'@'%' with grant option;
    create user 'oozie'@'%' identified by 'oozie';
    create database oozie DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
    grant all privileges on oozie.* to 'oozie'@'%' with grant option; 
    flush privileges;
    exit
    EOF
    
> 7.安装配置ntp

hadoop1节点执行：

    yum install -y ntp
    service ntpd start
    chkconfig ntpd on
    
    sed -i "s;restrict default kod nomodify notrap nopeer noquery;#restrict default kod nomodify notrap nopeer noquery;g" /etc/ntp.conf
    sed -i "s;restrict -6 default kod nomodify notrap nopeer noquery;#restrict -6 default kod nomodify notrap nopeer noquery;g" /etc/ntp.conf
    sed -i "s#restrict -6 ::1#restrict ::1#g" /etc/ntp.conf
    sed -i "s;server 0.centos.pool.ntp.org iburst;#server 0.centos.pool.ntp.org iburst;g" /etc/ntp.conf
    sed -i "s;server 1.centos.pool.ntp.org iburst;#server 1.centos.pool.ntp.org iburst;g" /etc/ntp.conf
    sed -i "s;server 2.centos.pool.ntp.org iburst;#server 2.centos.pool.ntp.org iburst;g" /etc/ntp.conf
    sed -i "s;server 3.centos.pool.ntp.org iburst;#server 3.centos.pool.ntp.org iburst;g" /etc/ntp.conf
    echo "server 127.127.1.0" >> /etc/ntp.conf
    echo "fudge 127.127.1.0 stratum 10" >> /etc/ntp.conf
    echo "disable monitor" >> /etc/ntp.conf
    echo "restrict default nomodify" >> /etc/ntp.conf
    
hadoop2、hadoop3节点执行：

    yum install -y ntp
    
    sed -i "s;restrict default kod nomodify notrap nopeer noquery;#restrict default kod nomodify notrap nopeer noquery;g" /etc/ntp.conf
    sed -i "s;restrict -6 default kod nomodify notrap nopeer noquery;#restrict -6 default kod nomodify notrap nopeer noquery;g" /etc/ntp.conf
    sed -i "s#restrict -6 ::1#restrict ::1#g" /etc/ntp.conf
    sed -i "s;server 0.centos.pool.ntp.org iburst;#server 0.centos.pool.ntp.org iburst;g" /etc/ntp.conf
    sed -i "s;server 1.centos.pool.ntp.org iburst;#server 1.centos.pool.ntp.org iburst;g" /etc/ntp.conf
    sed -i "s;server 2.centos.pool.ntp.org iburst;#server 2.centos.pool.ntp.org iburst;g" /etc/ntp.conf
    sed -i "s;server 3.centos.pool.ntp.org iburst;#server 3.centos.pool.ntp.org iburst;g" /etc/ntp.conf
    echo "server hadoop1" >> /etc/ntp.conf
    echo "disable monitor" >> /etc/ntp.conf
    echo "restrict default nomodify" >> /etc/ntp.conf
    ntpdate hadoop1
    
> 8.下载mysql驱动（hadoop1节点）

下载[mysql-connector-java-5.1.48.tar.gz](https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-5.1.48.tar.gz)上传至hadoop1:/tmp下

执行以下命令，调整名称

    mkdir -p /usr/share/java
    tar zxvf mysql-connector-java-5.1.48.tar.gz
    cp mysql-connector-java-5.1.48/mysql-connector-java-5.1.48.jar /usr/share/java/mysql-connector-java.jar

### 安装CDH5.4

> 1.创建离线镜像源目录（所有节点）

    mkdir -p /cm
    
下载[cloudera-manager](http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5.4.0/RPMS/x86_64/)下的所有文件，并上传至/cm下

> 2.配置cm源（所有节点）

创建repo源文件

    cd /cm && createrepo ./
    cat > /etc/yum.repos.d/cm.repo <<EOF
    [cloudera-manager]
    name=cm
    baseurl=file:///cm
    gpgkey=file:///cm/RPM-GPG-KEY-cloudera
    enable = 1
    gpgcheck = 1
    EOF

`/cm`目录最终结构如下：

    /cm
    ├── cloudera-manager-agent-5.4.0-1.cm540.p0.165.el6.x86_64.rpm
    ├── cloudera-manager-daemons-5.4.0-1.cm540.p0.165.el6.x86_64.rpm
    ├── cloudera-manager-server-5.4.0-1.cm540.p0.165.el6.x86_64.rpm
    ├── cloudera-manager-server-db-2-5.4.0-1.cm540.p0.165.el6.x86_64.rpm
    ├── enterprise-debuginfo-5.4.0-1.cm540.p0.165.el6.x86_64.rpm
    ├── jdk-6u31-linux-amd64.rpm
    ├── oracle-j2sdk1.7-1.7.0+update67-1.x86_64.rpm
    ├── repodata
    │   ├── 3a8b6a8a03c3846eadd0f0d8df2ef1142e6e32d21ce7e4e58a304ad3bef8b5b7-primary.sqlite.bz2
    │   ├── 853ca50d5d1f076b5f53cd06ed4d74c62ee729af1a86e3caa1bd39aaf6e68cf7-other.sqlite.bz2
    │   ├── a6b67b1228bbb6791eb66fd52cfc2044a681a9444e1a1aa044111029b6f4760c-filelists.xml.gz
    │   ├── b05946fbbf3fec9e107640249a183e7109d0e336ef23fcbe199b3dd1743f84f3-other.xml.gz
    │   ├── c2c48ea8c58913116c14e8ec853d2fd2731bee779edafc81dec0d60771709f17-filelists.sqlite.bz2
    │   ├── fd1f07dacbe9d5e3be1e7f7930fbb6eac4d29a75c172c2a31e6e18baa56b5fee-primary.xml.gz
    │   └── repomd.xml
    └── RPM-GPG-KEY-cloudera
    
> 3.安装cloudera-manager-server(hadoop1节点)

    yum install cloudera-manager-daemons cloudera-manager-server -y
    
> 4.安装cloudera-manager-agent(hadoop1、hadoop2、hadoop3节点)

    yum install cloudera-manager-agent -y
    
> 5.修改cloudera-manager-agent配置文件(hadoop1、hadoop2、hadoop3节点)

hadoop1、hadoop2、hadoop3节点执行：

    sed -i "s#server_host=localhost#server_host=hadoop1#g" /etc/cloudera-scm-agent/config.ini
    echo "listening_ip=`hostname`" >> /etc/cloudera-scm-agent/config.ini
    echo "listening_hostname=`hostname`" >> /etc/cloudera-scm-agent/config.ini

> 6.创建CDH离线源仓储

创建目录(hadoop1节点)
    
        mkdir -p /opt/cloudera/parcel-repo
       
上传以下文件至hadoop1节点`/opt/cloudera/parcel-repo`下

- [manifest.json](http://archive.cloudera.com/cdh5/parcels/5.4.0/manifest.json)
- [CDH-5.4.0-1.cdh5.4.0.p0.27-el6.parcel](http://archive.cloudera.com/cdh5/parcels/5.4.0/CDH-5.4.0-1.cdh5.4.0.p0.27-el6.parcel)
- [CDH-5.4.0-1.cdh5.4.0.p0.27-el6.parcel.sha1](http://archive.cloudera.com/cdh5/parcels/5.4.0/CDH-5.4.0-1.cdh5.4.0.p0.27-el6.parcel.sha1)

调整CDH-5.4.0-1.cdh5.4.0.p0.27-el6.parcel.sha1名称

    cd /opt/cloudera/parcel-repo
    mv CDH-5.4.0-1.cdh5.4.0.p0.27-el6.parcel.sha1 CDH-5.4.0-1.cdh5.4.0.p0.27-el6.parcel.sha
    
> 7.初始化CM Server数据库(hadoop1节点)

    /usr/share/cmf/schema/scm_prepare_database.sh mysql scm_server_db scm_server scm_server -h 127.0.0.1
    
> 8.启动cloudera-manager-agent（hadoop1、hadoop2、hadoop3节点）

    service cloudera-scm-agent start
    chkconfig cloudera-scm-agent on

> 9.启动cloudera-manager-server(hadoop1节点)

    service cloudera-scm-server start
    chkconfig cloudera-scm-server on
    
查看日志

    tail -200f /var/log/cloudera-scm-server/cloudera-scm-server.log
    
> 10.访问控制台初始化

主要hadoop1替换为实际IP地址

访问http://hadoop1:7180，账号密码: admin/admin

![](./images/cdh_login.jpg)

部署免费版本

![](./images/cdh_free_version.jpg) 

确认部署应用，点击**继续**

![](./images/cdh_entry_cdh_version.jpg) 

添加部署节点，点击继续

![](./images/cdh_input_hosts.jpg)

确认cdh版本，继续

![](./images/cdh_entry_install_version.jpg)

确认安装完成，点击继续

![](./images/cdh_installed.jpg)

确认检测结果，点击完成

![](./images/cdh_entry_check_result.jpg)

选取hbase内核hadoop安装

![](./images/cdh_choose_hbase_kernel.jpg)

默认角色分配，继续

![](./images/cdh_entry_hadoop_role.jpg)

输入用户名密码数据库实例名，测试连接后点击继续

hive/hive hive
oozie/oozie oozie

![](./images/cdh_test_db_connect.png)
    
确认审核设置，点击继续

![](./images/cdh_cluster_settings.jpg)

安装完成

![](./images/cdh_been_installed.jpg)

### 安装trafodion

**主机列表**

- 192.168.1.11

- 192.168.1.12

- 192.168.1.13

> 1.下载安装介质及脚本

互联网下载地址:

- [installer](https://archive.apache.org/dist/trafodion/apache-trafodion-2.1.0-incubating/bin/apache-trafodion_installer-2.1.0-incubating.tar.gz)
- [trafodion_server](https://archive.apache.org/dist/trafodion/apache-trafodion-2.1.0-incubating/bin/apache-trafodion_server-2.1.0-RH6-x86_64-incubating.tar.gz)

> 2.创建/trafodion目录，上传安装介质及脚本至该目录下

目录结构如下：

    /trafodion/
    ├── apache-trafodion_installer-2.1.0-incubating.tar.gz
    └── apache-trafodion_server-2.1.0-RH6-x86_64-incubating.tar.gz

> 3.解压运行安装脚本

    cd /trafodion
    tar zxvf apache-trafodion_pyinstaller-2.1.0-incubating.tar.gz
    cd python-installer
    ./db_install.py
    
> 4.按提示输入相关信息

    Enter HDP/CDH web manager URL:port, (full URL, if no http/https prefix, default prefix is http://):
    -- 输入 http://192.168.1.11:7180
    
    Enter HDP/CDH web manager user name [admin]:
    -- 回车默认
    
    Enter HDP/CDH web manager user password:
    -- 输入 admin
    
    Confirm Enter HDP/CDH web manager user password:
    -- 输入 admin
    
    Enter full path to Trafodion tar file:
     -- 输入 /trafodion/apache-trafodion_server-2.1.0-RH6-x86_64-incubating.tar.gz
    
    Enter directory name to install trafodion to [apache-trafodion-2.1.0]:
    -- 回车默认
    
    Enter trafodion user password:
    -- 输入 trafodion
    
    Enter number of DCS client connections per node [4]:
    -- 回车默认
    
    Enter trafodion scratch file folder location(should be a large disk),
    if more than one folder, use comma seperated [$TRAF_HOME/tmp]:
    -- 回车默认
    
    Start instance after installation (Y/N)  [Y]:
    -- 回车默认
    
    Enable LDAP security (Y/N)  [N]:
    -- 回车默认
    
    Enable DCS High Avalability (Y/N)  [N]:
    -- 回车默认
    
    Enter Hadoop admin password, default is [admin]:
    -- 回车默认
    
    Confirm result (Y/N) [N]:
    -- 输入 Y
    
安装过程

![](imags/trafodion_installing.png)

安装完毕

![](images/trafodion_installed.png)

> 5.查看trafodion状态

登录hadoop2，切换到trafodion用户执行以下语句：

    sqcheck

返回如下，说明成功

    *** Checking Trafodion Environment ***
    
    Checking if processes are up.
    Checking attempt: 1; user specified max: 2. Execution time in seconds: 0.
    
    The Trafodion environment is up!
    
    
    Process         Configured      Actual      Down
    -------         ----------      ------      ----
    DTM             2               2
    RMS             4               4
    DcsMaster       1               1
    DcsServer       2               2
    mxosrvr         8               8
    RestServer      1               1