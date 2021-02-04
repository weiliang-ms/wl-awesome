<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [路由配置](#%E8%B7%AF%E7%94%B1%E9%85%8D%E7%BD%AE)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 路由配置 ##

应用场景：内外网同联

**很危险的操作！！！**

192.168.146.0/24 路由到网关192.168.121.1

	route -p add 192.168.146.0 mask 255.255.255.0 192.168.121.1