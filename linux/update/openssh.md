### 升级openssl版本

> 1.下载最新稳定版

[openssl release地址](https://github.com/openssl/openssl/releases)

> 2.安装必要依赖

    yum install -y wget gcc perl
    
> 3.解压编译

    tar zxvf openssl-OpenSSL_*.tar.gz
    cd openssl-OpenSSL*
    ./config shared --openssldir=/usr/local/openssl --prefix=/usr/local/openssl
    make && make install
    sed -i '/\/usr\/local\/openssl\/lib/d' /etc/ld.so.conf
    echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
    ldconfig -v
    mv /usr/bin/openssl /usr/bin/openssl.old
    ln -s /usr/local/openssl/bin/openssl  /usr/bin/openssl
    cd -
    openssl version
    
### 升级Openssh

> 1.下载openssh包

[下载站点](https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/)

> 2.安装

备份旧ssh配置文件

    mv /etc/ssh/ /etc/ssh-bak
    
编译安装

    yum install -y pam-devel
    ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-zlib --with-md5-passwords
    make && make install

复制pam的头文件：

    \cp contrib/redhat/sshd.pam /etc/pam.d/sshd

复制启动脚本：

    \cp contrib/redhat/sshd.init /etc/init.d/sshd
    \chkconfig sshd on

验证版本信息： 

    ssh -V

重启ssh服务

    service sshd restart

至此openssh升级完毕！