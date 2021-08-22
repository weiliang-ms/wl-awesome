## 禁止Control-Alt-Delete 键盘重启系统命令

```shell
rm -rf /usr/lib/systemd/system/ctrl-alt-del.target
```