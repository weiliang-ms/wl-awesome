# k8s运行runner

## 创建cephfs

用于挂载.m2、node缓存数据

1. 创建cephfs

```shell
$ ceph osd pool create devops_cephfs_data 8
$ ceph osd pool create devops_cephfs_metadata 8
$ ceph fs new k8s-cephfs devops_cephfs_metadata devops_cephfs_data
$ ceph osd pool application enable devops_cephfs_data cephfs
$ ceph osd pool set-quota devops_cephfs_data max_bytes 4T
```

## 获取Gitlab组

1. 获取Gitlab组的gitlab-runner token，用于后续注册

```
Wf-qTAsNjBBDZPDzsXwT
```

2. base64

```shell
$ echo "Wf-qTAsNjBBDZPDzsXwT" |  base64 -w0
V2YtcVRBc05qQkJEWlBEenNYd1QK
```

## 创建gitlab runner

1. 新建命名空间，命名空间需唯一。原则上以`devops-`起始（例devops-linyi）

```shell
$ kubectl create ns devops-demo
```

2. 创建密钥

```shell
$ cat <<EOF | kubectl -n devops-demo apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-ci-token
  labels:
    app: gitlab-ci-runner
data:
  GITLAB_CI_TOKEN: V2YtcVRBc05qQkJEWlBEenNYd1QK
EOF
```

3. 创建管理脚本

```shell
$ cat <<EOF | kubectl -n devops-demo apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: gitlab-ci-runner
  name: gitlab-ci-runner-scripts
data:
  run.sh: |
    #!/bin/bash
    unregister() {
        kill %1
        echo "Unregistering runner ${RUNNER_NAME} ..."
        /usr/bin/gitlab-ci-multi-runner unregister -t "$(/usr/bin/gitlab-ci-multi-runner list 2>&1 | tail -n1 | awk '{print $4}' | cut -d'=' -f2)" -n ${RUNNER_NAME}
        exit $?
    }
    trap 'unregister' EXIT HUP INT QUIT PIPE TERM
    echo "Registering runner ${RUNNER_NAME} ..."
    /usr/bin/gitlab-ci-multi-runner register -r ${GITLAB_CI_TOKEN}
    sed -i 's/^concurrent.*/concurrent = '"${RUNNER_REQUEST_CONCURRENCY}"'/' /home/gitlab-runner/.gitlab-runner/config.toml
    echo "Starting runner ${RUNNER_NAME} ..."
    /usr/bin/gitlab-ci-multi-runner run -n ${RUNNER_NAME} &
    wait
EOF
```

4. 创建配置文件

```shell
$ cat <<EOF | kubectl -n devops-demo apply -f -
apiVersion: v1
data:
  REGISTER_NON_INTERACTIVE: "true"
  REGISTER_LOCKED: "false"
  METRICS_SERVER: "0.0.0.0:9100"
  CI_SERVER_URL: "http://192.168.131.211:7777/"
  RUNNER_REQUEST_CONCURRENCY: "4"
  RUNNER_EXECUTOR: "kubernetes"
  KUBERNETES_NAMESPACE: "devops-demo"
  KUBERNETES_PRIVILEGED: "true"
  KUBERNETES_CPU_LIMIT: "1"
  KUBERNETES_CPU_REQUEST: "500m"
  KUBERNETES_MEMORY_LIMIT: "1Gi"
  KUBERNETES_SERVICE_CPU_LIMIT: "1"
  KUBERNETES_SERVICE_MEMORY_LIMIT: "1Gi"
  KUBERNETES_HELPER_CPU_LIMIT: "500m"
  KUBERNETES_HELPER_MEMORY_LIMIT: "100Mi"
  KUBERNETES_PULL_POLICY: "if-not-present"
  KUBERNETES_TERMINATIONGRACEPERIODSECONDS: "10"
  KUBERNETES_POLL_INTERVAL: "5"
  KUBERNETES_POLL_TIMEOUT: "360"
kind: ConfigMap
metadata:
  labels:
    app: gitlab-ci-runner
  name: gitlab-ci-runner-cm
EOF
```

5. 创建rbac

```shell
$ cat <<EOF | kubectl -n devops-demo apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-ci
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gitlab-ci
rules:
  - apiGroups: [""]
    resources: ["*"]
    verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gitlab-ci
subjects:
  - kind: ServiceAccount
    name: gitlab-ci
roleRef:
  kind: Role
  name: gitlab-ci
  apiGroup: rbac.authorization.k8s.io
EOF
```

6. 创建runner

```shell
$ cat <<EOF | kubectl -n devops-demo apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: gitlab-ci-runner
  labels:
    app: gitlab-ci-runner
spec:
  updateStrategy:
    type: RollingUpdate
  replicas: 1
  selector:
    matchLabels:
      app: gitlab-ci-runner
  serviceName: gitlab-ci-runner
  template:
    metadata:
      labels:
        app: gitlab-ci-runner
    spec:
      volumes:
      - name: gitlab-ci-runner-scripts
        projected:
          sources:
          - configMap:
              name: gitlab-ci-runner-scripts
              items:
              - key: run.sh
                path: run.sh
                mode: 0755
      serviceAccountName: gitlab-ci
      containers:
      - image: harbor.chs.neusoft.com/gitlab/gitlab-runner:alpine-v12.10.1
        name: gitlab-ci-runner
        command:
        - /scripts/run.sh
        envFrom:
        - configMapRef:
            name: gitlab-ci-runner-cm
        - secretRef:
            name: gitlab-ci-token
        env:
        - name: RUNNER_NAME
          value: k8s-runner
        ports:
        - containerPort: 9100
          name: http-metrics
          protocol: TCP
        volumeMounts:
        - name: gitlab-ci-runner-scripts
          mountPath: "/scripts"
          readOnly: true
      restartPolicy: Always
EOF
```