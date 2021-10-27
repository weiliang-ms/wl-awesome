### 计算shell运行时间

> 用`date`相减

```bash
startTime=`date +%Y%m%d-%H:%M:%S`
startTime_s=`date +%s`

endTime=`date +%Y%m%d-%H:%M:%S`
endTime_s=`date +%s`

sumTime=$[ $endTime_s - $startTime_s ]

echo "$startTime ---> $endTime" "Total:$sumTime seconds"
```

> `time`

```bash
time sh xxx.sh
# 会返回3个时间数据
# real 该命令的总耗时, 包括user和sys及io等待, 时间片切换等待等等
# user 该命令在用户模式下的CPU耗时,也就是内核外的CPU耗时,不含IO等待这些时间
# sys  该命令在内核中的CPU耗时,不含IO,时间片切换耗时.
```

