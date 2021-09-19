## 关闭`ICMP_TIMESTAMP`应答

```shell
iptables -I INPUT -p ICMP --icmp-type timestamp-request -m comment --comment "deny ICMP timestamp" -j DROP
iptables -I INPUT -p ICMP --icmp-type timestamp-reply -m comment --comment "deny ICMP timestamp" -j DROP
```