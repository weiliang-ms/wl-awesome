## ntp

```shell
yum -y install ntpdate
/usr/sbin/ntpdate ntp1.aliyun.com
echo "*/5 * * * * /usr/sbin/ntpdate ntp1.aliyun.com" >> /etc/crontab
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```