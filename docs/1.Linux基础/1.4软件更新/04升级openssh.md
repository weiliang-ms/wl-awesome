### 升级openssh

> 1.下载openssh包

[下载站点](https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/)

> 2.开启telnet(防止失败)

```shell script
yum install -y telnet-server telnet xinetd 

systemctl restart telnet.socket
systemctl restart xinetd

echo 'pts/0' >>/etc/securetty
echo 'pts/1' >>/etc/securetty
systemctl restart telnet.socket
```

> 3.安装

备份旧`ssh`配置文件

```shell
mv /etc/ssh/ /etc/ssh-bak
```

编译安装

```shell
yum install -y pam-devel zlib-devel
tar zxvf openssh-*.tar.gz
cd openssh*
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/openssl --with-md5-passwords
make -j $(nproc) && make install
```


复制启动脚本：

```shell
\cp contrib/redhat/sshd.init /etc/init.d/sshd
\chkconfig sshd on
```

验证版本信息：

```shell
ssh -V
```

配置

```shell script
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
```

调整`service`,重启`ssh`服务

```shell script
sed -i "s;Type=notify;#Type=notify;g" /usr/lib/systemd/system/sshd.service
systemctl daemon-reload && systemctl restart sshd
```

成功后关闭`telnet`

```shell script
systemctl disable telnet.socket --now
systemctl disable xinetd --now
```