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