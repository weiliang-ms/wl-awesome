<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [el7在线升级稳定版内核](#el7%E5%9C%A8%E7%BA%BF%E5%8D%87%E7%BA%A7%E7%A8%B3%E5%AE%9A%E7%89%88%E5%86%85%E6%A0%B8)
- [el7在线升级主线版内核](#el7%E5%9C%A8%E7%BA%BF%E5%8D%87%E7%BA%A7%E4%B8%BB%E7%BA%BF%E7%89%88%E5%86%85%E6%A0%B8)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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
     rpm -qa|grep kernel-tools|xargs -n1 rpm -e
     
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

    


    

