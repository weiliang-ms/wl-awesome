<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [helm](#helm)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## helm

> 安装helm3.x

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    
> 添加仓库

    helm repo add stable https://charts.helm.sh/stable
    
> 查询下载

    helm search repo mysql
    helm pull stable/mysql
    
> 