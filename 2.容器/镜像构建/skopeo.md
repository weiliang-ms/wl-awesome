# skopeo

- [项目地址](https://github.com/containers/skopeo)

## 安装
### 编译安装

> 安装

```bash
yum install -y btrfs-progs-devel gpgme-devel device-mapper-devel libassuan-devel
git clone https://github.com/containers/skopeo.git
cd skopeo
make bin/skopeo
cp bin/skopeo /usr/local/bin
chmod +x /usr/local/bin/skopeo
```

### 预编译包

- [skopeo-1.3.1-linux-amd64.tar.gz](https://github.com/weiliang-ms/skopeo/releases/download/v1.3.1/skopeo-1.3.1-linux-amd64.tar.gz)

> 下载安装

```bash
wget https://github.com/weiliang-ms/skopeo/releases/download/v1.3.1/skopeo-1.3.1-linux-amd64.tar.gz
tar zxvf skopeo-1.3.1-linux-amd64.tar.gz
cp skopeo-1.3.1-linux-amd64/bin/skopeo /usr/local/bin
chmod +x /usr/local/bin/skopeo
```

## dir格式批量导出/导入

> 文件层级

```bash
harbor-export
├── download.sh
├── image-list.txt
└── upload.sh
```

> `image-list.txt`

```bash
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

```bash
#!/bin/bash
GREEN_COL="\\033[32;1m"
RED_COL="\\033[1;31m"
NORMAL_COL="\\033[0;39m"

SOURCE_REGISTRY=harbor.wl.com
REGISTRY_USER=admin
REGISTRY_PASS=Harbor-12345
TARGET_REGISTRY=""

PROJECT_NAME=$1
IMAGES_DIR=$PROJECT_NAME/images

: ${IMAGES_DIR:="images"}
: ${IMAGES_LIST_FILE:="$PROJECT_NAME/image-list.txt"}
: ${TARGET_REGISTRY:="hub.k8s.li"}
: ${SOURCE_REGISTRY:="harbor.chs.neusoft.com"}

BLOBS_PATH="$PROJECT_NAME/docker/registry/v2/blobs/sha256"
REPO_PATH="$PROJECT_NAME/docker/registry/v2/repositories"

set -eo pipefail

CURRENT_NUM=0
TOTAL_NUMS=$(cat "$IMAGES_LIST_FILE" | wc -l)

skopeo_sync() {
 mkdir -p $2/$1
 if skopeo sync --all --insecure-policy --src-tls-verify=false --dest-tls-verify=false \
 --override-arch amd64 --override-os linux --src docker --dest dir $1 $2 > /dev/null; then
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

#while read line
#do
# let CURRENT_NUM=${CURRENT_NUM}+1
# skopeo_sync ${line} $IMAGES_DIR
#done < ${IMAGES_LIST_FILE}

convert_images() {
 rm -rf ${IMAGES_DIR}; mkdir -p ${IMAGES_DIR}

while read image
do
 let CURRENT_NUM=${CURRENT_NUM}+1
 image=`echo $image |sed "s#harbor.chs.neusoft.com/##g"`
 image_name=${image%%:*}
 image_tag=${image##*:}
 image_repo=${image%%/*}
 echo "image-name -> $image_name image-tag -> $image_tag image-repo -> $image_repo"
 mkdir -p ${IMAGES_DIR}/${image_repo}
 skopeo_sync ${SOURCE_REGISTRY}/${image} ${IMAGES_DIR}/${image_repo}
  manifest="${IMAGES_DIR}/${image}/manifest.json"
 manifest_sha256=$(sha256sum ${manifest} | awk '{print $1}')
 mkdir -p ${BLOBS_PATH}/${manifest_sha256:0:2}/${manifest_sha256}
 ln -f ${manifest} ${BLOBS_PATH}/${manifest_sha256:0:2}/${manifest_sha256}/data
 # make image repositories dir
 mkdir -p ${REPO_PATH}/${image_name}/{_uploads,_layers,_manifests}
 mkdir -p ${REPO_PATH}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}
 mkdir -p ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/{current,index/sha256}
 mkdir -p ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}
 # create image tag manifest link file
 echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/current/link
 echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/revisions/sha256/${manifest_sha256}/link
 echo -n "sha256:${manifest_sha256}" > ${REPO_PATH}/${image_name}/_manifests/tags/${image_tag}/index/sha256/${manifest_sha256}/link
 # link image layers file to registry blobs dir
 for layer in $(sed '/v1Compatibility/d' ${manifest} | grep -Eo "\b[a-f0-9]{64}\b"); do
 mkdir -p ${BLOBS_PATH}/${layer:0:2}/${layer}
 mkdir -p ${REPO_PATH}/${image_name}/_layers/sha256/${layer}
 echo -n "sha256:${layer}" > ${REPO_PATH}/${image_name}/_layers/sha256/${layer}/link
 ln -f ${IMAGES_DIR}/${image}/${layer} ${BLOBS_PATH}/${layer:0:2}/${layer}/data
 done
done < ${IMAGES_LIST_FILE}

rm -rf  ${IMAGES_DIR}
}
convert_images
```

使用方式

```shell
sh download.sh library
```

> 导入脚本`upload.sh`

```bash
#!/bin/bash
REGISTRY_DOMAIN="harbor.wl.com"
# 切换到 registry 存储主目录下
gen_skopeo_dir() {
   # 定义 registry 存储的 blob 目录 和 repositories 目录，方便后面使用
    BLOB_DIR="docker/registry/v2/blobs/sha256"
    REPO_DIR="docker/registry/v2/repositories"
    # 定义生成 skopeo 目录
    SKOPEO_DIR="docker/skopeo"
    # 通过 find 出 current 文件夹可以得到所有带 tag 的镜像，因为一个 tag 对应一个 current 目录
    for image in $(find ${REPO_DIR} -type d -name "current"); do
        # 根据镜像的 tag 提取镜像的名字
        name=$(echo ${image} | awk -F '/' '{print $5"/"$6":"$9}')
        link=$(cat ${image}/link | sed 's/sha256://')
        mfs="${BLOB_DIR}/${link:0:2}/${link}/data"
        # 创建镜像的硬链接需要的目录
        mkdir -p "${SKOPEO_DIR}/${name}"
        # 硬链接镜像的 manifests 文件到目录的 manifest 文件
        ln ${mfs} ${SKOPEO_DIR}/${name}/manifest.json
        # 使用正则匹配出所有的 sha256 值，然后排序去重
        layers=$(grep -Eo "\b[a-f0-9]{64}\b" ${mfs} | sort -n | uniq)
        for layer in ${layers}; do
          # 硬链接 registry 存储目录里的镜像 layer 和 images config 到镜像的 dir 目录
            ln ${BLOB_DIR}/${layer:0:2}/${layer}/data ${SKOPEO_DIR}/${name}/${layer}
        done
    done
}
sync_image() {
    # 使用 skopeo sync 将 dir 格式的镜像同步到 harbor
    for project in $(ls ${SKOPEO_DIR}); do
        skopeo sync --insecure-policy --src-tls-verify=false --dest-tls-verify=false \
        --src dir --dest docker ${SKOPEO_DIR}/${project} ${REGISTRY_DOMAIN}/${project}
    done
}
gen_skopeo_dir
sync_image
```

> 登录

```bash
skopeo login harbor.wl.com --tls-verify=false
```

> 执行导入

```bash
sh upload.sh
```