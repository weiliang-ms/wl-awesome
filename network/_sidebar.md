- 代理相关

  - [科学上网-windows](/network/proxy/windows)
  
  - [科学上网-linux](/network/proxy/linux)

- 网络管理

  - [windows抓包](/network/wireshark)

  - [windows路由](/network/windows)
  
  
  
FROM alpine

LABEL VERSION="5.0.7"

MAINTAINER REDIS Docker Maintainers "ren_jw@neusoft.com"

WORKDIR /

COPY redis-*.tar.gz ./redis.tar.gz

COPY gosu-amd64 /usr/local/sbin/gosu

ADD docker-entrypoint.sh /usr/local/sbin/

RUN addgroup -S -g 1000 redis \
  && adduser -S -G redis -u 999 redis \
  && chmod +x /usr/local/sbin/docker-entrypoint.sh \
  && chmod +x /usr/local/sbin/gosu \
  && set -eux \  
  && sed -i 's/dl-cdn.alpinelinux.org/192.168.131.211:8080/g' /etc/apk/repositories \
  && apk add --no-cache 'su-exec>=0.2' tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && apk del tzdata \
  && apk add --no-cache --virtual .build-deps coreutils gcc linux-headers make musl-dev openssl-dev \
  && mkdir -p /usr/src/redis \
  && tar -xzvf redis.tar.gz -C /usr/src/redis --strip-components=1 \  
  && rm redis.tar.gz \  
  && sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' /usr/src/redis/src/config.c \  
  && export BUILD_TLS=yes \  
  && make -C /usr/src/redis -j "$(nproc)" all \  
  && make -C /usr/src/redis install \  
  && rm -f /usr/local/bin/{redis-check*,redis-sentinel,redis-benchmark} \
  && ln -s /usr/local/bin/redis-sentinel /usr/local/bin/redis-server \
  && ln -s /usr/local/bin/redis-check-aof /usr/local/bin/redis-server \
  && ln -s /usr/local/bin/redis-check-dump /usr/local/bin/redis-server \
  && cp /usr/src/redis/redis.conf /etc/redis.conf \
  && sed -i 's!bind 127.0.0.1!bind 0.0.0.0!' /etc/redis.conf \
  && sed -i 's!dir ./!dir /data!' /etc/redis.conf \
  && sed -i 's!# requirepass foobared!requirepass redis!' /etc/redis.conf \
  && serverMd5="$(md5sum /usr/local/bin/redis-server | cut -d' ' -f1)" \   
  && export serverMd5 \  
  && find /usr/local/bin/redis* -maxdepth 0 -type f -not -name redis-server -exec sh -eux -c ' md5="$(md5sum "$1" | cut -d" " -f1)" \
  && test "$md5" = "$serverMd5" \ 
  && ' -- '{}' ';' -exec ln -svfT 'redis-server' '{}' ';' \ 
  && rm -r /usr/src/redis \ 
  && runDeps="$(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')" \ 
  && apk add --no-network --virtual .redis-rundeps $runDeps \
  && apk del --no-network .build-deps \
  && redis-cli --version \
  && redis-server --version \
  && mkdir /data \
  && chown redis:redis /data \
  && date -R

VOLUME [/data]

WORKDIR /data

EXPOSE 6379

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["redis-server","/etc/redis.conf"] 