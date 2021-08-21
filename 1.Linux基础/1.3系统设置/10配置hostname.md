### 配置hostname

- 方法一

```shell
cat >> /etc/sysconfig/network <<EOF
HOSTNAME=oracle
EOF
echo oracle >/proc/sys/kernel/hostname
```

- 方法二

```shell
cat >> /etc/sysconfig/network <<EOF
HOSTNAME=oracle
EOF
sysctl kernel.hostname=oracle
```

- 方法三

```shell
cat >> /etc/sysconfig/network <<EOF
HOSTNAME=oracle
EOF
hostname oracle
```

- 方法四

```shell
hostnamectl --static set-hostname master
```