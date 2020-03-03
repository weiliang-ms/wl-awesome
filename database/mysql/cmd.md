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