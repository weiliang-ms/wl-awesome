<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [安装java](#%E5%AE%89%E8%A3%85java)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 安装java

> 1.下载虚拟控制台连接文件

![](images/iDRAC_jnlp.jpg)

> 2.widows环境下下载安装java1.7

[jre1.7下载地址](https://www.oracle.com/java/technologies/javase/javase7-archive-downloads.html)

![](images/iDRAC_jre.jpg)

> 3.调整java设置

控制面板->程序->Java

![](images/iDRAC_control_java.jpg)

Java->查看->勾选取消高版本->确定

![](images/iDRAC_cancle_high_version.jpg)

高级->勾选调试三项->应用确定

![](images/iDRAC_open_debug.jpg)

> 4.设置引导

登录iDRAC控制台,配置如下

![](images/iDRAC_set_guide.jpg)

> 5.运行jnlp文件

鼠标右键步骤1下载的文件 -> 打开方式 -> 选择jre1.7的javaws.exe文件

![](images/iDRAC_open_jnlp.jpg)

允许使用过期版本

![](images/iDRAC_use_outdate_jre.jpg)

控制台日志输出

![](images/iDRAC_jre_console.png)

iDRAC虚拟控制台

![](images/iDRAC_virtaul_console.jpg)

> 6.安装操作系统

添加虚拟介质

![](images/iDRAC_virtaul_media.jpg)

添加映射本地iso

![](images/iDRAC_add_iso.jpg)

执行温引导

![](images/iDRAC_warm_lead.jpg)







    