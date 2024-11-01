## 基于二进制离线安装docker

1. 下载最新二进制文件：

https://download.docker.com/linux/static/stable/x86_64/

如：https://download.docker.com/linux/static/stable/x86_64/docker-20.10.17.tgz

2. 解压并配置到系统PATH

```shell
$ tar zxvf docker-20.10.17.tgz
$ cp docker/* /usr/bin/
```

3. 配置dockerd

```shell
$ tee /usr/lib/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF
```

4. 配置containerd

```shell
$ tee /etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target


[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-999


[Install]
WantedBy=multi-user.target
EOF
```

5. 生成docker.socket

```shell
$ tee /etc/systemd/system/docker.socket <<EOF
[Unit]
Description=Docker Socket for the API


[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker


[Install]
WantedBy=sockets.target
EOF
```

7. 启动containerd、dockerd

```shell
groupadd docker
systemctl enable --now containerd.service
systemctl enable --now docker.service
```

8. 测试docker

```shell
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
$ docker images
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
```

## 安装docker-compose

1. 下载二进制文件

https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-linux-x86_64

2. 拷贝到bin目录

```shell
$ cp docker-compose-linux-x86_64 /usr/bin/docker-compose
$ chmod +x /usr/bin/docker-compose
```