### 导出依赖与使用

> 导出（yum源可用）

```shell
yum install yum-plugin-downloadonly -y
yum install --downloadonly --downloaddir=./gcc gcc
```

> 生成`repo`依赖关系

```shell
yum install -y createrepo
createrepo ./gcc
```

> 压缩

```shell
tar zcvf gcc.tar.gz gcc
```

> 使用（yum源不可用）

```shell
tar zxvf gcc.tar.gz -C /
cat > /etc/yum.repos.d/gcc.repo <<EOF
[gcc]
name=python-repo
baseurl=file:///gpc
gpgcheck=0
enabled=1
EOF
yum install -y gcc
```
