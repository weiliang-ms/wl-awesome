<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [常用命令](#%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 常用命令

查看tcp连接状态

```bash
netstat -na|awk '/^tcp/ {++S[$NF]} END {for(i in S) print i,S[i]}'
```

> 安装监控工具

    yum -y install sysstat net-tools
    
> 
    
