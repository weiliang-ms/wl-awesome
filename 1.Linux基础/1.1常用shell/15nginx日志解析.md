1. 提取nginx访问前x的IP地址

第一个`sort`进行ip地址排序，`sort -nr`对数量排序

```shell
$ cat /var/log/nginx/access.log|awk '{print $1}'|sort|uniq -c|sort -nr
    396 10.30.2.169
     67 192.168.129.64
     34 192.168.129.176
      6 10.9.48.129
```

2. 提取nginx日志中状态码数量

```shell
$ cat /var/log/nginx/access.log|awk '{print $9}'|sort|uniq -c|sort -rn
    529 200
      6 302
      5 401
      4 502
      4 400
      4 304
      2 499
      1 201
      1 101
```