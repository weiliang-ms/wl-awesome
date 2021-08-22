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