## 为Pods配置卷权限和所有权更改策略

[Configure volume permission and ownership change policy for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods)

特性状态: `Kubernetes v1.20 [beta]`

默认情况下，`Kubernetes`递归地更改每个卷内容的所有权和权限，以匹配当挂载该卷时`Pod`的`securityContext`中指定的`fsGroup`。
对于大量数据，检查和更改所有权和权限会花费大量时间，从而减慢`Pod`的启动。

您可以使用`securityContext`中的`fsGroupChangePolicy`字段来控制`Kubernetes`检查和管理卷的所有权和权限的方式。

> fsGroupChangePolicy解析

`fsGroupChangePolicy`定义了在将卷暴漏给`Pod`之前更改卷的所有权和权限的行为。
此字段仅适用于支持`fsGroup`控制的所有权和权限的卷类型。该字段有两个可能的值:

- `OnRootMismatch`: 如果根目录的权限和所有权与卷的预期权限不匹配，将更改权限和所有权。这可以帮助缩短更改卷的所有权和许可所需的时间。
- `Always`: 总是在挂载卷时更改卷的权限和所有权

> 样例

```bash
securityContext:
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
  fsGroupChangePolicy: "OnRootMismatch"
```

**注意:** 该字段对临时卷类型(如secret、configMap和emptydir)没有影响。

