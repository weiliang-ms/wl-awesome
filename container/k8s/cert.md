<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [查看证书过期时间](#%E6%9F%A5%E7%9C%8B%E8%AF%81%E4%B9%A6%E8%BF%87%E6%9C%9F%E6%97%B6%E9%97%B4)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### 查看证书过期时间


- 检查证书是否过期

      kubeadm alpha certs check-expiration
      
![](images/outofdate.jpg)

- 手动更新证书

      kubeadm alpha certs renew
      

    
