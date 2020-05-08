## 允许某一IP访问本地端口

```bash
firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="192.168.239.133" port protocol="tcp" port="8099" accept"
firewall-cmd --reload
```