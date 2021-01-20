<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [配置清华源](#%E9%85%8D%E7%BD%AE%E6%B8%85%E5%8D%8E%E6%BA%90)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 配置清华源

> 清理已有源

```bash
rm -f /etc/apt/sources.list.d/*
```    

> 添加清华源

```bash
cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
EOF
```

> 更新

```bash
sudo apt-get update
```