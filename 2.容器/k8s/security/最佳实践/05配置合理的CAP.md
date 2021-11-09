# 配置合理的CAP

## 漏洞解析

扫描样例：

```
[control: Linux hardening] failed 😥
Description: Often, containers are given more privileges than actually needed. This behavior can increase the impact of a container compromise.
   Namespace security
      Deployment - nginx
Summary - Passed:0   Warning:0   Failed:1   Total:1
Remediation: Make sure you define  at least one linux security hardening property out of AppArmor, Seccomp, SELinux or Capabilities.
```

描述: 

如果程序以特权身份运行，应尽量降低其权限。因为很多默认权限/能力程序本身并不需要，其存在可能被攻击者利用。

## 加固方案

建议`DROP`掉所有`CAP`: 基于容器的`securityContext.capabilities`字段配置
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-server
spec:
  containers:
    - name: api-server
      image: xzxwl/api-server-demo:latest
      securityContext:
        capabilities:
          drop:
            - ALL
          add:
            - CHOWN
```

按需添加

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-server
spec:
  containers:
    - name: api-server
      image: xzxwl/api-server-demo:latest
      securityContext:
        capabilities:
          drop:
            - ALL
          add:
            - CHOWN
```

关于`CAP`部分解析请参考：

- [cap_chown解析](../容器CAP解析/01cap_chown解析.md)
- [cap_dac_override解析](../容器CAP解析/02cap_dac_override解析.md)
- [cap_fowner解析](../容器CAP解析/03cap_fowner解析.md)
- [cap_fsetid解析](../容器CAP解析/04cap_fsetid解析.md)
- [cap_kill解析](../容器CAP解析/05cap_kill解析.md)
- [cap_setgid解析](../容器CAP解析/06cap_setgid解析.md)
- [cap_setuid解析](../容器CAP解析/07cap_setuid解析.md)
- [cap_net_bind_service解析](../容器CAP解析/09cap_net_bind_service解析.md)
- [cap_sys_chroot解析](../容器CAP解析/11cap_sys_chroot解析.md)
- [cap_mknod解析](../容器CAP解析/12cap_mknod解析.md)
- [cap_audit_write解析](../容器CAP解析/13cap_audit_write解析.md)