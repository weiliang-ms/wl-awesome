<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [安装oracle单机](#%E5%AE%89%E8%A3%85oracle%E5%8D%95%E6%9C%BA)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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