### el7在线升级内核

导入public key,添加扩展源

    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    yum install https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm -y
    

安装最新稳定版

    yum -y --enablerepo=elrepo-kernel install kernel-lt.x86_64 kernel-lt-devel.x86_64
    
删除旧版本工具包

    yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64 -y
    
安装新版本工具包

    yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-lt-tools.x86_64
    
配置新版内核

    grub2-set-default 0
    
重启

    reboot
    
删除旧版本内核

    oldkernel=`rpm -qa|grep kernel-[0-9]` && yum remove -y $oldkernel

    

