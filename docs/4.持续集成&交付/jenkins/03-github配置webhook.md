### github配置webhook

1. 登录`GitHub`，进入要本次构建用到的工程

2. 在工程主页面点击右上角的`Settings`，再点击左侧`Webhooks`，然后点击`Add webhook`，如下图：

![](./images/jenkins-add-webhook.png)

3. 如下图，在`Payload URL`位置填入`webhook`地址，再点击底部的`Add webhook`按钮，这样就完成`webhook`配置了， 
今后当前工程有代码提交，`GitHub`就会向此`webhook`地址发请求，通知`Jenkins``构建：

- `http://192.168.1.2:8081/jenkins/github-webhook`

![](./images/jenkins-github-generate-hook.png)

4. `push`触发效果

![](./images/jenkins-github-webhook-achive.png)