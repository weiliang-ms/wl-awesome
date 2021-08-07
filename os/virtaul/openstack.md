<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [控制节点](#%E6%8E%A7%E5%88%B6%E8%8A%82%E7%82%B9)
- [计算节点](#%E8%AE%A1%E7%AE%97%E8%8A%82%E7%82%B9)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[参考文章](https://www.cnblogs.com/heruiguo/p/openstack.html)

节点信息

- 控制节点：132.232.81.250

- 计算节点：139.155.29.65

## 控制节点

> 0.修改hostname

    cat >> /etc/sysconfig/network <<EOF 
    HOSTNAME=controller 
    EOF
    
    sysctl kernel.hostname=controller
    echo "127.0.0.1 `hostname`" >> /etc/hosts

> 1.配置yum源

```shell
rm -f /etc/yum.repos.d/*.repo
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
```
   
更新
 
    cat > /etc/yum.repos.d/cloud.repo <<EOF
    [cloud]
    name=cloud-repo
    baseurl=https://mirrors.aliyun.com/centos/\$releasever/cloud/x86_64/openstack-queens/
    gpgcheck=0
    enabled=1
    EOF
    
    yum clean all
    yum -y update
    
> 2.安装openstack客户端

    yum install python-openstackclient -y
    yum install openstack-selinux -y
    
> 3.mariadb数据库的安装

[参考安装配置](https://www.cnblogs.com/yhongji/p/9783065.html)

OpenStack使用数据库来存储，支持大部分数据库MariaDB或、MySQL或者PostgreSQL，数据库运行于控制节点
    
    yum install mariadb mariadb-server python2-PyMySQL  -y
    
启动

    systemctl enable mariadb.service --now
    
初始化

    mysql_secure_installation
    
根据提示依次输入

    Enter current password for root (enter for none):  # 输入数据库超级管理员root的密码(注意不是系统root的密码)，第一次进入还没有设置密码则直接回车
    
    Set root password? [Y/n]  # 设置密码，y
    
    New password:  # 新密码
    Re-enter new password:  # 再次输入密码
    
    Remove anonymous users? [Y/n]  # 移除匿名用户， y
    
    Disallow root login remotely? [Y/n]  # 拒绝root远程登录，n，不管y/n，都会拒绝root远程登录
    
    Remove test database and access to it? [Y/n]  # 删除test数据库，y：删除。n：不删除，数据库中会有一个test数据库，一般不需要
    
    Reload privilege tables now? [Y/n]  # 重新加载权限表，y。或者重启服务也许
    
> 4.安装rabbitmq

安装 

    yum install rabbitmq-server -y

启动

    systemctl enable rabbitmq-server --now
    
初始化

    rabbitmqctl add_user openstack RABBIT_PASS
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"
    
> 5.安装Memcached

    yum install memcached python-memcached -y

调整配置

    sed -i "s#127.0.0.1#0.0.0.0#g" /etc/sysconfig/memcached
    
启动

    systemctl enable memcached.service --now
    
> 6.安装keystone服务

创建数据库用户

    CREATE DATABASE keystone;
    GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
      IDENTIFIED BY 'KEYSTONE_DBPASS';
    GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
      IDENTIFIED BY 'KEYSTONE_DBPASS';
      
安装keystone相关软件包

    yum install openstack-keystone httpd mod_wsgi -y

配置keystone

    cat > /etc/keystone/keystone.conf <<EOF
    [DEFAULT]
    admin_token = ADMIN_TOKEN
    [assignment]
    [auth]
    [cache]
    [catalog]
    [cors]
    [cors.subdomain]
    [credential]
    [database]
    connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone
    [domain_config]
    [endpoint_filter]
    [endpoint_policy]
    [eventlet_server]
    [eventlet_server_ssl]
    [federation]
    [fernet_tokens]
    [identity]
    [identity_mapping]
    [kvs]
    [ldap]
    [matchmaker_redis]
    [memcache]
    [oauth1]
    [os_inherit]
    [oslo_messaging_amqp]
    [oslo_messaging_notifications]
    [oslo_messaging_rabbit]
    [oslo_middleware]
    [oslo_policy]
    [paste_deploy]
    [policy]
    [resource]
    [revoke]
    [role]
    [saml]
    [shadow_users]
    [signing]
    [ssl]
    [token]
    provider = fernet
    [tokenless_auth]
    [trust]
    EOF
    
同步数据

    su -s /bin/sh -c "keystone-manage db_sync" keystone

初始化fernet

    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    
配置httpd

    echo "ServerName controller" >>/etc/httpd/conf/httpd.conf
    echo 'Listen 5000
    Listen 35357
    
    <VirtualHost *:5000>
        WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
        WSGIProcessGroup keystone-public
        WSGIScriptAlias / /usr/bin/keystone-wsgi-public
        WSGIApplicationGroup %{GLOBAL}
        WSGIPassAuthorization On
        ErrorLogFormat "%{cu}t %M"
        ErrorLog /var/log/httpd/keystone-error.log
        CustomLog /var/log/httpd/keystone-access.log combined
    
        <Directory /usr/bin>
            Require all granted
        </Directory>
    </VirtualHost>
    
    <VirtualHost *:35357>
        WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
        WSGIProcessGroup keystone-admin
        WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
        WSGIApplicationGroup %{GLOBAL}
        WSGIPassAuthorization On
        ErrorLogFormat "%{cu}t %M"
        ErrorLog /var/log/httpd/keystone-error.log
        CustomLog /var/log/httpd/keystone-access.log combined
    
        <Directory /usr/bin>
            Require all granted
        </Directory>
    </VirtualHost>' >/etc/httpd/conf.d/wsgi-keystone.conf
    
启动httpd

    systemctl start httpd
    systemctl enable httpd
    
初始化keystone

    export OS_TOKEN=ADMIN_TOKEN
    export OS_URL=http://controller:35357/v3
    export OS_IDENTITY_API_VERSION=3
    
    openstack service create --name keystone --description "OpenStack Identity" identity
    openstack endpoint create --region RegionOne  identity public http://controller:5000/v3
    openstack endpoint create --region RegionOne  identity internal http://controller:5000/v3
    openstack endpoint create --region RegionOne  identity admin http://controller:35357/v3

    # 创建域,项目,用户,角色
    openstack domain create --description "Default Domain" default
    openstack project create --domain default --description "Admin Project" admin
    openstack user create --domain default  --password ADMIN_PASS admin
    openstack role create admin
    openstack role add --project admin --user admin admin
    
    openstack project create --domain default \
      --description "Service Project" service
      
      
    unset OS_TOKEN OS_URL   ###把他加入开机自启，不然下次启动会无法访问
    export OS_PROJECT_DOMAIN_NAME=default
    export OS_USER_DOMAIN_NAME=default
    export OS_PROJECT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=ADMIN_PASS
    export OS_AUTH_URL=http://controller:35357/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2
    
验证keystone服务是否正常

> 7.安装glance镜像服务

mysql中创库授权

    CREATE DATABASE glance;
    GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
      IDENTIFIED BY 'GLANCE_DBPASS';
    GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
      IDENTIFIED BY 'GLANCE_DBPASS';

在keystone创建系统账号,并关联角色

    openstack user create --domain default --password GLANCE_PASS glance
    openstack role add --project service --user glance admin
    
在keystone上创建服务名称,注册api

    openstack service create --name glance  --description "OpenStack Image" image
    openstack endpoint create --region RegionOne  image public http://controller:9292
    openstack endpoint create --region RegionOne  image internal http://controller:9292
    openstack endpoint create --region RegionOne  image admin http://controller:9292
    
安装相关软件包

    yum install openstack-glance openstack-utils -y
    
修改配置文件

    openstack-config --set /etc/glance/glance-api.conf  database  connection  mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
    openstack-config --set /etc/glance/glance-api.conf  glance_store stores  file,http
    openstack-config --set /etc/glance/glance-api.conf  glance_store default_store  file
    openstack-config --set /etc/glance/glance-api.conf  glance_store filesystem_store_datadir  /var/lib/glance/images/
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken auth_uri  http://controller:5000
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken auth_url  http://controller:35357
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken memcached_servers  controller:11211
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken auth_type  password
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken project_domain_name  default
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken user_domain_name  default
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken project_name  service
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken username  glance
    openstack-config --set /etc/glance/glance-api.conf  keystone_authtoken password  GLANCE_PASS
    openstack-config --set /etc/glance/glance-api.conf  paste_deploy flavor  keystone
    #cat glance-registry.conf >/etc/glance/glance-registry.conf 
    openstack-config --set /etc/glance/glance-registry.conf  database  connection  mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken auth_uri  http://controller:5000
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken auth_url  http://controller:35357
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken memcached_servers  controller:11211
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken auth_type  password
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken project_domain_name  default
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken user_domain_name  default
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken project_name  service
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken username  glance
    openstack-config --set /etc/glance/glance-registry.conf  keystone_authtoken password  GLANCE_PASS
    openstack-config --set /etc/glance/glance-registry.conf  paste_deploy flavor  keystone
    
同步数据(创表)

    su -s /bin/sh -c "glance-manage db_sync" glance

启动服务

    systemctl enable openstack-glance-api.service  openstack-glance-registry.service
    systemctl start openstack-glance-api.service  openstack-glance-registry.service
    
验证。上传[cirros-0.3.4-x86_64-disk.img](http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img)到当前目录    

    openstack image create "cirros"   --file cirros-0.3.4-x86_64-disk.img   --disk-format qcow2 --container-format bare   --public

检查上传结果

    openstack image list
    
> 8.安装nova计算服务控制端

mysql中创库授权

    CREATE DATABASE nova_api;
    CREATE DATABASE nova;
    GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' \
      IDENTIFIED BY 'NOVA_DBPASS';
    GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' \
      IDENTIFIED BY 'NOVA_DBPASS';
    GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
      IDENTIFIED BY 'NOVA_DBPASS';
    GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
      IDENTIFIED BY 'NOVA_DBPASS';
      
在keystone创建系统账号,并关联角色

    openstack user create --domain default  --password NOVA_PASS nova
    openstack role add --project service --user nova admin
    
在keystone上创建服务名称,注册api

    openstack service create --name nova \
      --description "OpenStack Compute" compute
     openstack endpoint create --region RegionOne \
      compute public http://controller:8774/v2.1/%\(tenant_id\)s
     openstack endpoint create --region RegionOne \
      compute internal http://controller:8774/v2.1/%\(tenant_id\)s
     openstack endpoint create --region RegionOne \
      compute admin http://controller:8774/v2.1/%\(tenant_id\)s
      
安装相关软件包

    yum install -y openstack-nova-api openstack-nova-placement-api \
      openstack-nova-conductor openstack-nova-console \
      openstack-nova-novncproxy openstack-nova-scheduler
      
修改配置文件

    cp /etc/nova/nova.conf{,.bak}
    grep -Ev '^$|#' /etc/nova/nova.conf.bak >/etc/nova/nova.conf
    
    openstack-config --set /etc/nova/nova.conf  DEFAULT enabled_apis  osapi_compute,metadata
    openstack-config --set /etc/nova/nova.conf  DEFAULT transport_url rabbit://openstack:RABBIT_PASS@controller
    openstack-config --set /etc/nova/nova.conf  DEFAULT auth_strategy  keystone
    openstack-config --set /etc/nova/nova.conf  DEFAULT my_ip  10.0.0.11
    openstack-config --set /etc/nova/nova.conf  DEFAULT use_neutron  True
    openstack-config --set /etc/nova/nova.conf  DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver
    openstack-config --set /etc/nova/nova.conf  api_database connection  mysql+pymysql://nova:NOVA_DBPASS@controller/nova_api
    openstack-config --set /etc/nova/nova.conf  database  connection  mysql+pymysql://nova:NOVA_DBPASS@controller/nova
    openstack-config --set /etc/nova/nova.conf  glance api_servers  http://controller:9292
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  auth_uri  http://controller:5000
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  auth_url  http://controller:35357
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  memcached_servers  controller:11211
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  auth_type  password
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  project_domain_name  default
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  user_domain_name  default
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  project_name  service
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  username  nova
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  password  NOVA_PASS
    openstack-config --set /etc/nova/nova.conf  oslo_concurrency lock_path  /var/lib/nova/tmp
    openstack-config --set /etc/nova/nova.conf  oslo_messaging_rabbit   rabbit_host  controller
    openstack-config --set /etc/nova/nova.conf  oslo_messaging_rabbit   rabbit_userid  openstack
    openstack-config --set /etc/nova/nova.conf  oslo_messaging_rabbit   rabbit_password  RABBIT_PASS
    openstack-config --set /etc/nova/nova.conf  libvirt  virt_type  qemu
    openstack-config --set /etc/nova/nova.conf  libvirt  cpu_mode  none
    openstack-config --set /etc/nova/nova.conf  vnc enabled  True
    openstack-config --set /etc/nova/nova.conf  vnc vncserver_listen  0.0.0.0
    openstack-config --set /etc/nova/nova.conf  vnc vncserver_proxyclient_address  '$my_ip'
    openstack-config --set /etc/nova/nova.conf  vnc novncproxy_base_url  http://controller:6080/vnc_auto.html
    openstack-config --set /etc/nova/nova.conf  neutron url  http://controller:9696
    openstack-config --set /etc/nova/nova.conf  neutron auth_url  http://controller:35357
    openstack-config --set /etc/nova/nova.conf  neutron auth_type  password
    openstack-config --set /etc/nova/nova.conf  neutron project_domain_name  default
    openstack-config --set /etc/nova/nova.conf  neutron user_domain_name  default
    openstack-config --set /etc/nova/nova.conf  neutron region_name  RegionOne
    openstack-config --set /etc/nova/nova.conf  neutron project_name  service
    openstack-config --set /etc/nova/nova.conf  neutron username  neutron
    openstack-config --set /etc/nova/nova.conf  neutron password  NEUTRON_PASS
    openstack-config --set /etc/nova/nova.conf  neutron service_metadata_proxy  True
    openstack-config --set /etc/nova/nova.conf  neutron metadata_proxy_shared_secret  METADATA_SECRET
    
修改myip为实际IP

    sed -i "s#my_ip = 10.0.0.11#my_ip = 172.27.0.13#g" /etc/nova/nova.conf
    
配置placement

    sed -i '/\[placement\]/d' /etc/nova/nova.conf
    cat >> /etc/nova/nova.conf <<EOF
    [placement]
    os_region_name = RegionOne
    project_domain_name = Default
    project_name = service
    auth_type = password
    user_domain_name = Default
    auth_url = http://controller:35357/v3
    username = placement
    password = placement
    EOF

修改`/etc/httpd/conf.d/00-nova-placement-api.conf`,在<VirtualHost></VirtualHost>之间添加如下代码

    <Directory /usr/bin>
       <IfVersion >= 2.4>
          Require all granted
       </IfVersion>
       <IfVersion < 2.4>
          Order allow,deny
          Allow from all
       </IfVersion>
    </Directory>

    
同步nova-api数据库

    su -s /bin/sh -c "nova-manage api_db sync" nova
    
注册cell0数据库

    su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova

创建cell1的cell

    su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
    
同步nova数据库
    
    su -s /bin/sh -c "nova-manage db sync" nova
    
验证cell0和cell1的注册是否正确

    nova-manage cell_v2 list_cells
    
启动服务

    systemctl enable openstack-nova-api.service \
      openstack-nova-consoleauth.service openstack-nova-scheduler.service \
      openstack-nova-conductor.service openstack-nova-novncproxy.service
    systemctl restart openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service

nova服务注册

    openstack service create --name nova --description "OpenStack Compute" compute
    openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1
    openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1
    openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1
    
    openstack service create --name placement --description "Placement API" placement
    openstack endpoint create --region RegionOne placement public http://controller:8778
    openstack endpoint create --region RegionOne placement internal http://controller:8778
    openstack endpoint create --region RegionOne placement admin http://controller:8778
 
验证控制节点服务

    openstack host list
    
   
## 计算节点

> 1.配置yum源

    rm -f /etc/yum.repos.d/*.repo
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
   
更新
 
    cat > /etc/yum.repos.d/cloud.repo <<EOF
    [cloud]
    name=cloud-repo
    baseurl=https://mirrors.aliyun.com/centos/\$releasever/cloud/x86_64/openstack-queens/
    gpgcheck=0
    enabled=1
    EOF
    
    cat > /etc/yum.repos.d/CentOS-Virt.repo <<EOF
    [Virt]
    name=CentOS-\$releasever - Base
    #mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=os&infra=\$infra
    baseurl=http://mirrors.sohu.com/centos/7/virt/x86_64/kvm-common/
    gpgcheck=0
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    EOF
    
    yum clean all
    yum -y update
    
> 2.安装openstack客户端

    yum install python-openstackclient -y
    yum install openstack-selinux -y
    
> 3.修改`hostname`，配置`/etc/hosts`文件
    
    cat >> /etc/sysconfig/network <<EOF 
    HOSTNAME=compute1 
    EOF
    
    sysctl kernel.hostname=compute1
    echo "127.0.0.1 `hostname`" >> /etc/hosts
    
    
> 4.计算节点安装nova计算服务agent端

安装软件

    yum install openstack-nova-compute openstack-utils -y

配置

    cp /etc/nova/nova.conf{,.bak}
    grep '^[a-Z\[]' /etc/nova/nova.conf.bak >/etc/nova/nova.conf
    openstack-config --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:RABBIT_PASS@controller
    openstack-config --set /etc/nova/nova.conf  DEFAULT auth_strategy  keystone
    openstack-config --set /etc/nova/nova.conf  DEFAULT my_ip  10.0.0.31
    openstack-config --set /etc/nova/nova.conf  DEFAULT use_neutron  True
    openstack-config --set /etc/nova/nova.conf  DEFAULT firewall_driver  nova.virt.firewall.NoopFirewallDriver
    openstack-config --set /etc/nova/nova.conf  glance api_servers  http://controller:9292
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  auth_uri  http://controller:5000
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  auth_url  http://controller:35357
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  memcached_servers  controller:11211
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  auth_type  password
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  project_domain_name  default
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  user_domain_name  default
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  project_name  service
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  username  nova
    openstack-config --set /etc/nova/nova.conf  keystone_authtoken  password  NOVA_PASS
    openstack-config --set /etc/nova/nova.conf  oslo_concurrency lock_path  /var/lib/nova/tmp
    openstack-config --set /etc/nova/nova.conf  oslo_messaging_rabbit   rabbit_host  controller
    openstack-config --set /etc/nova/nova.conf  oslo_messaging_rabbit   rabbit_userid  openstack
    openstack-config --set /etc/nova/nova.conf  oslo_messaging_rabbit   rabbit_password  RABBIT_PASS
    openstack-config --set /etc/nova/nova.conf  vnc enabled  True
    openstack-config --set /etc/nova/nova.conf  vnc vncserver_listen  0.0.0.0
    openstack-config --set /etc/nova/nova.conf  vnc vncserver_proxyclient_address  '$my_ip'
    openstack-config --set /etc/nova/nova.conf  vnc novncproxy_base_url  http://controller:6080/vnc_auto.html
    
调整my_ip    
    
    sed -i "s#10.0.0.31#172.27.0.8#g" /etc/nova/nova.conf
    
启动
    
    systemctl start libvirtd
    systemctl enable libvirtd
    systemctl start openstack-nova-compute
    systemctl enable openstack-nova-compute
    
**控制节点验证**

    openstack compute service list
    
计算节点加入控制节点（控制节点执行）

    su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova


    
    

    

    
    
