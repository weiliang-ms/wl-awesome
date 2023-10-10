```shell
ps aux | awk '/yum/{system("kill-9"$2)}'
#清除rpm库文件
rm -f /var/lib/rpm/__db*
#重新构建
rpm --rebuilddb
#清除yum缓存
yum clean all && rm -rf /var/cache/yum
#重新缓存
yum makecache
```