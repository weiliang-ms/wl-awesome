# 配置chrony

```shell
$ yum install -y chrony
```

```shell
$ cat > /etc/chrony.conf <<EOF
server 127.0.0.1 iburst
local stratum 10
EOF
```

启动
```shell
$ systemctl enable chronyd --now
```

手动同步

```shell
timedatectl set-ntp true
```