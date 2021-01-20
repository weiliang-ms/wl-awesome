<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [redis k8s集群](#redis-k8s%E9%9B%86%E7%BE%A4)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### redis k8s集群

nfs server IP

    192.168.1.1
    
nfs server配置

    /data/nfs/redis *(rw,sync,no_root_squas)

创建角色

    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: redis-provisioner-runner
    rules:
    - apiGroups: [""]
      resources: ["persistentvolumes"]
      verbs: ["get", "list", "watch", "create", "delete"]
    - apiGroups: [""]
      resources: ["persistentvolumeclaims"]
      verbs: ["get", "list", "watch", "update"]
    - apiGroups: [""]
      resources: ["endpoints"]
      verbs: ["get", "list", "watch", "create", "update", "patch"]
    - apiGroups: ["storage.k8s.io"]
      resources: ["storageclasses"]
      verbs: ["get", "list", "watch"]
    - apiGroups: [""]
      resources: ["events"]
      verbs: ["create", "update", "patch"]
    ---
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: redis-provisioner
    subjects:
    - kind: ServiceAccount
      name: redis-provisioner
      namespace: default
    roleRef:
      kind: ClusterRole
      name: redis-provisioner-runner
      apiGroup: rbac.authorization.k8s.io
    ---
    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: redis-provisioner
    rules:
    - apiGroups: [""]
      resources: ["endpoints"]
      verbs: ["get", "list", "watch", "create", "update", "patch"]
    ---
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: redis-provisioner
    subjects:
    - kind: ServiceAccount
      name: redis-provisioner
      # replace with namespace where provisioner is deployed
      namespace: default
    roleRef:
      kind: Role
      name: redis-provisioner
      apiGroup: rbac.authorization.k8s.io
      
创建service account

    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: redis-nfs-client-provisioner
    ---
    kind: Deployment
    apiVersion: extensions/v1beta1
    metadata:
      name: redis-nfs-client-provisioner
    spec:
      replicas: 1
      strategy:
        type: Recreate
      template:
        metadata:
          labels:
            app: redis-nfs-client-provisioner
        spec:
          serviceAccount: redis-nfs-client-provisioner
          containers:
          - name: redis-nfs-client-provisioner
            image: quay.io/external_storage/nfs-client-provisioner:latest
            imagePullPolicy: IfNotPresent
            volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
            env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 192.168.1.1
            - name: NFS_PATH
              value: /data/nfs/redis
          volumes:
          - name: nfs-client-root
            nfs:
              server: 192.168.1.1
              path: /data/nfs/redis
              
创建storage class

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: redis-managed-nfs-storage
    provisioner: fuseim.pri/ifs
    parameters:
      archiveOnDelete: "false"
      
创建redis

    ---
    apiVersion: v1
    kind: Service
    metadata:
      #name: redis-headless
      name: redis-cluster
      labels:
        app: redis
      annotations:
        service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
    spec:
      ports:
        - port: 6379
          name: server
          targetPort: 6379
      #clusterIP: None
      selector:
        app: redis
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: redis-config
    data:
      redis-config: |
        appendonly yes
        cluster-enabled yes
        cluster-config-file /var/lib/redis/nodes.conf
        cluster-node-timeout 5000
        dir /var/lib/redis
        port 6379
        requirepass password
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: redis
    spec:
      serviceName: redis-headless
      replicas: 6
      template:
        metadata:
          labels:
            app: redis
          annotations:
            pod.alpha.kubernetes.io/initialized: "true"
        spec:
          serviceAccountName: redis-nfs-client-provisioner
          containers:
            - name: redis
              imagePullPolicy: IfNotPresent
              image: redis:latest
              command: [ "/bin/sh","-c","redis-server /etc/redis/redis.conf"]
              resources:
                requests:
                  memory: "2Gi"
                  cpu: "500m"
              ports:
                - containerPort: 6379
                  name: client-port
              ports:
                - containerPort: 16379
                  name: cluster-port
              readinessProbe:
                exec:
                  command:
                  - "/bin/sh"
                  - "-c"
                  - "redis-cli -h $(hostname) ping"
                initialDelaySeconds: 15
                timeoutSeconds: 15
              livenessProbe:
                exec:
                  command:
                  - "/bin/sh"
                  - "-c"
                  - "redis-cli -h $(hostname) ping"
              volumeMounts:
                - name: "redis-conf"
                  mountPath: "/etc/redis"
                - name: "redis-data"
                  mountPath: "/var/lib/redis"
          volumes:
            - name: "redis-conf"
              configMap:
                name: "redis-config"
                items:
                  - key: "redis-config"
                    path: "redis.conf"
      volumeClaimTemplates:
        - metadata:
            name: redis-data
            annotations:
              volume.beta.kubernetes.io/storage-class: "redis-managed-nfs-storage"
          spec:
            accessModes: [ "ReadWriteMany" ]
            resources:
              requests:
                storage: 5Gi
      selector:
        matchLabels:
          app: redis
          
初始化集群

    echo "yes" | kubectl exec -it redis-0 -- redis-cli --cluster create --cluster-replicas 1 $(kubectl get pods -l app=redis -o jsonpath='{range.items[*]}{.status.podIP}:6379 ') -a password
    

