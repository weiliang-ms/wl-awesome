- [oracle](#oracle)
  - [安装条件检测](#%E5%AE%89%E8%A3%85%E6%9D%A1%E4%BB%B6%E6%A3%80%E6%B5%8B)
  - [安装oracle单机](#%E5%AE%89%E8%A3%85oracle%E5%8D%95%E6%9C%BA)
  - [docker启动oracle](#docker%E5%90%AF%E5%8A%A8oracle)

# oracle

## 安装条件检测 ###

**以下内容仅为官网要求部分摘抄，详细环境要求如下**

[https://docs.oracle.com/en/database/oracle/oracle-database/12.2/ladbi/oracle-database-installation-checklist.html#GUID-E847221C-1406-4B6D-8666-479DB6BDB046](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/ladbi/oracle-database-installation-checklist.html#GUID-E847221C-1406-4B6D-8666-479DB6BDB046)

> 硬件要求

	1、DVD光驱（如果采用DVD光盘安装）

	2、linux系统运行级别为3或5

	3、显卡分辨率最低1024 x 768（Oracle Universal Installer图形化安装需要）

	4、oracle宿主机联网（拥有网络适配器）

	5、最小1g内存，建议2g

	#Linux系统有7个运行级别(runlevel)
	运行级别0：系统停机状态，系统默认运行级别不能设为0，否则不能正常启动
	运行级别1：单用户工作状态，root权限，用于系统维护，禁止远程登陆
	运行级别2：多用户状态(没有NFS)
	运行级别3：完全的多用户状态(有NFS)，登陆后进入控制台命令行模式
	运行级别4：系统未使用，保留
	运行级别5：X11控制台，登陆后进入图形GUI模式
	运行级别6：系统正常关闭并重启，默认运行级别不能设为6，否则不能正常启动

	#查看当前系统运行级别(即多用户级别)
	systemctl get-default  或 runlevel

![](images/runlevel.jpg)

	运行级别的原理：
	1。在目录/etc/rc.d/init.d下有许多服务器脚本程序，一般称为服务(service)
	2。在/etc/rc.d下有7个名为rcN.d的目录，对应系统的7个运行级别
	3。rcN.d目录下都是一些符号链接文件，这些链接文件都指向init.d目录下的service脚本文件，命名规则为K+nn+服务名或S+nn+服务名，其中nn为两位数字。
	4。系统会根据指定的运行级别进入对应的rcN.d目录，并按照文件名顺序检索目录下的链接文件
	     对于以K开头的文件，系统将终止对应的服务
	     对于以S开头的文件，系统将启动对应的服务
	5。查看运行级别用：runlevel
	6。进入其它运行级别用：init N
	7。另外init0为关机，init 6为重启系统

> 操作系统要求

	1、安装OpenSSH服务

	2、针对X86-64系统内核支持

	Oracle Linux 7 with the Unbreakable Enterprise Kernel 3: 3.8.13-35.3.1.el7uek.x86_64 or later
	Oracle Linux 7.2 with the Unbreakable Enterprise Kernel 4: 4.1.12-32.2.3.el7uek.x86_64 or later
	Oracle Linux 7 with the Red Hat Compatible kernel: 3.10.0-123.el7.x86_64  or later
	
	Red Hat Enterprise Linux 7: 3.10.0-123.el7.x86_64 or later
	Oracle Linux 6.4 with the Unbreakable Enterprise Kernel 2: 2.6.39-400.211.1.el6uek.x86_64or later
	Oracle Linux 6.6 with the Unbreakable Enterprise Kernel 3: 3.8.13-44.1.1.el6uek.x86_64 or later
	Oracle Linux 6.8 with the Unbreakable Enterprise Kernel 4: 4.1.12-37.6.2.el6uek.x86_64 or later
	Oracle Linux 6.4 with the Red Hat Compatible kernel: 2.6.32-358.el6.x86_64 or later
	Red Hat Enterprise Linux 6.4: 2.6.32-358.el6.x86_64 or later
	SUSE Linux Enterprise Server 12 SP1: 3.12.49-11.1 or later

	SUSE Linux Enterprise Server 15: 4.12.14-25-default or later
	
	Review the system requirements section for a list of minimum package requirements.

	3、若宿主机操作系统为Oracle Linux，建议使用oracle预编译rpm包进行oracle环境初始化

> 宿主机配置要求

	1、/tmp下只要1GB可用存储空间
	
	2、交换区内存大小应满足以下要求
	
	当物理内存在1GB与2GB之间，swap内存应为物理内存的1.5倍
	当物理内存在2GB与16GB之间，swap内存应等于物理内存
	当物理内存高于16GB，swap内存固定16G

	需要注意的是，如果为Linux服务器启用了HugePages，那么在计算交换空间之前，应该从可用RAM中减去分配给HugePages的内存

	3、oracle安装目录必须为ASCII字符

	4、清除以下变量（如果当前主机安装过oracle，会存在以下变量）
	$ORACLE_HOME,$ORA_NLS10, $TNS_ADMIN, $ORACLE_BASE, $ORACLE_SID 

	5、使用root用户或具有root权限的用户（sudo）进行安装

> 宿主机存储空间要求

	针对Linux x86-64:

	单节点最低8.6 GB
	企业版最低7.5 GB
	
## 安装oracle单机

[参考地址](https://blog.csdn.net/dwyane__wade/article/details/80942597)

下载安装介质（迅雷下载）

```
https://updates.oracle.com/Orion/Services/download/p13390677_112040_Linux-x86-64_1of7.zip?aru=16716375&patch_file=p13390677_112040_Linux-x86-64_1of7.zip
https://updates.oracle.com/Orion/Services/download/p13390677_112040_Linux-x86-64_2of7.zip?aru=16716375&patch_file=p13390677_112040_Linux-x86-64_2of7.zip
```

安装依赖

```bash
yum -y install binutils compat-libstdc++-33 elfutils-libelf gcc gcc-c++ \
glibc glibc-common glibc-devel glibc-headers ksh libaio libaio-devel \
libgomp libgcc libstdc++ libstdc++-devel make sysstat unixODBC \
unixODBC-devel numactl-devel kernel-headers glibc-headers \
glibc-devel elfutils-libelf-devel pdksh readline-dev* libXp-* unzip perl psmisc
```

修改系统参数

```bash
HOSTNAME=ora11g
echo "$HOSTNAME">/etc/hostname

echo "$(grep -E '127|::1' /etc/hosts)">/etc/hosts
echo "$(ip a|grep "inet "|grep -v 127|awk -F'[ /]' '{print $6}') $HOSTNAME">>/etc/hosts

rm -rf /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

systemctl disable firewalld --now
systemctl disable NetworkManager --now
systemctl disable NetworkManager-dispatcher --now
systemctl disable postfix --now
```

创建用户用户组

```bash
groupadd oinstall
groupadd dba

# 服务器一定要配置成新建用户同时新建用户家目录！！！
useradd -g oinstall -G dba oracle
echo oracle|passwd --stdin oracle

echo 'fs.suid_dumpable = 1'>>/etc/sysctl.conf
echo 'fs.aio-max-nr = 1048576'>>/etc/sysctl.conf
echo 'fs.file-max = 6815744'>>/etc/sysctl.conf
echo 'kernel.shmmni = 4096'>>/etc/sysctl.conf
echo 'kernel.shmmax = 1075267584'>>/etc/sysctl.conf
echo 'kernel.shmall = 2097152'>>/etc/sysctl.conf
echo 'kernel.sem = 250 32000 100 128'>>/etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 9000 65500'>>/etc/sysctl.conf
echo 'net.core.rmem_default = 1048576'>>/etc/sysctl.conf
echo 'net.core.rmem_max = 4194304'>>/etc/sysctl.conf
echo 'net.core.wmem_default = 262144'>>/etc/sysctl.conf
echo 'net.core.wmem_max = 1048586'>>/etc/sysctl.conf

sysctl -p

echo 'oracle soft nproc 2047'>>/etc/security/limits.conf
echo 'oracle hard nproc 16384'>>/etc/security/limits.conf
echo 'oracle soft nofile 4096'>>/etc/security/limits.conf
echo 'oracle hard nofile 65536'>>/etc/security/limits.conf
echo 'oracle soft stack 10240'>>/etc/security/limits.conf
echo 'session required pam_limits.so'>>/etc/pam.d/login

mkdir -p /u01/app/oracle/product/11.2.0/db_1
chown -R oracle:oinstall /u01
chmod -R 775 /u01
```

配置环境变量

```bash
cat >> /home/oracle/.bash_profile <<EOF
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/db_1
export ORACLE_SID=orcl
export PATH=\$PATH:\$ORACLE_HOME/bin
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
EOF
source /home/oracle/.bash_profile
```

上传安装介质至/tmp下,root执行

```bash
chown oracle:oinstall /tmp/p13390677_112040_Linux-x86-64_*
```

切换用户解压
```bash
su - oracle
cd /tmp
# linux安装zip unzip: yum install -y unzip zip;
unzip p13390677_112040_Linux-x86-64_1of7.zip 
unzip p13390677_112040_Linux-x86-64_2of7.zip
```

创建配置文件

```bash

# 复制粘贴执行即可#############开始######################
cd database/
cat >>/tmp/database/response/install_11g.rsp<<EOF
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oracle/oraInventory
SELECTED_LANGUAGES=en,zh_CN,zh_TW
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.EEOptionsSelection=true
oracle.install.db.optionalComponents=oracle.rdbms.partitioning:11.2.0.3.0,oracle.oraolap:11.2.0.3.0,oracle.rdbms.dm:11.2.0.3.0,oracle.rdbms.dv:11.2.0.3.0,oracle.rdbms.lbac:11.2.0.3.0,oracle.rdbms.rat:11.2.0.3.0
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oinstall
oracle.install.db.CLUSTER_NODES=
oracle.install.db.isRACOneInstall=
oracle.install.db.racOneServiceName=
oracle.install.db.config.starterdb.type=
oracle.install.db.config.starterdb.globalDBName=
oracle.install.db.config.starterdb.SID=
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=true
oracle.install.db.config.starterdb.memoryLimit=
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.SYSMAN=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
oracle.install.db.config.starterdb.automatedBackup.enable=false
oracle.install.db.config.starterdb.automatedBackup.osuid=
oracle.install.db.config.starterdb.automatedBackup.ospwd=
oracle.install.db.config.starterdb.storageType=
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
COLLECTOR_SUPPORTHUB_URL=
oracle.installer.autoupdates.option=
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
EOF
```
静默安装

```bash
# 很重要的一个过程,出现警告正常，出现FATAL不可继续执行！！！
# 出现FATAL,请检查tmp及其子目录是否有多余的一些垃圾文件
# 这个执行过程是很长的，一定要等待这一步完全执行完成，方可进行下一步操作，可以通过：ps -ef  | grep oracle ,查看此命令的执行进程！！！！！
./runInstaller -force -silent -responseFile /tmp/database/response/install_11g.rsp
```

oracle用户执行

```bash
/u01/app/oracle/oraInventory/orainstRoot.sh
/u01/app/oracle/product/11.2.0/db_1/root.sh
```

oracle用户创建监听

```bash
cat >/u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora<<EOF
# listener.ora Network Configuration File: /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora
# Generated by Oracle configuration tools.
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = orcl)
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
      (SID_NAME = orcl)
    )
  )
LISTENER =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $(/sbin/ip a|grep "inet "|grep -v 127|awk -F'[ /]' '{print $6}'))(PORT = 1521))
  )
ADR_BASE_LISTENER = /u01/app/oracle
EOF

# 启动监听必须是oracle用户
lsnrctl start
```

root执行建库脚本

```bash
mkdir -p /oradata/orcl
chown -R oracle: /oradata

su - oracle
###建库脚本，执行并挂到后台
vi /oradata/orcl/dbca.sh

#  以下是脚本内容：****************************************

#!/bin/bash
cat >>/home/oracle/init.ora<<EOF
db_block_size=8192
open_cursors=300
db_domain=""
db_name="orcl"
control_files=("/oradata/orcl/control01.ctl", "/oradata/orcl/control02.ctl", "/oradata/orcl/control03.ctl")
compatible=11.2.0.0.0
diagnostic_dest=/u01/app/oracle
memory_target=842006528
processes=150
audit_file_dest="/u01/app/oracle/admin/orcl/adump"
audit_trail=db
remote_login_passwordfile=EXCLUSIVE
undo_tablespace=UNDOTBS1
EOF
OLD_UMASK=`umask`
umask 0027
mkdir -p /u01/app/oracle/admin/orcl/adump
mkdir -p /u01/app/oracle/admin/orcl/dpdump
mkdir -p /u01/app/oracle/admin/orcl/pfile
mkdir -p /u01/app/oracle/cfgtoollogs/dbca/orcl
mkdir -p /u01/app/oracle/product/11.2.0/db_1/dbs
umask ${OLD_UMASK}
ORACLE_SID=orcl; export ORACLE_SID
PATH=$ORACLE_HOME/bin:$PATH; export PATH
#echo You should Add this entry in the /etc/oratab: orcl:/u01/app/oracle/product/11.2.0/db_1:Y
echo 'orcl:/u01/app/oracle/product/11.2.0/db_1:N'>>/etc/oratab
/u01/app/oracle/product/11.2.0/db_1/bin/sqlplus /nolog<<EOF
set verify off
host /u01/app/oracle/product/11.2.0/db_1/bin/orapwd file=/u01/app/oracle/product/11.2.0/db_1/dbs/orapworcl password='oracle' force=y
SET VERIFY OFF
connect "SYS"/"oracle" as SYSDBA
set echo on
spool /home/oracle/CreateDB.log append
startup nomount pfile="/home/oracle/init.ora";
CREATE DATABASE "orcl"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
DATAFILE '/oradata/orcl/system01.dbf' SIZE 700M REUSE AUTOEXTEND ON NEXT  10240K MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
SYSAUX DATAFILE '/oradata/orcl/sysaux01.dbf' SIZE 600M REUSE AUTOEXTEND ON NEXT  10240K MAXSIZE UNLIMITED
SMALLFILE DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE '/oradata/orcl/temp01.dbf' SIZE 20M REUSE AUTOEXTEND ON NEXT  640K MAXSIZE UNLIMITED
SMALLFILE UNDO TABLESPACE "UNDOTBS1" DATAFILE '/oradata/orcl/undotbs01.dbf' SIZE 200M REUSE AUTOEXTEND ON NEXT  5120K MAXSIZE UNLIMITED
CHARACTER SET ZHS16GBK
NATIONAL CHARACTER SET AL16UTF16
LOGFILE GROUP 1 ('/oradata/orcl/redo01.log') SIZE 51200K,
GROUP 2 ('/oradata/orcl/redo02.log') SIZE 51200K,
GROUP 3 ('/oradata/orcl/redo03.log') SIZE 51200K
USER SYS IDENTIFIED BY "oracle" USER SYSTEM IDENTIFIED BY "oracle";
spool off
SET VERIFY OFF
connect "SYS"/"oracle" as SYSDBA
set echo on
spool /home/oracle/CreateDBFiles.log append
CREATE SMALLFILE TABLESPACE "USERS" LOGGING DATAFILE '/oradata/orcl/users01.dbf'
SIZE 5M REUSE AUTOEXTEND ON NEXT  1280K MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO;
ALTER DATABASE DEFAULT TABLESPACE "USERS";
spool off
SET VERIFY OFF
connect "SYS"/"oracle" as SYSDBA
set echo on
spool /home/oracle/CreateDBCatalog.log append
@/u01/app/oracle/product/11.2.0/db_1/rdbms/admin/catalog.sql;
@/u01/app/oracle/product/11.2.0/db_1/rdbms/admin/catblock.sql;
@/u01/app/oracle/product/11.2.0/db_1/rdbms/admin/catproc.sql;
@/u01/app/oracle/product/11.2.0/db_1/rdbms/admin/catoctk.sql;
@/u01/app/oracle/product/11.2.0/db_1/rdbms/admin/owminst.plb;
connect "SYSTEM"/"oracle"
@/u01/app/oracle/product/11.2.0/db_1/sqlplus/admin/pupbld.sql;
connect "SYSTEM"/"oracle"
set echo on
spool /home/oracle/sqlPlusHelp.log append
@/u01/app/oracle/product/11.2.0/db_1/sqlplus/admin/help/hlpbld.sql helpus.sql;
spool off
spool off
SET VERIFY OFF
set echo on
spool /home/oracle/lockAccount.log append
BEGIN
 FOR item IN ( SELECT USERNAME FROM DBA_USERS WHERE ACCOUNT_STATUS IN ('OPEN', 'LOCKED', 'EXPIRED') AND USERNAME NOT IN (
'SYS','SYSTEM') )
 LOOP
  dbms_output.put_line('Locking and Expiring: ' || item.USERNAME);
  execute immediate 'alter user ' ||
   sys.dbms_assert.enquote_name(
   sys.dbms_assert.schema_name(
   item.USERNAME),false) || ' password expire account lock' ;
 END LOOP;
END;
/
spool off
SET VERIFY OFF
connect "SYS"/"oracle" as SYSDBA
set echo on
spool /home/oracle/postDBCreation.log append
execute DBMS_AUTO_TASK_ADMIN.disable();
@/u01/app/oracle/product/11.2.0/db_1/rdbms/admin/catbundle.sql psu apply;
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
connect "SYS"/"oracle" as SYSDBA
set echo on
create spfile='/u01/app/oracle/product/11.2.0/db_1/dbs/spfileorcl.ora' FROM pfile='/home/oracle/init.ora';
shutdown immediate;
connect "SYS"/"oracle" as SYSDBA
startup ;
spool off
exit;
EOF

#  以上是脚本内容：****************************************

chmod +x dbca.sh
# (一定注意这个执行过程是很长的！！！)
# ./dbca.sh &  隐藏sql执行过程（不建议）

./dbca.sh
```

启动oracle

```bash
sqlplus / as sysdba
```

调整配置

```bash
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
#将默认的密码生存周期由180天改为无限制
alter system set audit_trail=none scope=spfile;
shutdown immediate;
#关闭默认库级审计
startup
alter system set deferred_segment_creation=false;

#关闭段延迟分配
###################################################
host mkdir -p /oradata/arch/orcl
alter system set log_archive_format='arch_%t_%s_%r.arc' scope=spfile;
alter system set log_archive_dest_10='location=/oradata/arch/orcl/' scope=spfile;
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
alter system archive log current;
alter system set control_file_record_keep_time=30;
```

## docker启动oracle

> 1.[安装docker](https://github.com/weiliang-ms/wl-awesome/blob/master/container/docker/docker-install.md)

> 2.拉群镜像

    docker pull registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g

> 3.启动
    
    docker run -itd -p 11521:1521 --restart=always --name oracle11g registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g