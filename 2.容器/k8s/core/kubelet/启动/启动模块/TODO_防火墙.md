## iptables

### 基础概念

本文讨论内容需具备一定`iptables`基础：

[iptables详解（1）：iptables概念](https://www.zsythink.net/archives/1199)

[iptables详解（12）：iptables动作总结之一](https://www.zsythink.net/archives/1684)

[iptables详解（13）：iptables动作总结之二](https://www.zsythink.net/archives/1764)

### 常用指令

> 查询链是否存在

```shell
$ iptables -t nat -L <chain-name>
```
