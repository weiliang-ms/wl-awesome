## 常用命令

查看tcp连接状态

```bash
netstat -na|awk '/^tcp/ {++S[$NF]} END {for(i in S) print i,S[i]}'
```

> 安装监控工具

    yum -y install sysstat net-tools
    
> 
    
