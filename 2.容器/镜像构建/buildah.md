# buildah

## 安装


### 编译安装

> 安装依赖

```bash
yum -y install \
    make \
    gcc \
    golang \
    bats \
    btrfs-progs-devel \
    device-mapper-devel \
    glib2-devel \
    gpgme-devel \
    libassuan-devel \
    libseccomp-devel \
    git \
    bzip2 \
    go-md2man \
    runc \
    skopeo-containers
```

```bash
mkdir ~/buildah
cd ~/buildah
export GOPATH=`pwd`
git clone https://github.com/containers/buildah ./src/github.com/containers/buildah
cd ./src/github.com/containers/buildah
make
sudo make install
buildah --help
```

### 安装binary

> 下载解压

- [buildah-release-1.21-linux-amd64.tar.gz](https://github.com/weiliang-ms/buildah/releases/download/v1.21.0/buildah-release-1.21-linux-amd64.tar.gz)

```bash
tar zxvf buildah-release-1.21-linux-amd64.tar.gz
cp buildah-release-1.21-linux-amd64/bin/buildah /usr/bin
```