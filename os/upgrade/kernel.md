## 升级kernel
### el7在线升级稳定版内核

导入public key,添加扩展源

```go
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm -y
```
    

安装最新稳定版

```shell
yum -y --enablerepo=elrepo-kernel install kernel-lt.x86_64 kernel-lt-devel.x86_64
```
    
删除旧版本工具包

```shell
yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64 -y
```
    
安装新版本工具包

```shell
yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-lt-tools.x86_64
```
    
查看内核列表

```shell
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
```
    
重建内核

```shell
grub2-mkconfig -o /boot/grub2/grub.cfg
```

配置新版内核

```shell
sed -i "s/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g" /etc/default/grub
```

重启

```shell
reboot
```
    
删除旧版本内核

```shell
oldkernel=`rpm -qa|grep kernel-[0-9]` && yum remove -y $oldkernel
```

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