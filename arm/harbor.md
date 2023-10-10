###

```shell
$ docker-compose ps
NAME                COMMAND                  SERVICE             STATUS                PORTS
harbor-core         "/harbor/entrypoint.…"   core                running (healthy)
harbor-db           "/docker-entrypoint.…"   postgresql          running (healthy)
harbor-jobservice   "/harbor/entrypoint.…"   jobservice          running (healthy)
harbor-log          "/bin/sh -c /usr/loc…"   log                 running (healthy)     127.0.0.1:1514->10514/tcp
harbor-portal       "nginx -g 'daemon of…"   portal              running (unhealthy)
nginx               "nginx -g 'daemon of…"   proxy               restarting
redis               "redis-server /etc/r…"   redis               running (unhealthy)
registry            "/home/harbor/entryp…"   registry            restarting
registryctl         "/home/harbor/start.…"   registryctl         restarting
```

异常一: `registry` 服务 `configuration error: open /etc/registry/config.yml: permission denied`

```shell
$ docker-compose logs -f registry
registry  | Appending internal tls trust CA to ca-bundle ...
registry  | find: '/etc/harbor/ssl': No such file or directory
registry  | Internal tls trust CA appending is Done.
registry  | ls: /harbor_cust_cert: Permission denied
registry  | configuration error: open /etc/registry/config.yml: permission denied
```