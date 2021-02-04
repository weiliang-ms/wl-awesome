- [系统设置](#%E7%B3%BB%E7%BB%9F%E8%AE%BE%E7%BD%AE)
  - [关闭图形化](#%E5%85%B3%E9%97%AD%E5%9B%BE%E5%BD%A2%E5%8C%96)
  - [防火墙](#%E9%98%B2%E7%81%AB%E5%A2%99)
  - [ssh密钥登陆](#ssh%E5%AF%86%E9%92%A5%E7%99%BB%E9%99%86)
  - [配置时区](#%E9%85%8D%E7%BD%AE%E6%97%B6%E5%8C%BA)

# 系统设置
针对linux平台的设置

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

## 配置时区

el7

    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    
## 配置hostname

- 方法一


	cat >> /etc/sysconfig/network <<EOF
	HOSTNAME=oracle
	EOF
	
	echo oracle >/proc/sys/kernel/hostname

- 方法二


	cat >> /etc/sysconfig/network <<EOF
	HOSTNAME=oracle
	EOF
	
	sysctl kernel.hostname=oracle

- 方法三


	cat >> /etc/sysconfig/network <<EOF
	HOSTNAME=oracle
	EOF
	
	hostname oracle
	
- 方法四


    hostnamectl --static set-hostname master