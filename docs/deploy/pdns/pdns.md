## pdns

> 安装epel源

    yum install -y epel-release
    
> 安装mariadb

    yum -y install mariadb mariadb-server
    
> 启动mariadb

    systemctl enable mariadb --now
    
> 配置mariadb

    mysql_secure_installation
    
依次输入以下内容
    
    Enter current password for root (enter for none):
    -- 回车
    
    Set root password? [Y/n]
    -- Y
    
    New password:
    -- 输入root口令，这里演示用设置为root
    
    Re-enter new password:
    -- 输入上一步设置的root口令进行确认
    
    Remove anonymous users? [Y/n]
    -- 回车
    
    Disallow root login remotely? [Y/n]
    -- 回车
    
    Remove test database and access to it? [Y/n]
    -- 回车
    
    Reload privilege tables now? [Y/n]
    -- 回车
    
> 修改mariadb字符集

修改服务端

    sed -i "s/\[mysqld\]/&\
    \ninit_connect='SET collation_connection = utf8_unicode_ci'\
    \ninit_connect='SET NAMES utf8'\
    \ncharacter-set-server=utf8\
    \ncollation-server=utf8_unicode_ci\
    \nskip-character-set-client-handshake/" /etc/my.cnf
    
修改客户端

    sed -i "s/\[client\]/&\ndefault-character-set=utf8/" /etc/my.cnf.d/client.cnf
    sed -i "s/\[mysql\]/&\ndefault-character-set=utf8/" /etc/my.cnf.d/mysql-clients.cnf
    
> 重启mariadb

    systemctl restart mariadb

> 查看字符集

    mysql -uroot -proot <<EOF
    show variables like "%character%";show variables like "%collation%";
    EOF
    
输出如下：

    Variable_name   Value
    character_set_client    utf8
    character_set_connection        utf8
    character_set_database  utf8
    character_set_filesystem        binary
    character_set_results   utf8
    character_set_server    utf8
    character_set_system    utf8
    character_sets_dir      /usr/share/mysql/charsets/
    Variable_name   Value
    collation_connection    utf8_unicode_ci
    collation_database      utf8_unicode_ci
    collation_server        utf8_unicode_ci
    
> 创建pdns_db

    mysql -uroot -proot <<EOF
    create database poweradmin;
    EOF
    
> 创建pdns用户

    mysql -uroot -proot <<EOF
    GRANT ALL ON poweradmin.* TO 'poweradmin'@'localhost' IDENTIFIED BY 'poweradmin';
    FLUSH PRIVILEGES;
    EOF
    
> 初始化数据

    mysql -u root -proot poweradmin< /usr/share/doc/pdns-backend-mysql-*/schema.mysql.sql

> 安装pdns

    yum install -y pdns.x86_64 pdns-backend-mysql
    
> 配置pdns

    sed -i "s#launch=bind#launch=gmysql\
    \ngmysql-host=localhost\
    \ngmysql-user=powerdns\
    \ngmysql-dbname=pdns_db\
    \ngmysql-password=powerdns#" /etc/pdns/pdns.conf