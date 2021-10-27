### openssl

> 1.下载最新稳定版

[openssl release地址](https://github.com/openssl/openssl/releases)

> 2.安装必要依赖

```bash
yum install -y wget gcc perl
```

> 3.解压编译

```bash
tar zxvf openssl-OpenSSL_*.tar.gz
cd openssl-OpenSSL*
./config shared --openssldir=/usr/local/openssl --prefix=/usr/local/openssl
make -j $(nproc) && make install
sed -i '/\/usr\/local\/openssl\/lib/d' /etc/ld.so.conf
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
ldconfig -v
mv /usr/bin/openssl /usr/bin/openssl.old
ln -s /usr/local/openssl/bin/openssl  /usr/bin/openssl
cd -
openssl version
```
