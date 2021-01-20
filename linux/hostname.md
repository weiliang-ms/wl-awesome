<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [修改hostname](#%E4%BF%AE%E6%94%B9hostname)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### 修改hostname

- 方法一


	cat >> /etc/sysconfig/network <<EOF
	HOSTNAME=oracle
	EOF
	
	echo oracle >/proc/sys/kernel/hostname

- 方法二


	cat >> /etc/sysconfig/network <<EOF
	HOSTNAME=oracle
	EOF
	
	sysctl kernel.hostname=oracle

- 方法三


	cat >> /etc/sysconfig/network <<EOF
	HOSTNAME=oracle
	EOF
	
	hostname oracle
	
- 方法四


    hostnamectl --static set-hostname master
