## 卷挂载时避免使用subPath

### 漏洞样例

```
[control: CVE-2021-25741 - Using symlink for arbitrary host file system access.] failed 😥
Description: A user may be able to create a container with subPath volume mounts to access files & directories outside of the volume, including on the host filesystem. This was affected at the following versions: v1.22.0 - v1.22.1, v1.21.0 - v1.21.4, v1.20.0 - v1.20.10, version v1.19.14 and lower.
      Node - node1
   Namespace champ
      Deployment - bcp-console
Summary - Passed:35   Warning:0   Failed:1   Total:36
Remediation: To mitigate this vulnerability without upgrading kubelet, you can disable the VolumeSubpath feature gate on kubelet and kube-apiserver, and remove any existing Pods making use of the feature.
```

### 漏洞描述

用户可以创建一个带有`subPath`卷挂载的容器来访问卷之外的文件和目录，包括主机文件系统上的文件和目录。

这在以下版本受到影响:`v1.22.0` - `v1.22.1`, `v1.21.0` - `v1.21.4`, `v1.20.0` - `v1.20.10`，版本`v1.19.14`及更低的版本。


### 漏洞修复

> 样例配置:

- `Deployment`（只截取了关键部分内容）:

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: bcp-console
  namespace: champ
  labels:
    app: bcp-console
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bcp-console
  template:
    spec:
      volumes:
        - name: bcp-console-cm-volume
          configMap:
            name: bcp-console-cm
            defaultMode: 420
      containers:
        - name: bcp-console
          image: 'xxx.xxx.xxx/xxx/xxx:xxxx'
          volumeMounts:
            - name: bcp-console-cm-volume
              readOnly: true
              mountPath: /opt/application.yml
              subPath: application.yml
```

- `ConfigMap/bcp-console-cm`（部分内容脱敏已删除）:

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: bcp-console-cm
  namespace: champ
  labels:
    app: bcp-console-cm
    app.kubernetes.io/instance: bcp-console
data:
  application.yml: |-
    spring:
        profiles:
            active: paas
```

1. 变更`Deployment`挂载配置方式:

由

```yaml
  volumes:
    - name: bcp-console-cm-volume
      configMap:
        name: bcp-console-cm
        defaultMode: 420
  containers:
    - name: bcp-console
      image: 'xxx.xxx.xxx/xxx/xxx:xxxx'
      volumeMounts:
        - name: bcp-console-cm-volume
          readOnly: true
          mountPath: /opt/application.yml
          subPath: application.yml
```

改为

```yaml
  volumes:
    - name: bcp-console-cm-volume
      configMap:
        name: bcp-console-cm
        defaultMode: 420
  containers:
    - name: bcp-console
      image: 'xxx.xxx.xxx/xxx/xxx:xxxx'
      volumeMounts:
        - name: bcp-console-cm-volume
          readOnly: true
          mountPath: /opt
```

**注意：** 当`ConfigMap`只存在一对`key value`时，`key`可以设置为文件名称（如: `application.yml`），`value`设置为文件内容。
此时执行挂载时，只需指定挂载路径（如`mountPath: /opt`），