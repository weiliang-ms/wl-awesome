<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [binlog](#binlog)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## binlog

> 查看binlog保存天数

默认值为0，即永久保存

```sql
show variables like 'expire_logs_days';
```

> 配置binlog失效时间

```sql
set global expire_logs_days=7;
```

> 清理binlog

```sql
flush logs;
```

> 清除指定时间的binlog

```sql
purge binary logs before '2017-05-01 13:09:51';
```