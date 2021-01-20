## 系统加固

### 禁ping

    echo "1">/proc/sys/net/ipv4/icmp_echo_ignore_all
    
### 升级openssl版本

> 1.下载最新稳定版

[openssl release地址](https://github.com/openssl/openssl/releases)

> 2.安装必要依赖

    yum install -y wget gcc perl
    
> 3.解压编译

    tar zxvf openssl-OpenSSL_*.tar.gz
    cd openssl-OpenSSL*
    ./config shared --openssldir=/usr/local/openssl --prefix=/usr/local/openssl
    make -j $(nproc) && make install
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

> 2.开启telnet(防止失败)

    yum install -y telnet-server telnet xinetd 
    
    systemctl restart telnet.socket
    systemctl restart xinetd
    
    echo 'pts/0' >>/etc/securetty
    echo 'pts/1' >>/etc/securetty
    systemctl restart telnet.socket

> 3.安装

备份旧ssh配置文件

    mv /etc/ssh/ /etc/ssh-bak
    
编译安装

    yum install -y pam-devel zlib-devel
    tar zxvf openssh-*.tar.gz
    cd openssh*
    ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/openssl --with-md5-passwords
    make -j $(nproc) && make install


复制启动脚本：

    \cp contrib/redhat/sshd.init /etc/init.d/sshd
    \chkconfig sshd on

验证版本信息： 

    ssh -V
    
配置

    cat > /etc/ssh/sshd_config <<EOF
    Protocol 2
    SyslogFacility AUTHPRIV
    PermitRootLogin yes
    PasswordAuthentication yes
    ChallengeResponseAuthentication no
    PermitRootLogin yes
    PubkeyAuthentication yes
    UseDNS no
    AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
    AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
    AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
    AcceptEnv XMODIFIERS
    AllowTcpForwarding yes
    X11Forwarding yes
    Subsystem sftp /usr/libexec/openssh/sftp-server
    EOF
    
关闭selinux

    setenforce 0

重启ssh服务

    service sshd restart

成功后关闭telnet

    systemctl disable telnet.socket --now
    systemctl disable xinetd --now

    