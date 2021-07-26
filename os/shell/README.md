## 常用shell语句

### 查询文件内`tab`键

适用于`yaml`校验(制表符)

```shell script
grep  $'\t' 文件名
```
    
### 查看shell运行时间

> 用`date`相减

```shell script
startTime=`date +%Y%m%d-%H:%M:%S`
startTime_s=`date +%s`

endTime=`date +%Y%m%d-%H:%M:%S`
endTime_s=`date +%s`

sumTime=$[ $endTime_s - $startTime_s ]

echo "$startTime ---> $endTime" "Total:$sumTime seconds"
```

> `time`

```shell script
time sh xxx.sh
# 会返回3个时间数据
# real 该命令的总耗时, 包括user和sys及io等待, 时间片切换等待等等
# user 该命令在用户模式下的CPU耗时,也就是内核外的CPU耗时,不含IO等待这些时间
# sys  该命令在内核中的CPU耗时,不含IO,时间片切换耗时.
```

### 操作用户

> 1.root下创建用户neusoft

	#创建neusoft用户，且初始化密码为1234%^&*
	useradd -m neusoft  && echo "1234%^&*" | passwd --stdin neusoft

> 2.删除用户及该用户HOME目录

	#删除neusoft用户及该用户HOME目录(/home/neusoft)
	userdel -r neusoft

### vi用法(英文输入法下)

	#1.关闭保存
	:wq!
	#2.强制退出
	:q!
	#3.进入编辑模式,英文输入法下输入
	i 或者 o 或者 a 或者 insert
	#4.匹配关键字，英文输入法下
	/关键字
	
	#5.光标移动到行尾
	
	shift + 4
	
	#6.光标移动到第一段
	
	shift + h
	
	#7.光标移动到最后一段

	shift + g
	
	#8.将当前行找到的所有str1替换为str2
	
	:s/str1/str2/g

### 防火墙开放端口
    
- el6

    
    #开放端口（7777）
    iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 7777 -j ACCEPT
    #保存
    /etc/rc.d/init.d/iptables save
    #重载
    service iptables restart
    
- el7

    
    firewall-cmd --zone=public --add-port=7777/tcp --permanent
    #重新载入
    firewall-cmd --reload

### 关闭selinux
    
    setenforce 0
    sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config

### 开启tcp端口监听（测试网络连通性）

    python -m SimpleHTTPServer 9099

### 文件切割

	split -d -b 100m enterprise.log  enterprise-

### 磁盘占用异常排查

	#查找
	du -m --max-depth=1 |sort -gr

	lsof |grep delete

	#删除
	lsof |grep delete|awk '{print $2}'|xargs -n1 kill -9

	#恢复删除文件（句柄未释放）
	https://segmentfault.com/a/1190000000461077

### 查看tcp连接状态

   netstat -na|awk '/^tcp/ {++S[$NF]} END {for(i in S) print i,S[i]}'

### 打包iso

    mkisofs -o ./package.iso -J -R -A -V -v package

### 创建大文件

创建

    fallocate -l 10G test4
    
撤销

    fallocate -d test4
    
## 磁盘监控脚本

系统版本：CentOS7

脚本`/usr/bin/disk-monitor.sh`内容如下：

```bash
#!/bin/bash
LOCAL_HOST=192.168.1.3
RECEIVE_LIST="aaa@xxx.com"
CC_LIST="bbb@xxx.com,ccc@xxx.com,ddd@xxx.com"

MOUNT_NODE_COUNT=`df -h|wc -l`

echo "挂载节点数为：${MOUNT_NODE_COUNT}"

while [[ ${MOUNT_NODE_COUNT} -ne 1 ]];
do
  FILE_SYSTEM=`df -h |sed -n "$MOUNT_NODE_COUNT p"|awk '{print $1}'`
  MOUNT_NODE=`df -h |sed -n "$MOUNT_NODE_COUNT p"|awk '{print $6}'`
  PART_FREE_SPACE=`df -h |sed -n "$MOUNT_NODE_COUNT p"|awk '{print $4}'`
  UTILIZATION_RATE=`df -h |sed -n "$MOUNT_NODE_COUNT p"|awk '{print $5}'`
  UTILIZATION_RATE_VALUE=`echo ${UTILIZATION_RATE}|sed 's/.$//'`
  # echo "文件系统：`echo ${FILE_SYSTEM}`，挂在节点：`echo "$MOUNT_NODE"`，分区磁盘使用率为：`echo ${UTILIZATION_RATE}`, 剩余磁盘空间：`echo ${PART_FREE_SPACE}`"
  if [[  ${UTILIZATION_RATE_VALUE} -gt 95 ]]; then
     MAIL_CONTENT="[当前地址]：${LOCAL_HOST}
[文件系统]：`echo ${FILE_SYSTEM}`
[挂在节点]：`echo "$MOUNT_NODE"`
[分区磁盘使用率]：`echo ${UTILIZATION_RATE}`

已达告警阈值，请及时清理！！！"
     echo ${MAIL_CONTENT}
     echo "${MAIL_CONTENT}" | mail -s "磁盘剩余空间告警" -c ${CC_LIST} ${RECEIVE_LIST} &> /dev/null
  fi
  let MOUNT_NODE_COUNT--
done
```

安装mailx

```bash
yum install -y mailx
```

配置mailx，/etc/mail.rc追加以下内容
```bash
set from=aaa@xxx.com
set smtp=smtp.xxx.com:587
set smtp-auth-user=aaa
set smtp-auth-password=******
set smtp-auth=login
set smtp-use-starttls
set ssl-verify=ignore
set nss-config-dir=/etc/pki/nssdb/
```

配置定时任务

```bash
cat >> /etc/crontab <<EOF
0 */1 * * * root /usr/bin/disk-monitor.sh
EOF
```

## ssl生成脚本

    #!/bin/bash
    
    # 域名
    export domain=www.example.com
    
    # IP地址（可选）
    export address=192.168.1.11
    
    # 国家
    export contryName=CN
    
    # 省/州/邦
    export stateName=Liaoning
    
    # 地方/城市名
    export locationName=Shenyang
    
    # 组织/公司名称
    export organizationName=example
    
    # 组织/公司部门名称
    export sectionName=develop
    
    echo "Getting Certificate Authority..."
    openssl genrsa -out ca.key 4096
    openssl req -x509 -new -nodes -sha512 -days 3650 \
      -subj "/C=$contryName/ST=$stateName/L=$locationName/O=$organizationNaem/OU=$sectionName/CN=$domain" \
      -key ca.key \
      -out ca.crt
    
    echo "Create your own Private Key..."
    openssl genrsa -out $domain.key 4096
    
    echo "Generate a Certificate Signing Request..."
    openssl req -sha512 -new \
      -subj "/C=$contryName/ST=$stateName/L=$locationName/O=$organizationNaem/OU=$sectionName/CN=$domain" \
      -key $domain.key \
      -out $domain.csr
    
    echo "Generate the certificate of your registry host..."
    cat > v3.ext <<-EOF
    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    extendedKeyUsage = serverAuth
    subjectAltName = @alt_names
    
    [alt_names]
    DNS.1=$domain
    DNS.2=hostname
    IP.1=$address
    EOF
    
    openssl x509 -req -sha512 -days 3650 \
      -extfile v3.ext \
      -CA ca.crt -CAkey ca.key -CAcreateserial \
      -in $domain.csr \
      -out $domain.crt
    
    echo "Convert server $domain.crt to $domain.cert..."
    openssl x509 -inform PEM -in $domain.crt -out $domain.cert
    
    echo "merge the intermediate certificate with your own certificate to create a certificate bundle..."
    cp $domain.crt /etc/pki/ca-trust/source/anchors/$domain.crt
    update-ca-trust
    
    echo "successful..."
