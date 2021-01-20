<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Harbor](#harbor)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Harbor

    kubectl create secret docker-registry regcred \
    --docker-server=harbor.weiliang.com \
    --docker-username=admin \
    --docker-password='Harbor-12345' \
    --docker-email=weiliang@163.com
    
使用

![](images/harbor-secret.jpg)

    imagePullSecrets:
    - name: regcred