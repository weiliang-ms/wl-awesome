<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [docker build image](#docker-build-image)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## docker build image

创建目录

	mkdir -p /docker/simple

创建dockerfile

	FROM alpine
	
	# 设置变量
	ENV NGINX_VERSION 1.16.1
	
	# 修改源
	RUN echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > /etc/apk/repositories && \
	    echo "http://mirrors.aliyun.com/alpine/latest-stable/community/" >> /etc/apk/repositories && \
	# 安装需要的软件
	    apk update && \
	    apk add --no-cache ca-certificates && \
	    apk add --no-cache curl bash tree tzdata && \
	    cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	
	# 编译安装nginx
	    GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
	    && CONFIG="\
	        --prefix=/opt/nginx \
	        --sbin-path=/usr/sbin/nginx \
	        --modules-path=/usr/lib/nginx/modules \
	        --conf-path=/opt/nginx/conf/nginx.conf \
	        --error-log-path=/var/log/nginx/error.log \
	        --http-log-path=/var/log/nginx/access.log \
	        --pid-path=/var/run/nginx.pid \
	        --lock-path=/var/run/nginx.lock \
	        --http-client-body-temp-path=/var/cache/nginx/client_temp \
	        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	        --user=nginx \
	        --group=nginx \
	        --with-http_ssl_module \
	        --with-http_realip_module \
	        --with-http_addition_module \
	        --with-http_sub_module \
	        --with-http_gunzip_module \
	        --with-http_gzip_static_module \
	        --with-http_random_index_module \
	        --with-http_secure_link_module \
	        --with-http_stub_status_module \
	        --with-http_auth_request_module \
	        --with-http_xslt_module=dynamic \
	        --with-http_image_filter_module=dynamic \
	        --with-http_geoip_module=dynamic \
	        --with-stream \
	        --with-stream_ssl_module \
	        --with-stream_ssl_preread_module \
	        --with-stream_realip_module \
	    " \
	    && addgroup -S nginx \
	    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	    && apk add --no-cache --virtual .build-deps \
	        gcc \
	        libc-dev \
	        make \
	        openssl-dev \
	        pcre-dev \
	        zlib-dev \
	        linux-headers \
	        curl \
	        gnupg \
	        libxslt-dev \
	        gd-dev \
	        geoip-dev \
	    && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	    && mkdir -p /usr/src \
	    && tar -zxC /usr/src -f nginx.tar.gz \
	    && rm nginx.tar.gz \
	    && cd /usr/src/nginx-$NGINX_VERSION \
	    && ./configure $CONFIG --with-debug \
	    && make -j$(getconf _NPROCESSORS_ONLN) \
	    && mv objs/nginx objs/nginx-debug \
	    && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
	    && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
	    && ./configure $CONFIG \
	    && make -j$(getconf _NPROCESSORS_ONLN) \
	    && make install \
	    && rm -rf /opt/nginx/html/ \
	    && mkdir /opt/nginx/conf/conf.d/ \
	    && mkdir -p /usr/share/nginx/html/ \
	    && install -m644 html/index.html /usr/share/nginx/html/ \
	    && install -m644 html/50x.html /usr/share/nginx/html/ \
	    && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
	    && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
	    && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
	    && ln -s ../../usr/lib/nginx/modules /opt/nginx/modules \
	    && strip /usr/sbin/nginx* \
	    && strip /usr/lib/nginx/modules/*.so \
	    && rm -rf /usr/src/nginx-$NGINX_VERSION \
	    \
	    # Bring in gettext so we can get `envsubst`, then throw
	    # the rest away. To do this, we need to install `gettext`
	    # then move `envsubst` out of the way so `gettext` can
	    # be deleted completely, then move `envsubst` back.
	    && apk add --no-cache --virtual .gettext gettext \
	    && mv /usr/bin/envsubst /tmp/ \
	    \
	    && runDeps="$( \
	        scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
	            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
	            | sort -u \
	            | xargs -r apk info --installed \
	            | sort -u \
	    )" \
	    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
	    && apk del .build-deps \
	    && apk del .gettext \
	    && mv /tmp/envsubst /usr/local/bin/ \
	    \
	    # forward request and error logs to docker log collector
	    && ln -sf /dev/stdout /var/log/nginx/access.log \
	    && ln -sf /dev/stderr /var/log/nginx/error.log
	
	# 开放80端口
	EXPOSE 80
	
	STOPSIGNAL SIGTERM
	
	# 启动nginx命令
	CMD ["nginx", "-g", "daemon off;"]

构建镜像

	docker build -t nginx:1.16.1 .

11/16/2019 1:55:59 PM 

批量导出

    docker images |awk '{print $1}' |sed -n '2,$p' |xargs docker save -o k8s.tar