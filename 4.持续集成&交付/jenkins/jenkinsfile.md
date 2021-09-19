> 使用预定义密钥构建

```shell
stage('build java8-centos-office...') {
    steps {
        withCredentials([usernamePassword(passwordVariable : 'DOCKER_PASSWORD' ,usernameVariable : 'DOCKER_USERNAME' ,credentialsId : "$DOCKER_CREDENTIAL_ID" ,)]) {
            sh '''
                make all
            '''
        }
    }
}
```