## 单机

https://blog.51cto.com/qchenz/4964475

编辑/usr/lib/systemd/system/mariadb.service文件，在文件[Service]下添加

```shell
LimitNOFILE=65535
LimitNPROC=65535
```

保存后，执行下面命令，使配置生效

```shell
systemctl daemon-reload
systemctl restart  mariadb.service
```


CONFIG_MARIADB_PW=2a76a0b9f1c941d0