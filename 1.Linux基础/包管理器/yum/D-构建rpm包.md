### rpm制作

> 安装`rpmbuild`

```shell
yum install rpm-build -y
```

> 创建目录

````shell
mkdir ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
````

> 编写`~/rpmbuild/SPECS/nginx.spec`

样例

```
%define realname nginx

%define orgnize neu

%define realver 1.18.0

%define srcext tar.gz

%define opensslVersion openssl-1.0.2r

# Common info

Name: %{realname}

Version: %{realver}

Release: %{orgnize}%{?dist}

Summary:Nginx is a web server software

License:GPL

URL:http://nginx.org

Source0: %{realname}-%{realver}%{?extraver}.%{srcext}

Source1: %{opensslVersion}.tar.gz

Source2: headers-more-nginx-module-master.tar.gz

Source3: naxsi-0.56.tar.gz

Source4: nginx_upstream_check_module-master.tar.gz

Source5: ngx-fancyindex-master.tar.gz

Source6: ngx_cache_purge-2.3.tar.gz

Source11: nginx.logrotate

#Source12: nginx.conf

Source13: conf

Source14: nginx

Source21: pcre-8.44.tar.gz

Source22: zlib-1.2.11.tar.gz

Source23: LuaJIT-2.0.5.tar.gz

Source24: lua-nginx-module-0.10.13.tar.gz

Source25: ngx_devel_kit-0.3.0.tar.gz

#Patch:         nginx-memset_zero.patch

# Install-time parameters
Provides:      httpd http_daemon webserver %{?suse_version:suse_help_viewer}
Requires:      logrotate

#BuildRequires: gcc zlib-devel pcre-devel

%description

nginx [engine x] is an HTTP and reverse proxy server

%post

chkconfig nginx on

sed -i "/* soft nofile 655350/d" /etc/security/limits.conf
echo "* soft nofile 655350" >> /etc/security/limits.conf

sed -i "/* hard nofile 655350/d" /etc/security/limits.conf
echo "* hard nofile 655350" >> /etc/security/limits.conf

sed -i "/* soft nproc 65535/d" /etc/security/limits.conf
echo "* soft nproc 65535" >> /etc/security/limits.conf

sed -i "/* hard nproc 65535/d" /etc/security/limits.conf
echo "* hard nproc 65535" >> /etc/security/limits.conf

#sed -i '/\/etc\/logrotate.d\/nginx/d' /etc/crontab
#echo "0 0 * * * root bash /usr/sbin/logrotate -f /etc/logrotate.d/nginx" >> /etc/crontab
mkdir -p ~/.vim
cp -r -v /opt/nginx/vim ~/.vim/
cat > ~/.vim/filetype.vim <<EOF
au BufRead,BufNewFile /opt/nginx/conf/conf.d/*.conf set ft=nginx
EOF

chmod +x /opt/nginx/lj2/lib/*

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/nginx/lj2/lib
ldconfig

# Preparation step (unpackung and patching if necessary)

%prep
%setup -q -n %{realname}-%{realver}%{?extraver} -a1 -a2 -a3 -a4 -a5 -a6 -a21 -a22 -a23 -a24 -a25
#%patch -p1

%build

# pcre-devel

#cd pcre-8.44
#./configure --prefix=/usr/local/pcre-devel
#make -j $(nproc)
#make install

# lua
cd LuaJIT-2.0.5 && make -j $(nproc) && \
  make install PREFIX=%{_builddir}/%{realname}-%{realver}%{?extraver}/lj2

cd ../
ls
ls ./lua-nginx-module-0.10.13
export LUAJIT_LIB=%{_builddir}/%{realname}-%{realver}%{?extraver}/lj2/lib
export LUAJIT_INC=%{_builddir}/%{realname}-%{realver}%{?extraver}/lj2/include/luajit-2.0

#./configure --prefix=/opt/nginx --with-stream --pid-path=/var/run/nginx.pid --add-module=%{_builddir}/%{realname}-%{realver}%{?extraver}/ngx_devel_kit-0.3.0 --add-module=%{_builddir}/%{realname}-%{realver}%{?extraver}/lua-nginx-module-0.10.13
./configure --prefix=/opt/nginx --with-stream \
    --pid-path=/var/run/nginx.pid \
    --with-openssl=%{_builddir}/%{realname}-%{realver}%{?extraver}/%{opensslVersion} \
        --with-pcre=%{_builddir}/%{realname}-%{realver}%{?extraver}/pcre-8.44 \
    --with-zlib=%{_builddir}/%{realname}-%{realver}%{?extraver}/zlib-1.2.11 \
    --with-stream_ssl_preread_module --with-stream_ssl_module \
    --with-http_stub_status_module --with-http_ssl_module \
    --with-http_gzip_static_module \
    --add-module=./ngx_cache_purge-2.3 \
        --add-module=./headers-more-nginx-module-master \
    --add-module=./naxsi-0.56/naxsi_src \
    --add-module=./ngx-fancyindex-master \
    --add-module=./ngx_devel_kit-0.3.0 \
        --add-module=./lua-nginx-module-0.10.13

make -j $(nproc)

%install
%__make install DESTDIR=%{buildroot}
iconv -f koi8-r CHANGES.ru > c && %__mv -f c CHANGES.ru
%__install -d %{buildroot}~/.vim
%__install -D -m755 %{S:11} %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
%__install -D -m755 %{S:14} %{buildroot}%{_sysconfdir}/init.d/%{name}
%__cp -r -v %{_builddir}/%{realname}-%{realver}%{?extraver}/lj2 %{buildroot}/opt/nginx/
%__cp -r -v %{_builddir}/%{realname}-%{realver}%{?extraver}/contrib/vim %{buildroot}/opt/nginx/
%__cp -r -v %{S:13}/* %{buildroot}/opt/nginx/conf/

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%config(noreplace) %{_sysconfdir}/init.d/%{name}
%doc
/opt/nginx/*
%changelog
```

> 构建

```shell
rpmbuild -ba ~/rpmbuild/SPECS/nginx.spec
```