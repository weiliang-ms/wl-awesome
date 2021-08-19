- [安全加固](#%E5%AE%89%E5%85%A8%E5%8A%A0%E5%9B%BA)
  - [漏洞扫描](#%E6%BC%8F%E6%B4%9E%E6%89%AB%E6%8F%8F)
  - [禁`ping`](#%E7%A6%81ping)
  - [关闭`ICMP_TIMESTAMP`应答](#%E5%85%B3%E9%97%ADicmp_timestamp%E5%BA%94%E7%AD%94)
  - [锁定系统关键文件](#%E9%94%81%E5%AE%9A%E7%B3%BB%E7%BB%9F%E5%85%B3%E9%94%AE%E6%96%87%E4%BB%B6)
  - [ssh加固](#ssh%E5%8A%A0%E5%9B%BA)
    - [限制`root`用户直接登录](#%E9%99%90%E5%88%B6root%E7%94%A8%E6%88%B7%E7%9B%B4%E6%8E%A5%E7%99%BB%E5%BD%95)
    - [修改允许密码错误次数](#%E4%BF%AE%E6%94%B9%E5%85%81%E8%AE%B8%E5%AF%86%E7%A0%81%E9%94%99%E8%AF%AF%E6%AC%A1%E6%95%B0)
    - [关闭`AgentForwarding`和`TcpForwarding`](#%E5%85%B3%E9%97%ADagentforwarding%E5%92%8Ctcpforwarding)
    - [关闭`UseDNS`](#%E5%85%B3%E9%97%ADusedns)
  - [升级`sudo`版本](#%E5%8D%87%E7%BA%A7sudo%E7%89%88%E6%9C%AC)
  - [设置会话超时（5分钟）](#%E8%AE%BE%E7%BD%AE%E4%BC%9A%E8%AF%9D%E8%B6%85%E6%97%B65%E5%88%86%E9%92%9F)
  - [隐藏系统版本信息](#%E9%9A%90%E8%97%8F%E7%B3%BB%E7%BB%9F%E7%89%88%E6%9C%AC%E4%BF%A1%E6%81%AF)
  - [禁止Control-Alt-Delete 键盘重启系统命令](#%E7%A6%81%E6%AD%A2control-alt-delete-%E9%94%AE%E7%9B%98%E9%87%8D%E5%90%AF%E7%B3%BB%E7%BB%9F%E5%91%BD%E4%BB%A4)
  - [密码加固](#%E5%AF%86%E7%A0%81%E5%8A%A0%E5%9B%BA)
  
# 安全加固

## 漏洞扫描

- [nessus下载地址](https://www.tenable.com/products/nessus/select-your-operating-system)
- [nessus注册地址](https://www.tenable.com/products/nessus-home)

## 禁`ping`

```shell
echo "net.ipv4.icmp_echo_ignore_all=1"  >> /etc/sysctl.conf
sysctl -p
```

## 关闭`ICMP_TIMESTAMP`应答

```shell
iptables -I INPUT -p ICMP --icmp-type timestamp-request -m comment --comment "deny ICMP timestamp" -j DROP
iptables -I INPUT -p ICMP --icmp-type timestamp-reply -m comment --comment "deny ICMP timestamp" -j DROP
```

## 锁定系统关键文件

防止被篡改

```shell
chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/inittab
```

## ssh加固
### 限制`root`用户直接登录

```shell
sed -i "s#PermitRootLogin yes#PermitRootLogin no#g" /etc/ssh/sshd_config
systemctl restart sshd
```

### 修改允许密码错误次数

```shell
sed -i "/MaxAuthTries/d" /etc/ssh/sshd_config
echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
systemctl restart sshd
```

### 关闭`AgentForwarding`和`TcpForwarding`

```shell
sed -i "/AgentForwarding/d" /etc/ssh/sshd_config
sed -i "/TcpForwarding/d" /etc/ssh/sshd_config
echo "AllowAgentForwarding no" >> /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
systemctl restart sshd
```

### 关闭`UseDNS`

```shell
sed -i "/UseDNS/d" /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config
systemctl restart sshd
```

## 升级`sudo`版本

`CVE-2021-3156`等

- [sudo-1.9.7-3.el7.x86_64.rpm](https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_7p2/sudo-1.9.7-3.el7.x86_64.rpm)

```shell
rpm -Uvh sudo-1.9.7-3.el7.x86_64.rpm
```

验证

```shell
sudo -V
```

## 设置会话超时（5分钟）

```shell
echo "export TMOUT=300" >>/etc/profile
. /etc/profile
```

## 隐藏系统版本信息

```shell
mv /etc/issue /etc/issue.bak 
mv /etc/issue.net /etc/issue.net.bak
```

## 禁止Control-Alt-Delete 键盘重启系统命令

```shell
rm -rf /usr/lib/systemd/system/ctrl-alt-del.target
```

## 密码加固

```shell
PASS_MAX_DAYS=`grep -e ^PASS_MAX_DAYS /etc/login.defs |awk '{print $2}'`
if [ $PASS_MAX_DAYS -gt 90 ];then
    echo "密码最长保留期限为：$PASS_MAX_DAYS, 更改为90天"
    sed -i "/^PASS_MAX_DAYS/d" /etc/login.defs
    echo "PASS_MAX_DAYS   90" >> /etc/login.defs
fi

PASS_MIN_DAYS=`grep -e ^PASS_MIN_DAYS /etc/login.defs |awk '{print $2}'`
if [ $PASS_MIN_DAYS -ne 1 ];then
    echo "密码最段保留期限为：$PASS_MIN_DAYS, 更改为1天"
    sed -i "/^PASS_MIN_DAYS/d" /etc/login.defs
    echo "PASS_MIN_DAYS   1" >> /etc/login.defs
fi

PASS_MIN_LEN=`grep -e ^PASS_MIN_LEN /etc/login.defs |awk '{print $2}'`
if [ $PASS_MIN_LEN -lt 8 ];then
    echo "密码最少字符为：$PASS_MIN_LEN, 更改为8"
    sed -i "/^PASS_MIN_LEN/d" /etc/login.defs
    echo "PASS_MIN_LEN   8" >> /etc/login.defs
fi
 
PASS_WARN_AGE=`grep -e ^PASS_WARN_AGE /etc/login.defs |awk '{print $2}'`
if [ $PASS_WARN_AGE -ne 7 ];then
  echo "密码到期前$PASS_MIN_LEN天提醒, 更改为7"
  sed -i "/^PASS_WARN_AGE/d" /etc/login.defs
  echo "PASS_WARN_AGE   7" >> /etc/login.defs
fi
```



    