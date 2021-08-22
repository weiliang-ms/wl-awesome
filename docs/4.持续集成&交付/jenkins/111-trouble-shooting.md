### 常见问题

> 安装插件时提示：`No valid crumb was included in the request`

**更改配置地址**

- http://192.168.1.2:8081/jenkins/configureSecurity/

解决方案：
在`jenkins 的Configure Global Security`下 , 取消“防止跨站点请求伪造（`Prevent Cross Site Request Forgery exploits）”的勾选。

![](./images/csrf.png)


> `GitHub webhook`触发时`You are authenticated as: anonymous 403`

解决方案：`99%`是`tocken`过期了，重新生成并配置