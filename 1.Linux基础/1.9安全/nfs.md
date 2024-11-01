## 修复nfs漏洞

描述：扫描主机可以安装远程服务器导出的至少一个NFS共享。 攻击者可能能够利用它来读取（并可能写入）远程主机上的文件。

1. server 端配置可挂载ip白名单

```shell
cat /etc/exports
/data/report      10.10.1.0/24(rw,no_root_squash,async)
```

2. server 配置Mount白名单

```shell
cat /etc/hosts.allow
mountd:10.10.1.3,10.10.4,10.10.5
```

```shell
cat /etc/hosts.deny
mountd:all
```

3. 重载（可能也不需要重载？）

```shell
systemctl restart sshd
```

4. 白名单机器验证

```shell
nmap --script nfs-showmount 10.10.1.1

Starting Nmap 6.40 ( http://nmap.org ) at 2024-07-05 09:19 CST
Nmap scan report for 10.10.1.1
Host is up (0.00020s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
111/tcp  open  rpcbind
| nfs-showmount:
|_  /data/report 10.10.1.0/24
2049/tcp open  nfs
8080/tcp open  http-proxy
MAC Address: 00:50:56:8C:9A:B5 (VMware)
```

5. 黑名单机器验证

```shell
$ nmap --script nfs-showmount 10.10.1.1

Starting Nmap 6.40 ( http://nmap.org ) at 2024-07-05 09:21 CST
Nmap scan report for 10.10.1.1
Host is up (0.00032s latency).
Not shown: 996 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
111/tcp  open  rpcbind
2049/tcp open  nfs
8080/tcp open  http-proxy

Nmap done: 1 IP address (1 host up) scanned in 31.74 seconds
```

