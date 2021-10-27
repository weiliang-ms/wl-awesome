## k8s安全上下文概述

安全上下文(`security context`)定义`Pod`或容器的特权和访问控制设置。安全上下文设置包括但不限于:

- 自由访问控制: 基于`UID、GID`文件/目录访问权限控制
- 安全增强的`Linux` (`SELinux`): 给对象分配安全标签
- 以特权或非特权的方式运行
- `Linux Capabilities`: 赋予进程一些特权，而不是根用户的所有特权
- `AppArmor`: 使用程序配置文件来限制单个程序的权限
- `Seccomp`: 过滤程序系统调用
- `AllowPrivilegeEscalation`(允许提权): 控制进程是否可以获得比其父进程更多的特权。该`bool`值直接控制是否在容器进程上设置`no_new_privs`标志。
`AllowPrivilegeEscalation`总是在容器以特权身份运行或具有`CAP_SYS_ADMIN`时为真
- 只读根文件系统: 将容器的根文件系统挂载为只读

完整的安全上下文配置参考[SecurityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#securitycontext-v1-core)

关于`Linux`中的安全机制的更多信息，参考[overview-linux-kernel-security-features](https://www.linux.com/training-tutorials/overview-linux-kernel-security-features/)