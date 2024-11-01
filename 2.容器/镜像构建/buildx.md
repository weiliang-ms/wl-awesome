## 基于x86编译运行arm镜像

### 编译

```shell
docker buildx build --platform=linux/amd64,linux/arm64 -t xxx/xxx:latest -f Dockerfile . --push
```

### 测试运行

开启 QEMU 仿真

```shell
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

下载 qemu-aarch64-static

```shell
wget https://github.com/multiarch/qemu-user-static/releases/download/v5.2.0-1/qemu-aarch64-static && \
chmod +x qemu-aarch64-static
```

启动容器时将 `qemu-aarch64-static` 挂载到容器内
```shell
docker run -t \
--rm \
--platform arm64 \
-v $(pwd)/qemu-aarch64-static:/usr/bin/qemu-aarch64-static \
debian:11 \
uname -m
```


https://blog.csdn.net/edcbc/article/details/139366049?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-139366049-blog-109631585.235^v43^pc_blog_bottom_relevance_base4&spm=1001.2101.3001.4242.2&utm_relevant_index=4