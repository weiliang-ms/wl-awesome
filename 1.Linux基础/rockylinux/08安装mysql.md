## 安装mysql

**基于二进制方式**

1. 准备安装包：

https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.38-linux-glibc2.12-x86_64.tar.gz

2. 解压

```shell
tar zxvf mysql-5.7.38-linux-glibc2.12-x86_64.tar.gz -C /usr/local
```

3. 创建用户授权

```shell
useradd mysql
mv /usr/local/mysql-5.7.38-linux-glibc2.12-x86_64 /usr/local/mysql
chown mysql:mysql -R /usr/local/mysql
echo "export PATH=\$PATH:/usr/local/mysql/bin" >> ~/.bash_profile
source ~/.bash_profile
```

4. 创建配置文件

```shell
$ tee /etc/my.cnf <<EOF
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#skip_grant_tables=1
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
port=3306
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
server-id = 3             #这个设置3
auto-increment-increment = 1   #这两个参数在Ubuntu系统中MySQL5.5以后都已经默认是1
auto-increment-offset = 1
slave-skip-errors = all      #跳过主从复制出现的错误
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
interactive_timeout = 28800
wait_timeout  = 28800
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
default-storage-engine=INNODB
character-set-server=utf8
collation-server=utf8_general_ci
lower_case_table_names=1
slow_query_log = 1
slow_query_log_file=/var/log/slow-query.log
long_query_time = 1
log-queries-not-using-indexes
max_connections = 2048
back_log = 128
wait_timeout = 60
interactive_timeout = 7200
key_buffer_size = 256M
query_cache_size = 256M
query_cache_type = 1
query_cache_limit = 50M
max_connect_errors = 20
sort_buffer_size = 1M
max_allowed_packet = 100M
join_buffer_size = 1M
thread_cache_size = 100
innodb_buffer_pool_size = 2048M
innodb_flush_log_at_trx_commit = 1
innodb_log_buffer_size = 32M
innodb_log_file_size = 128M
innodb_log_files_in_group = 3
log-bin=/var/lib/mysql/mysqlbin
binlog_cache_size = 2M
max_binlog_cache_size = 8M
max_binlog_size = 512M
expire_logs_days = 7
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
max_binlog_cache_size=268435456
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
[client]
socket=/var/lib/mysql/mysql.sock
EOF
```

5. 创建所需目录

```shell
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld
touch /var/log/mysqld.log /var/log/slow-query.log
chown mysql:mysql /var/log/mysqld.log
chown mysql:mysql /var/log/slow-query.log
```

6. 创建service

```shell
$ tee /usr/lib/systemd/system/mysqld.service <<EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql

Type=forking

PIDFile=/run/mysqld/mysqld.pid

# Disable service start and stop timeout logic of systemd for mysqld service.
TimeoutSec=0

# Execute pre and post scripts as root
PermissionsStartOnly=true

# Start main service
ExecStart=/usr/local/mysql/bin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid $MYSQLD_OPTS

# Use this to switch malloc implementation
EnvironmentFile=-/etc/sysconfig/mysql

# Sets open_files_limit
LimitNOFILE = 5000

Restart=on-failure

RestartPreventExitStatus=1

PrivateTmp=false
EOF
```

7. 初始化数据

```shell
/usr/local/mysql/bin/mysql_install_db --user=mysql --datadir=/var/lib/mysql
```

8. 启动mysql

```shell
$ systemctl enable --now mysqld
```

9. 查看状态

```shell
$ systemctl status mysqld
● mysqld.service - MySQL Server
     Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
     Active: active (running) since Wed 2022-08-17 10:47:31 CST; 11s ago
       Docs: man:mysqld(8)
             http://dev.mysql.com/doc/refman/en/using-systemd.html
    Process: 13894 ExecStart=/usr/local/mysql/bin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid (code=exited, status=0/SUCCESS)
   Main PID: 13896 (mysqld)
      Tasks: 30 (limit: 23408)
     Memory: 400.3M
        CPU: 307ms
     CGroup: /system.slice/mysqld.service
             └─13896 /usr/local/mysql/bin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid

8月 17 10:47:31 localhost.localdomain systemd[1]: Starting MySQL Server...
8月 17 10:47:31 localhost.localdomain systemd[1]: Started MySQL Server.
```

10. 建立动态库链接

```shell
$ ln -s /usr/lib64/libncurses.so.6 /usr/lib64/libncurses.so.5
$ ln -s /usr/lib64/libtinfo.so.6 /usr/lib64/libtinfo.so.5
```

11. 初始化root口令测试

```shell
$ systemctl stop mysqld
$ mysqld_safe --skip-grant-tables &
$ mysql -u root
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.38-log MySQL Community Server (GPL)

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use mysql
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> update user set authentication_string = password("Mysql@d523") WHERE user='root';
Query OK, 1 row affected, 1 warning (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 1

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.01 sec)

mysql> exit
Bye
```