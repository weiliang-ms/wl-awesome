# iptables

## 基础概念

本文讨论内容需具备一定`iptables`基础：

[iptables详解（1）：iptables概念](https://www.zsythink.net/archives/1199)

[iptables详解（12）：iptables动作总结之一](https://www.zsythink.net/archives/1684)

[iptables详解（13）：iptables动作总结之二](https://www.zsythink.net/archives/1764)

### 常用指令

> 查询链是否存在

```shell
$ iptables -t nat -L <chain-name>
```

## 模块解析

该模块需指定`--make-iptables-util-chains=true`开启，默认开启。

```go
func (kl *Kubelet) Run(updates <-chan kubetypes.PodUpdate) {
...
    if kl.makeIPTablesUtilChains {
        kl.initNetworkUtil()
    }
...
}
```

内部逻辑非常简单：初始化`kubernetes`定义的`iptables`链、规则。
并周期性（每分钟）对这些`iptables`链、规则检查变更，

```go
func (kl *Kubelet) initNetworkUtil() {

	kl.syncNetworkUtil()
	go kl.iptClient.Monitor(utiliptables.Chain("KUBE-KUBELET-CANARY"),
		[]utiliptables.Table{utiliptables.TableMangle, utiliptables.TableNAT, utiliptables.TableFilter},
		kl.syncNetworkUtil, 1*time.Minute, wait.NeverStop)
}
```

### iptables配置初始化

> 确认防火墙链是否存在

确认链是否存在，确认方式为执行创建命令:

```shell
$ iptables -N <链名称> -t <表名> <args>
```

创建成功返回`true`，若链已存在也返回`true`

```go
func (runner *runner) EnsureChain(table Table, chain Chain) (bool, error) {
	fullArgs := makeFullArgs(table, chain)

	runner.mu.Lock()
	defer runner.mu.Unlock()

	/* $ iptables -t nat -N KUBE-KUBELET-CANARY
	   iptables: Chain already exists.
	*/
	out, err := runner.run(opCreateChain, fullArgs)
	if err != nil {
		if ee, ok := err.(utilexec.ExitError); ok {
			if ee.Exited() && ee.ExitStatus() == 1 {
				return true, nil
			}
		}
		return false, fmt.Errorf("error creating chain %q: %v: %s", chain, err, out)
	}
	return false, nil
}
```

创建的链如下：

- `nat/KUBE-MARK-DROP`: 对于未能匹配到跳转规则的`traffic set mark 0x8000`，有此标记的数据包会在`filter`表`drop`掉
- `nat/KUBE-MARK-MASQ`: 对于符合条件的包`set mark 0x4000`, 有此标记的数据包会在`KUBE-POSTROUTING chain`中统一做`MASQUERADE`（动态`SNAT`）
- `nat/KUBE-POSTROUTING`: 该链对打上了`0x4000`标记的报文进行`SNAT`转换
- `filter/KUBE-FIREWALL`: 该链对所有标记了`0x8000`的报文进行丢弃

> 规则的创建

确认防火墙规则，检测未存在进行创建：

```shell
$ iptables -C 
```

具体路由方式由`kube-proxy`管理，这里不作过深讨论。

## 参考文献

[浅谈 kubernetes service 那些事](https://zhuanlan.zhihu.com/p/39909011)


