
`default_type application/pdf;` 

```shell
location = /pdf_carpet {
    alias /var/www/html/pdf_carpet/file.pdf;
    default_type application/pdf;
    add_header Content-Disposition 'inline';
}
```

如果访问 PDF 文件的 URI 以斜杠结尾(或者它是一个特殊情况的根 URI),则上述配置将不起作用,因为 nginx 会将索引文件名附加到这样的 URI(使location = /path/ { ... }不匹配$uri内部 nginx 变量)。对于这种情况,可以使用另一种技术:

```shell
location = / {
    root /var/www/html/pdf_carpet;
    rewrite ^ /file.pdf break;
    add_header Content-Disposition 'inline';
}
```

源：https://devpress.csdn.net/cloud/630546977e6682346619dd7e.html