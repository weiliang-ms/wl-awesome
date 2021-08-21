### 配置`sudo`用户

[强密码生成](https://tool.ip138.com/random/)

或利用以下指令生成

```shell
pwmake 128
```

初始化用户，配置sudo权限

```shell
useradd -m neusoft && echo "m&t+arz4SEvWq5)QG" | passwd --stdin neusoft
echo "neusoft        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
```
