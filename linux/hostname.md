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
