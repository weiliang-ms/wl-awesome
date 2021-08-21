### 配置`yum`本地源

```shell
rm -rf /etc/yum.repos.d/*
mount -o loop CentOS-7-x86_64-DVD-2009.iso /media
mkdir -p /yum
cp -r /media/* /yum
umount /media
rm -f CentOS-7-x86_64-DVD-2009.iso
```

配置文件

```shell
cat > /etc/yum.repos.d/c7.repo <<EOF
[c7repo]
name=c7repo
baseurl=file:///yum
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
```