<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [连接](#%E8%BF%9E%E6%8E%A5)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 连接

> 查看当前连接数

```sql
show status like 'Threads%';
```

> 查看最大连接数

```sql
show variables like '%max_connections%';
```

> 查看显示连接状态

```sql
SHOW STATUS LIKE '%connect%';
```

> 查看当前所有连接

```sql
show full processlist;
```