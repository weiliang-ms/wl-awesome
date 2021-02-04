- [软件升级](#%E8%BD%AF%E4%BB%B6%E5%8D%87%E7%BA%A7)
  - [升级kernel](#%E5%8D%87%E7%BA%A7kernel)
    - [el7在线升级稳定版内核](#el7%E5%9C%A8%E7%BA%BF%E5%8D%87%E7%BA%A7%E7%A8%B3%E5%AE%9A%E7%89%88%E5%86%85%E6%A0%B8)
    - [el7在线升级主线版内核](#el7%E5%9C%A8%E7%BA%BF%E5%8D%87%E7%BA%A7%E4%B8%BB%E7%BA%BF%E7%89%88%E5%86%85%E6%A0%B8)
  - [gcc](#gcc)
  - [openssl](#openssl)
  - [openssh](#openssh)

# 软件升级
更新升级如`kernel`、`openssl`、`openssh`等

## 升级kernel
### el7在线升级稳定版内核

导入public key,添加扩展源

    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    yum install https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm -y
    

安装最新稳定版

    yum -y --enablerepo=elrepo-kernel install kernel-lt.x86_64 kernel-lt-devel.x86_64
    
删除旧版本工具包

    yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64 -y
    
安装新版本工具包

    yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-lt-tools.x86_64
   
    
查看内核列表

    awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
    
重建内核

    grub2-mkconfig -o /boot/grub2/grub.cfg

配置新版内核

    grub2-set-default 0

重启

    reboot
    
删除旧版本内核

    oldkernel=`rpm -qa|grep kernel-[0-9]` && yum remove -y $oldkernel

### el7在线升级主线版内核

**针对4.x识别不了raid卡磁盘**

导入public key,添加扩展源

    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    yum install https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm -y
    

安装最新主线版

    yum -y --enablerepo=elrepo-kernel install kernel-ml.x86_64 kernel-ml-devel.x86_64
    
删除旧版本工具包

     rpm -qa|grep kernel-3|xargs -n1 rpm -e
     rpm -e  kernel-tools-libs-*
     
安装新版本工具包

    yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml-tools.x86_64
   
查看内核列表

    awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
    
重建内核

    grub2-mkconfig -o /boot/grub2/grub.cfg

配置新版内核

    grub2-set-default 0

系统盘非raid模式直接重启

    reboot
    
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

重启ssh服务

    service sshd restart

至此openssh升级完毕！

成功后关闭telnet

    systemctl disable telnet.socket --now
    systemctl disable xinetd --now

