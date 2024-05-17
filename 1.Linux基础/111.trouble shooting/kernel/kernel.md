## 内核相关信息

### 查看内核日志中的调用栈

以易读格式显示日志事件
```shell
dmesg -T
```

滚动查看

```shell
dmesg -T|less
```

tail 查看
```shell
dmesg -T | tail -n 10
```
