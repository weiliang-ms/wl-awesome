## endpoint

将外部服务映射为集群内布，便于配置应用路由等

1. 创建`endpoint`对象

- `addresses`: 数组类型，可以为多个，也可以为一个
- `namespace`: 命名空间

```shell
cat <<EOF | kubectl apply -f -
kind: Endpoints
apiVersion: v1
metadata: 
  name: mysql-external
  namespace: default
subsets:
- addresses:
  - ip: xxx.xxx.xx.xxx
  ports:
   - port: 3306
     name: mysql-external
EOF
```

2. 创建`service`对象

- `port`: 与`endpoint`一致
- `metadata.name`: 与`endpoint`一致
- `metadata.namespace`: 与`endpoint`一致

```shell
cat <<EOF | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: mysql-external
  namespace: default
spec:
  ports:
  - port: 3306
    name: mysql-external
    targetPort: 3306
EOF
```

