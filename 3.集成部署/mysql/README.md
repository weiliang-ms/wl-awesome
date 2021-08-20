- [集成部署](#%E9%9B%86%E6%88%90%E9%83%A8%E7%BD%B2)
  - [单机集成部署](#%E5%8D%95%E6%9C%BA%E9%9B%86%E6%88%90%E9%83%A8%E7%BD%B2)
- [添加slave节点](#%E6%B7%BB%E5%8A%A0slave%E8%8A%82%E7%82%B9)
- [cli命令](#cli%E5%91%BD%E4%BB%A4)
  - [查看连接](#%E6%9F%A5%E7%9C%8B%E8%BF%9E%E6%8E%A5)
- [配置优化](#%E9%85%8D%E7%BD%AE%E4%BC%98%E5%8C%96)
  - [连接数](#%E8%BF%9E%E6%8E%A5%E6%95%B0)
  - [暂存连接数](#%E6%9A%82%E5%AD%98%E8%BF%9E%E6%8E%A5%E6%95%B0)
  - [缓冲区变量](#%E7%BC%93%E5%86%B2%E5%8C%BA%E5%8F%98%E9%87%8F)
  - [防止暴力破解](#%E9%98%B2%E6%AD%A2%E6%9A%B4%E5%8A%9B%E7%A0%B4%E8%A7%A3)
  - [限制数据包大小](#%E9%99%90%E5%88%B6%E6%95%B0%E6%8D%AE%E5%8C%85%E5%A4%A7%E5%B0%8F)
- [使用教程](#%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B)
  - [慢查询](#%E6%85%A2%E6%9F%A5%E8%AF%A2)
  - [查看变量](#%E6%9F%A5%E7%9C%8B%E5%8F%98%E9%87%8F)
  - [查看锁性能](#%E6%9F%A5%E7%9C%8B%E9%94%81%E6%80%A7%E8%83%BD)
  - [查看连接数](#%E6%9F%A5%E7%9C%8B%E8%BF%9E%E6%8E%A5%E6%95%B0)
  - [查看回滚数量](#%E6%9F%A5%E7%9C%8B%E5%9B%9E%E6%BB%9A%E6%95%B0%E9%87%8F)
  - [查询运行时间](#%E6%9F%A5%E8%AF%A2%E8%BF%90%E8%A1%8C%E6%97%B6%E9%97%B4)
  - [查询缓存状态](#%E6%9F%A5%E8%AF%A2%E7%BC%93%E5%AD%98%E7%8A%B6%E6%80%81)
  - [查看连接信息](#%E6%9F%A5%E7%9C%8B%E8%BF%9E%E6%8E%A5%E4%BF%A1%E6%81%AF)
  - [查询表使用状态](#%E6%9F%A5%E8%AF%A2%E8%A1%A8%E4%BD%BF%E7%94%A8%E7%8A%B6%E6%80%81)
  - [查看增删改数量](#%E6%9F%A5%E7%9C%8B%E5%A2%9E%E5%88%A0%E6%94%B9%E6%95%B0%E9%87%8F)
  - [修改密码](#%E4%BF%AE%E6%94%B9%E5%AF%86%E7%A0%81)
  - [binlog](#binlog)

## 集成部署

[较全的教程](https://github.com/judasn/Linux-Tutorial/blob/master/markdown-file/Mysql-Install-And-Settings.md)

### 单机集成部署

`适用于CentOS Red Hat`

[官网 5.5 下载](http://dev.mysql.com/downloads/mysql/5.5.html#downloads)

[官网 5.6 下载](http://dev.mysql.com/downloads/mysql/5.6.html#downloads)

[官网 5.7 下载](http://dev.mysql.com/downloads/mysql/5.7.html#downloads)

> 版本信息

	5.7.27社区版

> 配置yum源

	配置基础yum源即可无需epel源

配置阿里云源（保证网络可达）

[Centos-5.repo](http://mirrors.aliyun.com/repo/Centos-5.repo)

[Centos-6.repo](http://mirrors.aliyun.com/repo/Centos-6.repo)

[Centos-7.repo](http://mirrors.aliyun.com/repo/Centos-7.repo)

> 安装卸载依赖

```bash
yum install net-tools -y
yum remove mysql* -y
```
centos7需要卸载mariadb

```bash
yum remove -y mariadb-libs
```

> 上传安装包至/tmp下，进行安装

```bash
cd /tmp
rpm -ivh mysql-community-common-*.el7.x86_64.rpm
rpm -ivh mysql-community-libs-*.el7.x86_64.rpm
rpm -ivh mysql-community-client-*.el7.x86_64.rpm
rpm -ivh mysql-community-server-*.el7.x86_64.rpm
```

> 配置

```bash
echo "default-storage-engine=INNODB" >>/etc/my.cnf
echo "character-set-server=utf8"  >>/etc/my.cnf
echo "collation-server=utf8_general_ci"  >>/etc/my.cnf
echo "lower_case_table_names=1" >>/etc/my.cnf
```

> 启动

centos7
    
```bash
systemctl daemon-reload
systemctl enable mysqld --now
```
	
centos6

```bash
service mysqld start
chkconfig mysqld on
```

> 修改防火墙、SElinux策略

```bash
firewall-cmd --permanent --zone=public --add-port=3306/tcp
firewall-cmd --reload
setenforce 0
```

> 修改root密码

```sql
password=`grep 'temporary password' /var/log/mysqld.log|awk '{print $NF}'|awk 'END {print}'`
mysql -uroot -p$password --connect-expired-password <<EOF
set global validate_password_policy=0;
set global validate_password_length=1;
set password=passworD("root");
FLUSH PRIVILEGES;
quit
EOF
```
## 添加slave节点

1、确认主节点版本

2、从节点安装相同版本mysql

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

## cli命令
### 查看连接
 
> 查看当前连接数

```sql
show status like 'Threads%';
```

> 查看最大连接数

```sql
show variables like '%max_connections%';
```

> 查看显示连接状态

```sql
SHOW STATUS LIKE '%connect%';
```

> 查看当前所有连接

```sql
show full processlist;
```

## 配置优化

[参考地址](https://www.jb51.net/article/144039.htm#_lab2_2_0)

### 连接数

查看最大连接数，默认151

	show VARIABLES like 'max_connections';

	+-----------------+-------+
	| Variable_name   | Value |
	+-----------------+-------+
	| max_connections | 151   |
	+-----------------+-------+
	1 row in set (0.00 sec)

查看当前连接数

	SHOW STATUS LIKE 'max_used_connections';
	
	# 理想值约等于85%
    max_used_connections/max_connections*100% 

配置方式

	#客户端命令行
	set GLOBAL max_connections=2000;
	set GLOBAL max_user_connections=1500;

	#配置文件
	[mysqld]
	max_connections = 1000
	max_user_connections=1500

### 暂存连接数

MySQL能够暂存的连接数量。

当主要MySQL线程在一个很短时间内得到非常多的连接请求，他就会起作用。
如果MySQL的连接数据达到max_connections时，新的请求将会被存在堆栈中，以等待某一连接释放资源，该堆栈数量即back_log，如果等待连接的数量超过back_log，将不被接受连接资源。

	show VARIABLES like 'back_log';

	mysql> show VARIABLES like 'back_log';
	+---------------+-------+
	| Variable_name | Value |
	+---------------+-------+
	| back_log      | 80    |
	+---------------+-------+
	1 row in set (0.00 sec)


back_log值不能超过TCP/IP连接的侦听队列的大小。若超过则无效，查看当前系统的TCP/IP连接的侦听队列的大小命令（默认128）

	cat /proc/sys/net/ipv4/tcp_max_syn_backlog

配置方式

	echo "net.ipv4.tcp_max_syn_backlog = 8192" >> /etc/sysctl.conf
	sysctl -p
	
	#配置文件
	[mysqld]
	back_log=128

### 缓冲区变量

**1、key_buffer_size**

默认的配置数时8388608（8M），主机有4G内存可以调优值为268435456（256M）

通过检查状态值 key_read_requests和key_reads，可以知道key_buffer_size设置是否合理。

比例key_reads/key_read_requests应该尽可能的低，至少是1：100，1：1000更好（上述状态值可以使用show status like ‘key_read%'获得）
	
	mysql> show variables like 'key_buffer_size';
	+-----------------+---------+
	| Variable_name   | Value   |
	+-----------------+---------+
	| key_buffer_size | 8388608 |
	+-----------------+---------+
	1 row in set (0.00 sec)

	mysql> show status like 'key_read%';
	+-------------------+-------+
	| Variable_name     | Value |
	+-------------------+-------+
	| Key_read_requests | 33    |
	| Key_reads         | 8     |
	+-------------------+-------+
	2 rows in set (0.00 sec)

	set global key_buffer_size = 256*1024*1024;

**2、query_cache_size**

使用查询缓存，MySQL将查询结果存放在缓冲区中，今后对同样的select语句（区分大小写），将直接从缓冲区中读取结果。

一个SQL查询如果以select开头，那么MySQL服务器将尝试对其使用查询缓存。

注：两个SQL语句，只要相差哪怕是一个字符（例如 大小写不一样：多一个空格等），那么两个SQL将使用不同的cache

 通过 show status like 'Qcache%'; 可以知道query_cache_size的设置是否合理

	mysql> show status like 'Qcache%';
	+-------------------------+---------+
	| Variable_name           | Value   |
	+-------------------------+---------+
	| Qcache_free_blocks      | 1       |
	| Qcache_free_memory      | 1031832 |
	| Qcache_hits             | 0       |
	| Qcache_inserts          | 0       |
	| Qcache_lowmem_prunes    | 0       |
	| Qcache_not_cached       | 9       |
	| Qcache_queries_in_cache | 0       |
	| Qcache_total_blocks     | 1       |
	+-------------------------+---------+
	8 rows in set (0.00 sec)

**3、sort_buffer_size**

每个需要排序的线程分配该大小的一个缓冲区。增加这值加速ORDER BY 或 GROUP BY操作
 
`sort_buffer_size`是一个connection级的参数，在每个connection（session）第一次需要使用这个buffer的时候，一次性分配设置的内存。

`sort_buffer_size`并不是越大越好，由于是connection级的参数，过大的设置+高并发可能会耗尽系统的内存资源。例如：500个连接将会消耗500*sort_buffer_size(2M)=1G

**默认0.25M**

	set global sort_buffer_size = 1 *1024 * 1024;

`join_buffer_size`

用于表示关联缓存的大小，和sort_buffer_size一样，该参数对应的分配内存也是每个连接独享。

	set global join_buffer_size = 1 *1024 * 1024;

**4、thread_cache_size**

服务器线程缓存，这个值表示可以重新利用保存在缓存中的线程数量，
当断开连接时，那么客户端的线程将被放到缓存中以响应下一个客户而不是销毁（前提时缓存数未达上限），如果线程重新被请求，那么请求将从缓存中读取，如果缓存中是空的或者是新的请求，这个线程将被重新请求，那么这个线程将被重新创建，如果有很多新的线程，增加这个值可以改善系统性能，通过比较Connections和Threads_created状态的变量，可以看到这个变量的作用。

**默认9**

	set global thread_cache_size = 100;

可以通过如下几个MySQL状态值来适当调整线程池的大小

	Threads_cached    : 当前线程池中缓存有多少空闲线程
	Threads_connected : 当前的连接数 ( 也就是线程数 )
	Threads_created   : 已经创建的线程总数
	Threads_running   : 当前激活的线程数 ( Threads_connected 中的线程有些可能处于休眠状态 )

可以通过 `show global status like 'Threads_%';` 命令查看以上4个状态值

### 防止暴力破解
	
`max_connect_errors`

是一个MySQL中与安全有关的计数器值，他负责阻止过多尝试失败的客户端以防止暴力破解密码的情况，
当超过指定次数，MySQL服务器将禁止host的连接请求，直到mysql服务器重启或通过flush hosts命令清空此host的相关信息。

	set global max_connect_errors = 20;

### 限制数据包大小

限制server接受的数据包大小，默认4M。

	mysql> show VARIABLES like 'max_allowed_packet';
	+--------------------+---------+
	| Variable_name      | Value   |
	+--------------------+---------+
	| max_allowed_packet | 4194304 |
	+--------------------+---------+
	1 row in set (0.00 sec)

	set global max_allowed_packet = 32*1024*1024;

## 使用教程

[使用教程1](http://www.tutorialspoint.com/mysql/)

[使用教程2](http://www.mysqltutorial.org/)

[使用教程3](http://zetcode.com/databases/mysqltutorial/)

[使用教程4](http://www.runoob.com/mysql/mysql-connection.html)

[使用教程5](http://www.w3school.com.cn/sql/)

[使用教程6](https://wizardforcel.gitbooks.io/w3school-sql/content/part7.html)

### 慢查询

查看`查询慢sql`配置

	show variables like 'slow%';

开启慢sql

	set global slow_query_log='ON'

查询慢 SQL 秒数值

	show variables like 'long%';

### 查看变量

	#该语句输出较多
	SHOW VARIABLES;

	SHOW VARIABLES like 'version';

### 查看锁性能

锁性能状态：

	SHOW STATUS LIKE 'innodb_row_lock_%';

	mysql> SHOW STATUS LIKE 'innodb_row_lock_%';
	+-------------------------------+--------+
	| Variable_name                 | Value  |
	+-------------------------------+--------+
	| Innodb_row_lock_current_waits | 0      |
	| Innodb_row_lock_time          | 497180 |
	| Innodb_row_lock_time_avg      | 4075   |
	| Innodb_row_lock_time_max      | 51006  |
	| Innodb_row_lock_waits         | 122    |
	+-------------------------------+--------+
	5 rows in set (0.00 sec)

`Innodb_row_lock_current_waits`：当前等待锁的数量

`Innodb_row_lock_time`：系统启动到现在、锁定的总时间长度

`Innodb_row_lock_time_avg`：每次平均锁定的时间

`Innodb_row_lock_time_max`：最长一次锁定时间

`Innodb_row_lock_waits`：系统启动到现在、总共锁定次数

### 查看连接数

	mysql> SHOW STATUS LIKE 'max_used_connections';
	+----------------------+-------+
	| Variable_name        | Value |
	+----------------------+-------+
	| Max_used_connections | 86    |
	+----------------------+-------+
	1 row in set (0.02 sec)
	
	mysql>


### 查看回滚数量

如果 rollback 过多，说明程序肯定哪里存在问题

	SHOW STATUS LIKE '%Com_rollback%';

### 查询运行时间

显示MySQL服务启动运行了多少时间，如果MySQL服务重启，该时间重新计算，单位秒

	SHOW STATUS LIKE 'uptime';

### 查询缓存状态

显示查询缓存的状态情况

	SHOW STATUS LIKE 'qcache%';

### 查看连接信息

[例子出处](http://www.ibloger.net/article/2519.html)

	SHOW FULL PROCESSLIST;

	#输出如下
	mysql> show processlist;
	+----+------+----------------------+---------+---------+------+-------+------------------+
	| Id | User | Host                 | db      | Command | Time | State | Info             |
	+----+------+----------------------+---------+---------+------+-------+------------------+
	|  1 | root | 192.168.20.160:53417 | firefly | Sleep   |   50 |       | NULL             |
	|  2 | root | localhost            | NULL    | Query   |    0 | init  | show processlist |
	+----+------+----------------------+---------+---------+------+-------+------------------+
	2 rows in set (0.00 sec)
	
	mysql> show processlist;
	+----+------+----------------------+---------+---------+------+--------------+---------------------+
	| Id | User | Host                 | db      | Command | Time | State        | Info                                                                                                 |
	+----+------+----------------------+---------+---------+------+--------------+---------------------+
	|  1 | root | 192.168.20.160:53417 | firefly | Query   |  125 | Sending data | SELECT
	    o.order_id,
	    creator_id,
	    '',
	    city_name,
	    order_address,
	    city_id,
	    order_type_description, |
	|  2 | root | localhost            | NULL    | Query   |    0 | init         | show processlist                                                                                     |
	+----+------+----------------------+---------+---------+------+--------------+-------------------+
	2 rows in set (0.00 sec)

`id`：标识

`user`：当前用户，如果不是root，这个命令就只显示你权限范围内的sql语句

`host`：显示执行sql语句的ip地址和端口号，追踪出问题语句的用户

`db`：显示这个进程目前连接的是哪个数据库

`command`：显示当前连接的执行的命令，一般就是休眠（sleep），查询（query），连接（connect）

`time`：状态持续的时间，单位是秒。

`state`，使用当前连接的sql语句的状态，很重要的列。

**注意，state只是语句执行中的某一个状态，一个sql语句，已查询为例，可能需要经过copying to tmp table，Sorting result，Sending data等状态才可以完成**

`info`：显示执行的sql语句，因为长度有限，所以长的sql语句就显示不全，但是，是一个判断问题语句的重要依据。

**state列**

这个命令中最关键的就是state列，mysql列出的状态主要有以下几种，所有状态参考下面官方手册：

`Checking table`

正在检查数据表（这是自动的）。

`Closing tables`

正在将表中修改的数据刷新到磁盘中，同时正在关闭已经用完的表。这是一个很快的操作，如果不是这样的话，就应该确认磁盘空间是否已经满了或者磁盘是否正处于重负中。

`Connect Out`

复制从服务器正在连接主服务器。

`Copying to tmp table on disk`

由于临时结果集大于tmp_table_size，正在将临时表从内存存储转为磁盘存储以此节省内存。

`Creating tmp table`

正在创建临时表以存放部分查询结果。

`deleting from main table`

服务器正在执行多表删除中的第一部分，刚删除第一个表。

`deleting from reference tables`

服务器正在执行多表删除中的第二部分，正在删除其他表的记录。

`Flushing tables`

正在执行FLUSH TABLES，等待其他线程关闭数据表。

`Killed`

发送了一个kill请求给某线程，那么这个线程将会检查kill标志位，同时会放弃下一个kill请求。MySQL会在每次的主循环中检查kill标志位，不过有些情况下该线程可能会过一小段才能死掉。如果该线程程被其他线程锁住了，那么kill请求会在锁释放时马上生效。

`Locked`

被其他查询锁住了。

`Sending data`

正在处理Select查询的记录，同时正在把结果发送给客户端。

`Sorting for group`

正在为GROUP BY做排序。

`Sorting for order`

正在为ORDER BY做排序。

`Opening tables`

这个过程应该会很快，除非受到其他因素的干扰。例如，在执Alter TABLE或LOCK TABLE语句行完以前，数据表无法被其他线程打开。正尝试打开一个表。

`Removing duplicates`

正在执行一个Select DISTINCT方式的查询，但是MySQL无法在前一个阶段优化掉那些重复的记录。因此，MySQL需要再次去掉重复的记录，然后再把结果发送给客户端。

`Reopen table`

获得了对一个表的锁，但是必须在表结构修改之后才能获得这个锁。已经释放锁，关闭数据表，正尝试重新打开数据表。

`Repair by sorting`

修复指令正在排序以创建索引。

`Repair with keycache`

修复指令正在利用索引缓存一个一个地创建新索引。它会比Repair by sorting慢些。

`Searching rows for update`

正在讲符合条件的记录找出来以备更新。它必须在Update要修改相关的记录之前就完成了。

`Sleeping`

正在等待客户端发送新请求.

`System lock`

正在等待取得一个外部的系统锁。如果当前没有运行多个mysqld服务器同时请求同一个表，那么可以通过增加--skip-external-locking参数来禁止外部系统锁。

`Upgrading lock`

Insert DELAYED正在尝试取得一个锁表以插入新记录。

`Updating`

正在搜索匹配的记录，并且修改它们。

`User Lock`

正在等待GET_LOCK()。

`Waiting for tables`

该线程得到通知，数据表结构已经被修改了，需要重新打开数据表以取得新的结构。然后，为了能的重新打开数据表，必须等到所有其他线程关闭这个表。以下几种情况下会产生这个通知：FLUSH TABLES tbl_name, Alter TABLE, RENAME TABLE, REPAIR TABLE, ANALYZE TABLE,或OPTIMIZE TABLE。

`waiting for handler insert`

Insert DELAYED已经处理完了所有待处理的插入操作，正在等待新的请求。

大部分状态对应很快的操作，只要有一个线程保持同一个状态好几秒钟，那么可能是有问题发生了，需要检查一下。

还有其他的状态没在上面中列出来，不过它们大部分只是在查看服务器是否有存在错误是才用得着

### 查询表使用状态

查询哪些表在被使用，是否有锁表：

	SHOW OPEN TABLES WHERE In_use > 0;

### 查看增删改数量

查询当前MySQL中查询、更新、删除执行多少条了，可以通过这个来判断系统是侧重于读还是侧重于写，如果是写要考虑使用读写分离。

	SHOW STATUS LIKE '%Com_select%';
	SHOW STATUS LIKE '%Com_insert%';
	SHOW STATUS LIKE '%Com_update%';
	SHOW STATUS LIKE '%Com_delete%';
	
### 修改密码

    use mysql
    update user set authentication_string=password('1qaz#EDC') where user='root';
    flush privileges;
    
### binlog

> 查看binlog保存天数

默认值为0，即永久保存

```sql
show variables like 'expire_logs_days';
```

> 配置binlog失效时间

```sql
set global expire_logs_days=7;
```

> 清理binlog

```sql
flush logs;
```

> 清除指定时间的binlog

```sql
purge binary logs before '2017-05-01 13:09:51';
```


