# skopeo

- [项目地址](https://github.com/containers/skopeo)

## 安装
### 编译安装

> 安装

```shell script
yum install -y btrfs-progs-devel gpgme-devel device-mapper-devel libassuan-devel
git clone https://github.com/containers/skopeo.git
cd skopeo
make bin/skopeo
cp bin/skopeo /usr/local/bin
chmod +x /usr/local/bin/skopeo
```

### 预编译包

- [skopeo-1.3.1-linux-amd64.tar.gz](https://github.com/weiliang-ms/skopeo/releases/download/v1.3.1/skopeo-1.3.1-linux-amd64.tar.gz)

> 下载安装

```shell script
wget https://github.com/weiliang-ms/skopeo/releases/download/v1.3.1/skopeo-1.3.1-linux-amd64.tar.gz
tar zxvf skopeo-1.3.1-linux-amd64.tar.gz
cp skopeo-1.3.1-linux-amd64/bin/skopeo /usr/local/bin
chmod +x /usr/local/bin/skopeo
```

## oci格式批量导出/导入

> 文件层级

```shell script
harbor-export
├── download.sh
├── image-list.txt
└── upload.sh
```

> `image-list.txt`

```shell script
harbor.wl.com/kubernetes/csi-snapshotter:v3.0.2
harbor.wl.com/kubernetes/csi-attacher:v3.0.2
harbor.wl.com/kubernetes/csi-node-driver-registrar:v2.0.1
harbor.wl.com/kubernetes/csi-provisioner:v2.0.4
harbor.wl.com/kubernetes/csi-resizer:v1.0.1
harbor.wl.com/kubernetes/cephfs-provisioner:latest
harbor.wl.com/kubernetes/cephcsi:v3.2.0
harbor.wl.com/kubernetes/cephcsi:v3.2.1
harbor.wl.com/kubernetes/node:v3.15.1
harbor.wl.com/kubernetes/cni:v3.15.1
harbor.wl.com/kubernetes/pod2daemon-flexvol:v3.15.1
harbor.wl.com/kubernetes/kube-controllers:v3.15.1
harbor.wl.com/kubernetes/coredns:1.6.9
```

> 导出脚本`download.sh`

```shell script
#!/bin/bash
GREEN_COL="\\033[32;1m"
RED_COL="\\033[1;31m"
NORMAL_COL="\\033[0;39m"

SOURCE_REGISTRY=$1
TARGET_REGISTRY=$2
IMAGES_DIR=$2

: ${IMAGES_DIR:="images"}
: ${IMAGES_LIST_FILE:="image-list.txt"}
: ${TARGET_REGISTRY:="hub.k8s.li"}
: ${SOURCE_REGISTRY:="harbor.wl.com"}

BLOBS_PATH="docker/registry/v2/blobs/sha256"
REPO_PATH="docker/registry/v2/repositories"

set -eo pipefail

CURRENT_NUM=0
ALL_IMAGES="$(sed -n '/#/d;s/:/:/p' ${IMAGES_LIST_FILE} | sort -u)"
TOTAL_NUMS=$(cat "${IMAGES_LIST_FILE}" | wc -l)

skopeo_sync() {
 mkdir -p $2/$1
 if skopeo copy --insecure-policy --src-tls-verify=false --dest-tls-verify=false \
 --override-arch amd64 --override-os linux docker://$1 oci:$2/$1 > /dev/null; then
 echo -e "$GREEN_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 successful $NORMAL_COL"
 else
 echo -e "$RED_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 failed $NORMAL_COL"
 exit 2
 fi
}
if [ -d $IMAGES_DIR ];then
  rm -rf $IMAGES_DIR
fi
mkdir -p $IMAGES_DIR
while read line
do
 let CURRENT_NUM=${CURRENT_NUM}+1
 skopeo_sync ${line} $IMAGES_DIR
done < ${IMAGES_LIST_FILE}
```

> 导入脚本`upload.sh`

```shell script
#!/bin/bash
GREEN_COL="\\033[32;1m"
RED_COL="\\033[1;31m"
NORMAL_COL="\\033[0;39m"

SOURCE_REGISTRY=$1
TARGET_REGISTRY=$2
IMAGES_DIR=$2

: ${IMAGES_DIR:="images"}
: ${IMAGES_LIST_FILE:="image-list.txt"}
: ${TARGET_REGISTRY:="hub.k8s.li"}
: ${SOURCE_REGISTRY:="harbor.wl.com"}

BLOBS_PATH="docker/registry/v2/blobs/sha256"
REPO_PATH="docker/registry/v2/repositories"

set -eo pipefail

CURRENT_NUM=0
ALL_IMAGES="$(sed -n '/#/d;s/:/:/p' ${IMAGES_LIST_FILE} | sort -u)"
TOTAL_NUMS=$(cat "${IMAGES_LIST_FILE}" | wc -l)

skopeo_sync() {
 echo "skopeo copy --insecure-policy --src-tls-verify=false --dest-tls-verify=false \
 --override-arch amd64 --override-os linux oci:$2/$1 docker://$1"
 if skopeo copy --insecure-policy --src-tls-verify=false --dest-tls-verify=false \
 --override-arch amd64 --override-os linux oci:$2/$1 docker://$1 > /dev/null; then
 echo -e "$GREEN_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 successful $NORMAL_COL"
 else
 echo -e "$RED_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 failed $NORMAL_COL"
 exit 2
 fi
}

while read line
do
 let CURRENT_NUM=${CURRENT_NUM}+1
 skopeo_sync ${line} $IMAGES_DIR
done < $IMAGES_LIST_FILE
```

> 执行导出

```shell script
sh download.sh
```

> 执行导入

```shell script
sh upload.sh
```