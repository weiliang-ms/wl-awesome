<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [安装Gpu驱动](#%E5%AE%89%E8%A3%85gpu%E9%A9%B1%E5%8A%A8)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### 安装Gpu驱动

> 1.查看Gpu版本

    lspci | grep NVIDIA

执行结果如下

    00:08.0 3D controller: NVIDIA Corporation GV100GL [Tesla V100 SXM2 32GB] (rev a1)

说明版本为`Tesla V100`

> 2.安装驱动

    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
    yum install nvidia-x11-drv nvidia-x11-drv-32bit -y

