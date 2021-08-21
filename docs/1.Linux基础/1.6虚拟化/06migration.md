## 安装openstack单节点

> 配置阿里`yum`镜像源

    rm -f /etc/yum.repos.d/*
 
- 在线


    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo
    
- 离线：手动下载后上传至`/etc/yum.repos.d/`
    - [Centos-7.repo](http://mirrors.aliyun.com/repo/Centos-7.repo)
    - [epel-7.repo](http://mirrors.aliyun.com/repo/epel-7.repo)
    

> 关闭防火墙

    systemctl disable firewalld --now
    
> 关闭selinux

```shell
setenforce 0
sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
```

> 关闭NetworkManager服务

    systemctl disable NetworkManager --now
   
> 安装依赖

    yum update -y
    yum install python3-devel libffi-devel gcc openssl-devel python3-libselinux python3-pip ansible -y

> 配置`pip`源与代理

`proxy=http://xxx.xxx.xxx.xxx:8080`替换为实际代理，如不需代理删除该配置项

    mkdir ~/.pip
    cat >> ~/.pip/pip.conf <<EOF
    [global] 
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple
    proxy=http://xxx.xxx.xxx.xxx:8080
    [install]
    trusted-host = pypi.tuna.tsinghua.edu.cn
    EOF
    
> 安装`kolla-ansible`

    pip3 install -U pip
    pip3 install kolla-ansible

> 安装`docker`

    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast
    yum -y install docker-ce
    systemctl enable docker --now
    
配置镜像加速

    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache fast
    yum -y install docker-ce
    systemctl enable docker --now

> 拷贝配置

    mkdir -p /etc/kolla
    cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
    cp /usr/local/share/kolla-ansible/ansible/inventory/* /etc/kolla
    
> 修改`hostname`添加解析

    hostnamectl set-hostname kolla
    echo '192.168.1.6    kolla' >> /etc/hosts
    
> 调整配置

- 生成`/etc/kolla/passwords.yml`配置项密码


    /usr/local/bin/kolla-genpwd
    
- 修改`keystone_admin_password`值


    vi /etc/kolla/passwords.yml
    
找到`keystone_admin_password`，替换值为Admin@123


- 调整网络配置

`em1`为宿主机网卡名称

    sed -i "s;#network_interface: "eth0";network_interface: "em1";g" /etc/kolla/globals.yml 
    sed -i "s;#enable_haproxy: \"yes\";enable_haproxy: \"no\";g" /etc/kolla/globals.yml 
    
`192.168.1.6`为宿主机IP
    
    sed -i "s;#kolla_internal_vip_address: \"10.10.10.254\";kolla_internal_vip_address: \"192.168.1.6\";g" /etc/kolla/globals.yml
    
> 克隆

    git clone https://opendev.org/openstack/openstack-ansible
    
> 新增yum源

`openstack-train.repo`

    cat > /etc/yum.repos.d/openstack-train.repo <<EOF
    [openstack-train]
    name=openstack-train
    baseurl=https://mirrors.aliyun.com/centos/7/cloud/x86_64/openstack-train/
    enabled=1
    gpgcheck=0
    EOF
    
`kvm-common.repo`

    cat > /etc/yum.repos.d/kvm-common.repo <<EOF
    [kvm-common]
    name=kvm-common
    baseurl=https://mirrors.aliyun.com/centos/7/virt/x86_64/kvm-common/
    enabled=1
    gpgcheck=0
    EOF
    
> 配置yum代理

**适用于主机通过代理访问互联网场景**

以下变量注意替换

- username: 代理用户名
- password: 代理用户密码
- proxy_host: 代理IP地址
- proxy_port: 代理端口


    echo "proxy=http://username:password@proxy_host:proxy_port" >> /etc/yum.conf
    
> 重建`yum`缓存

    yum clean all
    yum makecache
    
> 安装`OpenStack-packstack`软件包

    yum -y install openstack-packstack
    
> 回退`leatherman`版本

    yum downgrade leatherman -y
    
> 生成默认配置

    packstack --gen-answer-file=~/openstack.txt
    
> 修改`~/openstack.txt`配置

修改内容如下

    sed -i "s#CONFIG_SWIFT_INSTALL=y#CONFIG_SWIFT_INSTALL=n#g" ~/openstack.txt
    sed -i "s#CONFIG_AODH_INSTALL=y#CONFIG_AODH_INSTALL=n#g" ~/openstack.txt
    sed -i "s#CONFIG_NEUTRON_ML2_TYPE_DRIVERS=geneve,flat#CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vxlan,flat#g" ~/openstack.txt
    sed -i "s#CONFIG_NEUTRON_ML2_TENANT_NETWORK_TYPES=geneve#CONFIG_NEUTRON_ML2_TENANT_NETWORK_TYPES=vxlan#g" ~/openstack.txt
    sed -i "s#CONFIG_NEUTRON_ML2_MECHANISM_DRIVERS=ovn#CONFIG_NEUTRON_ML2_MECHANISM_DRIVERS=openvswitch#g" ~/openstack.txt
    
手动修改项
    
    CONFIG_COMPUTE_HOSTS=192.168.19 #计算节点ip地址 
    CONFIG_NEUTRON_ML2_FLAT_NETWORKS=physnet1      #flat网络这边要设置物理网卡名字
    CONFIG_NEUTRON_L2_AGENT=openvswitch            #L2网络的代理模式,也可选择linuxbridge
    CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=physnet1:br-ex    #这边要设置物理网卡的名字
    CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eth0          #这边br-ex:eth0是网络节点的nat网卡，到时候安装完毕之后IP地址会飘到这个上
    
更改主机密码（123456需要替换）

    sed -i -r 's/(.+_PW)=.+/\1=123456/' openstack.txt
    
备份配置

    cp openstack.txt openstack.txt.bak
    
> 安装

    packstack --answer-file=~/openstack.txt

    
- 如出现如下错误


    ...
    Applying Puppet manifests                         [ ERROR ]
    ...
    
执行以下语句

    sed -i "s;#baseurl;baseurl;g" /etc/yum.repos.d/*.repo
    sed -i "s;mirrorlist=;#mirrorlist=;g" /etc/yum.repos.d/*.repo
    rm -f /etc/yum.repos.d/CentOS-*
    rm -f *
    rm -rf /var/tmp/packstack/
    packstack --allinone
    
    
- 错误二


    ...
    Error: (pymysql.err.OperationalError) (1045, u"Access denied for user 'nova'@'192.168.1.6' (using password: YES)") (Background on this error at: http://sqlalche.me/e/e3q8)
    ...
    
执行以下命令

    su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
    
    
> 获取`admin`登录口令

    [root@localhost ~]# cat keystonerc_admin|grep OS_PASSWORD
        export OS_PASSWORD='ab2529c81120445a'
        


