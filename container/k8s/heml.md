### helm

安装
    
    curl -O https://storage.googleapis.com/kubernetes-helm/helm-v2.14.3-linux-amd64.tar.gz
    tar zxvf helm-v2.12.1-linux-amd64.tar.gz
    chmod +x linux-amd64/helm
    mv linux-amd64/helm /usr/local/bin
    
添加helm service account 并添加到clusteradmin 这个clusterrole上
    
    kubectl create serviceaccount --namespace=kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
   
安装tiller
    
    helm init -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.14.3 --stable-repo-url http://mirror.azure.cn/kubernetes/charts/ --service-account tiller --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -

查看
    
    kubectl get pods -n kube-system | grep tiller
    
### 离线安装tiller

搭建本地仓储

    http://10.16.48.44/

    docker pull fishead/gcr.io.kubernetes-helm.tiller:v2.11.0

上传导入

    helm init --upgrade --service-account tiller --tiller-image fishead/gcr.io.kubernetes-helm.tiller:v2.11.0 --stable-repo-url http://10.16.48.44/

    
    