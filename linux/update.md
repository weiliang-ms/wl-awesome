### 升级系统

本机centos7.0

    yum install centos-release -y
    
列出当前版本

    yum repolist all

清空缓存

    yum clean all
    rm -rf /var/cache/yum
    
全局更新至7.1

    yum --disablerepo='*' --enablerepo='C7.1*' upgrade