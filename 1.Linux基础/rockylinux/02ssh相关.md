### 开启root远程访问

**不建议**

当`rocky linux`默认安装完毕后，无法通过ssh进行root远程登录

如需开启root远程登录，变更以下配置：

```shell
$ sed -i "s;#PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
$ systemctl restart sshd
```

