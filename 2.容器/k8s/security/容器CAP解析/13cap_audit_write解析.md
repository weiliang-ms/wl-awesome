## cap_audit_write解析

- `cap_audit_write`: 允许将记录写入内核审计日志的权限

> 首先我们需要了解：内核审计日志用来记录什么？

主要用来记录什么时间，哪个用户，执行了哪个程序，操作了哪个文件，成功与否。
例如执行过`su`命令，`/tmp``目录是否被写入过

文件路径为：`/var/log/audit/audit.log`

让我们看下文件内容格式：

```shell
$ cat /var/log/audit/audit.log
...
type=CRED_REFR msg=audit(1636423606.888:8019): pid=258705 uid=0 auid=1001 ses=570 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_env,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/0 res=success'
type=USER_START msg=audit(1636423606.895:8020): pid=258705 uid=0 auid=1001 ses=570 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/0 res=success'
type=USER_AUTH msg=audit(1636423606.902:8021): pid=258707 uid=0 auid=1001 ses=570 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:authentication grantors=pam_rootok acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/0 res=success'
type=USER_ACCT msg=audit(1636423606.902:8022): pid=258707 uid=0 auid=1001 ses=570 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:accounting grantors=pam_succeed_if acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/0 res=success'
type=CRED_ACQ msg=audit(1636423606.903:8023): pid=258707 uid=0 auid=1001 ses=570 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_rootok acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/0 res=success'
type=USER_START msg=audit(1636423606.904:8024): pid=258707 uid=0 auid=1001 ses=570 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix,pam_xauth acct="root" exe="/usr/bin/su" hostname=localhost.localdomain addr=? terminal=pts/0 res=success'
...
```

默认记录用户登录相关的信息，我们接下来添加一条规则：

添加记录删除文件规则
```shell
$ echo "-w /bin/rm -p x -k removefile" >> /etc/audit/rules.d/audit.rules
```

重启服务

```shell
$ service auditd restart
```

查看规则

```shell
$ auditctl -l
-w /bin/rm -p x -k removefile
```

再次查看审计日志:

```shell
$ cat /var/log/audit/audit.log | tail -5
type=EXECVE msg=audit(1636424696.310:8047): argc=4 a0="rm" a1="-i" a2="-f" a3="/tmp/ddd"type=CWD msg=audit(1636424696.310:8047):  cwd="/root"
type=PATH msg=audit(1636424696.310:8047): item=0 name="/bin/rm" inode=1610620608 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL
type=PATH msg=audit(1636424696.310:8047): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=32646 dev=fd:00 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL
type=PROCTITLE msg=audit(1636424696.310:8047): proctitle=726D002D69002D66002F746D702F646464
```

格式不太友好，我们换成方式查看:

```shell
$ ausearch -i|tail -5
type=PATH msg=audit(11/08/2021 21:24:56.310:8047) : item=1 name=/lib64/ld-linux-x86-64.so.2 inode=32646 dev=fd:00 mode=file,755 ouid=root ogid=root rdev=00:00 obj=system_u:object_r:ld_so_t:s0 objtype=NORMAL
type=PATH msg=audit(11/08/2021 21:24:56.310:8047) : item=0 name=/bin/rm inode=1610620608 dev=fd:00 mode=file,755 ouid=root ogid=root rdev=00:00 obj=system_u:object_r:bin_t:s0 objtype=NORMAL
type=CWD msg=audit(11/08/2021 21:24:56.310:8047) :  cwd=/root
type=EXECVE msg=audit(11/08/2021 21:24:56.310:8047) : argc=4 a0=rm a1=-i a2=-f a3=/tmp/ddd
type=SYSCALL msg=audit(11/08/2021 21:24:56.310:8047) : arch=x86_64 syscall=execve success=yes exit=0 a0=0x1ffaba0 a1=0x1ffda20 a2=0x2000100 a3=0x7fffa0fcbfa0 items=2 ppid=258708 pid=258816 auid=neusoft uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=pts0 ses=570 comm=rm exe=/usr/bin/rm subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key=removefile
```

我们发现删除的操作已被记录，更多的审计规则请移步[sec-defining_audit_rules_and_controls](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/sec-defining_audit_rules_and_controls)
这里不做过多讨论

针对`cap_audit_write`应用场景，暂时没有找到合适的例子，后续待补充。