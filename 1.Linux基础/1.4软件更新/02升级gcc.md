### 升级gcc

升级至`5.4`

> 下载介质

- [gcc-5.4.0.tar.gz](http://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz)
- [gmp-4.3.2.tar.gz](http://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.gz)
- [mpc-1.0.1.tar.gz](http://ftp.gnu.org/gnu/mpc/mpc-1.0.1.tar.gz)
- [mpfr-2.4.2.tar.gz](http://ftp.gnu.org/gnu/mpfr/mpfr-2.4.2.tar.gz)

> 安装依赖

```bash
tar zxvf gmp-4.3.2.tar.gz
cd gmp-4.3.2
./configure --prefix=/usr/local/gmp-4.3.2 \
&& make -j $(nproc) && make install && cd -

tar zxvf mpfr-2.4.2.tar.gz
cd mpfr-2.4.2
./configure --prefix=/usr/local/mpfr-2.4.2 \
--with-gmp=/usr/local/gmp-4.3.2 \
&& make -j $(nproc) && make install && cd -

tar zxvfv mpc-1.0.1.tar.gz
cd mpc-1.0.1
./configure --prefix=/usr/local/mpc-1.0.1 \
--with-gmp=/usr/local/gmp-4.3.2 --with-mpfr=/usr/local/mpfr-2.4.2 \
&& make -j $(nproc) && make install && cd -
```

> 配置环境变量

```bash
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/gmp-4.3.2/lib:/usr/local/mpc-1.0.1/lib:/usr/local/mpfr-2.4.2/lib" >> /etc/profile
. /etc/profile
```

> 编译`gcc`

```bash
tar -xzvf gcc-5.4.0.tar.gz && mkdir gcc-5.4.0/gcc-build && cd gcc-5.4.0/gcc-build \
&& ../configure --prefix=/usr/local/gcc-5.4.0 --enable-threads=posix \
--disable-checking --disable-multilib --enable-languages=c,c++ \
--with-gmp=/usr/local/gmp-4.3.2 --with-mpfr=/usr/local/mpfr-2.4.2 \
--with-mpc=/usr/local/mpc-1.0.1 && make -j $(nproc) && make install && cd -
```

> 备份更新

```bash
mkdir -p /usr/local/bakup/gcc
mv /usr/bin/{gcc,g++} /usr/local/bakup/gcc/
cp /usr/local/gcc-5.4.0/bin/gcc /usr/bin/gcc
cp /usr/local/gcc-5.4.0/bin/g++ /usr/bin/g++
```