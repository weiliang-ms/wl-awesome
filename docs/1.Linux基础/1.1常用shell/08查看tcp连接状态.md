### 查看tcp连接状态

```shell
netstat -na|awk '/^tcp/ {++S[$NF]} END {for(i in S) print i,S[i]}'
```