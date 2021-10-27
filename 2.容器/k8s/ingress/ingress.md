# nginx ingress 配置手册

可以通过下面三种方式配置`nginx`

- `k8s ConfigMap`配置项方式
- `k8s Annotations`注解方式

## 注解方式-常用配置

注解的`key`与`value`取值为字符串类型. 布尔或数字等类型必须加引号如:

`"true"`, `"false"`, `"100"`

### body体大小

设置每个`location`读取客户端请求体的缓冲区大小。如果请求体大于缓冲区，则整个请求体或仅其部分被写入一个临时文件。
默认情况下，缓冲区大小等于两个内存页。这在`x86`、其他`32`位平台和`x86-64`上是`8K`。在其他`64`位平台上通常是`16K`。

```bash
nginx.ingress.kubernetes.io/client-body-buffer-size: 1M
```

对应原生`nginx`配置

```bash
Syntax:	client_body_buffer_size size;
Default:	
client_body_buffer_size 8k|16k;
Context:	http, server, location
```

