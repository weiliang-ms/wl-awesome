# 使用secret存放敏感凭据

> `Applications credentials in configuration files`扫描异常样例

```
[control: Applications credentials in configuration files] failed 😥
Description: Attackers who have access to configuration files can steal the stored secrets and use them. Checks if ConfigMaps or pods have sensitive information in configuration.
   Namespace champ
      Job - xxl-job-mysql-job
Summary - Passed:64   Warning:0   Failed:1   Total:65
Remediation: Use Kubernetes secrets to store credentials. Use ARMO secret protection solution to improve your security even more.
```

### 漏洞修复

修改前声明内容:

```yaml
kind: Job
apiVersion: batch/v1
metadata:
  name: xxl-job-mysql-job
  namespace: champ
  labels:
    app.kubernetes.io/managed-by: Helm
  annotations:
    meta.helm.sh/release-name: xxl-job-admin
    meta.helm.sh/release-namespace: champ
spec:
  parallelism: 1
  completions: 1
  activeDeadlineSeconds: 3000
  backoffLimit: 1
  selector:
    matchLabels:
      controller-uid: 6cca9ff1-731b-492c-b4ca-80c47779c6a7
  template:
    metadata:
      labels:
        app: xxl-job-mysql-job
        controller-uid: 6cca9ff1-731b-492c-b4ca-80c47779c6a7
        job-name: xxl-job-mysql-job
    spec:
      volumes:
        - name: volume-spnoig
          configMap:
            name: xxl-job-admin-mysql-sql-cm
            defaultMode: 420
      containers:
        - name: container-xcefoj
          image: 'mysql:5.7.31'
          command:
            - /bin/bash
            - '-c'
          args:
            - >-
              mysql -hmysql-champ.champ -uroot -P3306
              --default-character-set=utf8 < /home/mysql/xxl-job-mysql.sql
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "123456"
            - name: MYSQL_PWD
              value: "123456"
          resources: {}
          volumeMounts:
            - name: volume-spnoig
              readOnly: true
              mountPath: /home/mysql
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      restartPolicy: Never
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      securityContext: {}
      schedulerName: default-scheduler
```

1. 对密码进行`base64`编码

```bash
$ echo -n '123456' | base64
MTIzNDU2
```

2. 根据编码值创建`secret`对象

```bash
$ cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: xxljob-init-mysql-secret
  namespace: champ
data:
  mysql-password: MTIzNDU2
  mysql-root-password: MTIzNDU2
type: Opaque
EOF
```

3. 控制器对象引用

- 修改前

```yaml
...
  env:
    - name: MYSQL_ROOT_PASSWORD
      value: "123456"
    - name: MYSQL_PWD
      value: "123456"
```

- 修改后

```yaml
  env:
    - name: MYSQL_ROOT_PASSWORD
      valueFrom:
        secretKeyRef:
          name: xxljob-init-mysql-secret
          key: mysql-root-password
    - name: MYSQL_PWD
      valueFrom:
        secretKeyRef:
          name: xxljob-init-mysql-secret
          key: mysql-password
```

4. 重新`apply`生效