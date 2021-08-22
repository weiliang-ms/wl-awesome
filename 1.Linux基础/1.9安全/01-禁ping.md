### 禁ping

```shell
echo "net.ipv4.icmp_echo_ignore_all=1"  >> /etc/sysctl.conf
sysctl -p
```