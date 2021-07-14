- 软件升级
  - [升级kernel](kernel.md)
  - [gcc](#gcc)
  - [openssl](#openssl)
  - [openssh](#openssh)

# 软件升级
更新升级如`kernel`、`openssl`、`openssh`等
    
## gcc

升级至5.4

> 下载介质

- [gcc-5.4.0.tar.gz](http://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz)
- [gmp-4.3.2.tar.gz](http://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.gz)
- [mpc-1.0.1.tar.gz](http://ftp.gnu.org/gnu/mpc/mpc-1.0.1.tar.gz)
- [mpfr-2.4.2.tar.gz](http://ftp.gnu.org/gnu/mpfr/mpfr-2.4.2.tar.gz)

> 安装依赖

    tar zxvf gmp-4.3.2.tar.gz
    cd gmp-4.3.2
    ./configure --prefix=/usr/local/gmp-4.3.2 \
    && make -j $(nproc) && make install && cd -
    
    tar zxvf mpfr-2.4.2.tar.gz
    cd mpfr-2.4.2
    ./configure --prefix=/usr/local/mpfr-2.4.2 \
    --with-gmp=/usr/local/gmp-4.3.2 \
    && make -j $(nproc) && make install && cd -
    
    tar zxvfv mpc-1.0.1.tar.gz
    cd mpc-1.0.1
    ./configure --prefix=/usr/local/mpc-1.0.1 \
    --with-gmp=/usr/local/gmp-4.3.2 --with-mpfr=/usr/local/mpfr-2.4.2 \
    && make -j $(nproc) && make install && cd -
    
> 配置环境变量

    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/gmp-4.3.2/lib:/usr/local/mpc-1.0.1/lib:/usr/local/mpfr-2.4.2/lib" >> /etc/profile
    . /etc/profile
    
> 编译gcc

    tar -xzvf gcc-5.4.0.tar.gz && mkdir gcc-5.4.0/gcc-build && cd gcc-5.4.0/gcc-build \
    && ../configure --prefix=/usr/local/gcc-5.4.0 --enable-threads=posix \
    --disable-checking --disable-multilib --enable-languages=c,c++ \
    --with-gmp=/usr/local/gmp-4.3.2 --with-mpfr=/usr/local/mpfr-2.4.2 \
    --with-mpc=/usr/local/mpc-1.0.1 && make -j $(nproc) && make install && cd -
    
> 备份更新

    mkdir -p /usr/local/bakup/gcc
    mv /usr/bin/{gcc,g++} /usr/local/bakup/gcc/
    cp /usr/local/gcc-5.4.0/bin/gcc /usr/bin/gcc
    cp /usr/local/gcc-5.4.0/bin/g++ /usr/bin/g++

## openssl

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
    
## openssh

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
    UsePAM yes
    UseDNS no
    AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
    AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
    AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
    AcceptEnv XMODIFIERS
    AllowTcpForwarding yes
    X11Forwarding yes
    Subsystem sftp /usr/libexec/openssh/sftp-server
    EOF
    
调整`service`,重启`ssh`服务

    sed -i "s;Type=notify;#Type=notify;g" /usr/lib/systemd/system/sshd.service
    systemctl daemon-reload && systemctl restart sshd


成功后关闭`telnet`

    systemctl disable telnet.socket --now
    systemctl disable xinetd --now

