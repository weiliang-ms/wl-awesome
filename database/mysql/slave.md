<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [添加slave节点](#%E6%B7%BB%E5%8A%A0slave%E8%8A%82%E7%82%B9)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 添加slave节点

https://www.cnblogs.com/ygqygq2/p/6045279.html

1、确认主节点版本

2、从节点安装形同版本mysql

3、更换默认存储目录（可选）

```bash
systemctl stop mysqld.service
mkdir -p /data/mysql
chown -R mysql.mysql /data/mysql
cp -a /var/lib/mysql/* /data/mysql/
sed -i "s#/var/lib/mysql#/data/mysql#g" /etc/my.cnf
cat >> /etc/my.cnf << EOF
[client]
port=3306
socket=/data/mysql/mysql.sock
EOF
systemctl start mysqld.service
```

4、初始化密码

```bash
password=`grep 'temporary password' /var/log/mysqld.log|awk '{print $NF}'|awk 'END {print}'`
    mysql -uroot -p$password --connect-expired-password <<EOF
    set global validate_password_policy=0;
    set global validate_password_length=1;
    set password=passworD("root");
    FLUSH PRIVILEGES;
    quit
EOF
```

5、调整主库参数

原有主库配置参数如下：

```bash
server-id = 1             #id要唯一
log-bin = mysql-bin         #开启binlog日志
auto-increment-increment = 1   #在Ubuntu系统中MySQL5.5以后已经默认是1
auto-increment-offset = 1 
slave-skip-errors = all      #跳过主从复制出现的错误
```

主库创建同步账号

```bash
grant all on *.* to 'sync'@'192.168.%.%' identified by 'sync';
```

6、从库配置MySQL

```bash
server-id = 3             #这个设置3
log-bin = mysql-bin        #开启binlog日志
auto-increment-increment = 1   #这两个参数在Ubuntu系统中MySQL5.5以后都已经默认是1
auto-increment-offset = 1 
slave-skip-errors = all      #跳过主从复制出现的错误
```


update mysql.user set authentication_string=password('1qaz#EDC') where user='root';


mysqldump -h 192.168.174.30 -p3306 -uroot -p1qaz#EDC --all-databases > /root/all_db.sql