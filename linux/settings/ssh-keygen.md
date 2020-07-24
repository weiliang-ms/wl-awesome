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