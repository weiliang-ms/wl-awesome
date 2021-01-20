<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [关闭图形化](#%E5%85%B3%E9%97%AD%E5%9B%BE%E5%BD%A2%E5%8C%96)
- [防火墙](#%E9%98%B2%E7%81%AB%E5%A2%99)
- [ssh密钥登陆](#ssh%E5%AF%86%E9%92%A5%E7%99%BB%E9%99%86)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 关闭图形化

centos7

```bash
systemctl set-default multi-user.target
init 3
```

## 防火墙

> 允许某一IP访问本地端口

```bash
firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="192.168.239.133" port protocol="tcp" port="8099" accept"
firewall-cmd --reload
```

## ssh密钥登陆

建立密钥对，密码可选

```bash
ssh-keygen -t rsa
```

非交互生成密钥（无密码）

    ssh-keygen -t rsa -n '' -f ~/.ssh/id_rsa

安装公钥
```bash
cd ~/.ssh
cat id_rsa.pub >> authorized_keys
```

调整权限
```bash
chmod 600 authorized_keys
chmod 700 ~/.ssh
```

设置 SSH，打开密钥登录功能
```bash
echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
sed -i "s;#PubkeyAuthentication yes;PubkeyAuthentication yes;g" /etc/ssh/sshd_config
```

下载保存服务端私钥文件
```bash
/root/.ssh/id_rsa
```

重启服务测试密钥方式登录
```bash
service sshd restart
```

测试通过，关闭账号密码登录并重启ssh服务
```bash
sed -i "s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
service sshd restart
```