> 清除nat规则

```shell
iptables -t nat -F
```

> 查看nat规则

```shell
iptables -t nat -nvL
```