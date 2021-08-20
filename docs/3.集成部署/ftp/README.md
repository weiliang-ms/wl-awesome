## ftp

> 安装ftp

    yum install -y vsftpd
    
> 创建用户

    useradd -s /sbin/nologin ftpuser
    passwd ftpuser
    
    
> 目录赋权

    chown -R ftpuser:ftpuser /data
    
> 配置vsftp服务

    sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" /etc/vsftpd/vsftpd.conf
    
    cat >> /etc/vsftpd/vsftpd.conf <<EOF
    userlist_deny=NO
    userlist_file=/etc/vsftpd/user_list
    EOF
    
> 添加用户

    cat >  /etc/vsftpd/user_list <<EOF
    ftpuser
    EOF
    
> 启动
    
    systemctl enable vsftpd --now