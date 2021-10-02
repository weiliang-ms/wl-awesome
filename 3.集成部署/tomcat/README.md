### 修改tomcat8.5默认jvm内存参数

> 1.查看`java`进程`jvm`参数

```shell
$ jps -v
1633 Bootstrap -Djava.util.logging.config.file=/opt/apache-tomcat-8.5.71/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dorg.apache.catalina.security.SecurityListener.UMASK=0027 -Dignore.endorsed.dirs= -Dcatalina.base=/opt/apache-tomcat-8.5.71 -Dcatalina.home=/opt/apache-tomcat-8.5.71 -Djava.io.tmpdir=/opt/apache-tomcat-8.5.71/temp
```

结果发现默认启动时，并没有配置`jvm`参数

> 2.查看`java`进程实际运行时内存大小

发现`MaxHeapSize`为`4006.0MB`

```shell
$ jmap -heap 12206
Attaching to process ID 12206, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.262-b10

using thread-local object allocation.
Parallel GC with 4 thread(s)

Heap Configuration:
   MinHeapFreeRatio         = 0
   MaxHeapFreeRatio         = 100
   MaxHeapSize              = 4200595456 (4006.0MB)
   NewSize                  = 88080384 (84.0MB)
   MaxNewSize               = 1399848960 (1335.0MB)
   OldSize                  = 176160768 (168.0MB)
   NewRatio                 = 2
   SurvivorRatio            = 8
   MetaspaceSize            = 21807104 (20.796875MB)
   CompressedClassSpaceSize = 1073741824 (1024.0MB)
   MaxMetaspaceSize         = 17592186044415 MB
   G1HeapRegionSize         = 0 (0.0MB)

Heap Usage:
PS Young Generation
Eden Space:
   capacity = 1360003072 (1297.0MB)
   used     = 945066744 (901.2858810424805MB)
   free     = 414936328 (395.71411895751953MB)
   69.49004479895763% used
From Space:
   capacity = 18350080 (17.5MB)
   used     = 13697696 (13.063140869140625MB)
   free     = 4652384 (4.436859130859375MB)
   74.64651925223214% used
To Space:
   capacity = 19922944 (19.0MB)
   used     = 0 (0.0MB)
   free     = 19922944 (19.0MB)
   0.0% used
PS Old Generation
   capacity = 305135616 (291.0MB)
   used     = 255110640 (243.29246520996094MB)
   free     = 50024976 (47.70753479003906MB)
   83.6056581477529% used

46774 interned Strings occupying 5194776 bytes.
```

> 3.调整`jvm`参数

`vim apache-tomcat-8.5.71/bin/catalina.sh`

在`JAVA_OPTS="$JAVA_OPTS $JSSE_OPTS"`上面添加`JAVA_OPTS`参数，`JAVA_OPTS`参考值如下:

- 宿主机`8G`内存，并只运行一个`java`应用

```
JAVA_OPTS="-Dfile.encoding=UTF-8 -server -Xms6144m -Xmx6144m -XX:NewSize=1024m -XX:MaxNewSize=2048m -XX:PermSize=512m -XX:MaxPermSize=512m -XX:MaxTenuringThreshold=10 -XX:NewRatio=2 -XX:+DisableExplicitGC"
```

- 宿主机`16G`内存，并只运行一个`java`应用

```
JAVA_OPTS="-Dfile.encoding=UTF-8 -server -Xms13312m -Xmx13312m -XX:NewSize=3072m -XX:MaxNewSize=4096m -XX:PermSize=512m -XX:MaxPermSize=512m -XX:MaxTenuringThreshold=10 -XX:NewRatio=2 -XX:+DisableExplicitGC"
```

- 宿主机`32G`内存，并只运行一个`java`应用

```
JAVA_OPTS="-Dfile.encoding=UTF-8 -server -Xms29696m -Xmx29696m -XX:NewSize=6144m -XX:MaxNewSize=9216m -XX:PermSize=1024m -XX:MaxPermSize=1024m -XX:MaxTenuringThreshold=10 -XX:NewRatio=2 -XX:+DisableExplicitGC"
```

参数说明：

```
-Dfile.encoding：默认文件编码
-server：表示这是应用于服务器的配置，JVM 内部会有特殊处理的
-Xmx1024m：设置JVM最大可用内存为1024MB
-Xms1024m：设置JVM最小内存为1024m。此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存。
-XX:NewSize：设置年轻代大小
-XX:MaxNewSize：设置最大的年轻代大小
-XX:PermSize：设置永久代大小
-XX:MaxPermSize：设置最大永久代大小
-XX:NewRatio=4：设置年轻代（包括 Eden 和两个 Survivor 区）与终身代的比值（除去永久代）。设置为 4，则年轻代与终身代所占比值为 1：4，年轻代占整个堆栈的 1/5
-XX:MaxTenuringThreshold=10：设置垃圾最大年龄，默认为：15。如果设置为 0 的话，则年轻代对象不经过 Survivor 区，直接进入年老代。对于年老代比较多的应用，可以提高效率。
                             如果将此值设置为一个较大值，则年轻代对象会在 Survivor 区进行多次复制，这样可以增加对象再年轻代的存活时间，增加在年轻代即被回收的概论。
-XX:+DisableExplicitGC：这个将会忽略手动调用 GC 的代码使得 System.gc() 的调用就会变成一个空调用，完全不会触发任何 GC
```

> 4.优雅下线应用

```shell
$ kill -15 24188
```

> 5.启动应用

```shell
$ sh bin/startup.sh
```

> 6.确认`jvm`参数

```shell
jps -v
8751 Bootstrap -Djava.util.logging.config.file=/opt/apache-tomcat-8.5.71/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Dfile.encoding=UTF-8 -Xms13312m -Xmx13312m -XX:NewSize=3072m -XX:MaxNewSize=4096m -XX:PermSize=512m -XX:MaxPermSize=512m -XX:MaxTenuringThreshold=10 -XX:NewRatio=2 -XX:+DisableExplicitGC -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dorg.apache.catalina.security.SecurityListener.UMASK=0027 -Dignore.endorsed.dirs= -Dcatalina.base=/opt/apache-tomcat-8.5.71 -Dcatalina.home=/opt/apache-tomcat-8.5.71 -Djava.io.tmpdir=/opt/apache-tomcat-8.5.71/temp
```

> 7.查看应用运行时内存

```shell
$ jmap -heap 8751
Attaching to process ID 8751, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.262-b10

using thread-local object allocation.
Parallel GC with 4 thread(s)

Heap Configuration:
   MinHeapFreeRatio         = 0
   MaxHeapFreeRatio         = 100
   MaxHeapSize              = 13958643712 (13312.0MB)
   NewSize                  = 4294967296 (4096.0MB)
   MaxNewSize               = 4294967296 (4096.0MB)
   OldSize                  = 9663676416 (9216.0MB)
   NewRatio                 = 2
   SurvivorRatio            = 8
   MetaspaceSize            = 21807104 (20.796875MB)
   CompressedClassSpaceSize = 1073741824 (1024.0MB)
   MaxMetaspaceSize         = 17592186044415 MB
   G1HeapRegionSize         = 0 (0.0MB)

Heap Usage:
PS Young Generation
Eden Space:
   capacity = 3784835072 (3609.5MB)
   used     = 2417960320 (2305.9466552734375MB)
   free     = 1366874752 (1303.5533447265625MB)
   63.8854870556431% used
From Space:
   capacity = 261619712 (249.5MB)
   used     = 11125784 (10.610374450683594MB)
   free     = 250493928 (238.8896255493164MB)
   4.252655090454346% used
To Space:
   capacity = 248512512 (237.0MB)
   used     = 0 (0.0MB)
   free     = 248512512 (237.0MB)
   0.0% used
PS Old Generation
   capacity = 9663676416 (9216.0MB)
   used     = 37241992 (35.51673126220703MB)
   free     = 9626434424 (9180.483268737793MB)
   0.38538119859165615% used

39540 interned Strings occupying 4308880 bytes.
```

### 修改tomcat默认停止脚本

有这样的一个现象：一个`tomcat`程序`shutdown.sh`后，并未完全退出

```shell
$ ps -ef|grep java
root      1633     1  0 Sep23 ?        00:09:18 /usr/bin/java -Djava.util.logging.config.file=/opt/apache-tomcat-8.5.71/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dorg.apache.catalina.security.SecurityListener.UMASK=0027 -Dignore.endorsed.dirs= -classpath /opt/apache-tomcat-8.5.71/bin/bootstrap.jar:/opt/apache-tomcat-8.5.71/bin/tomcat-juli.jar -Dcatalina.base=/opt/apache-tomcat-8.5.71 -Dcatalina.home=/opt/apache-tomcat-8.5.71 -Djava.io.tmpdir=/opt/apache-tomcat-8.5.71/temp org.apache.catalina.startup.Bootstrap start
root      3059     1  0 Sep24 ?        00:15:43 /usr/bin/java -Djava.util.logging.config.file=/opt/apache-tomcat-8.5.71/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dorg.apache.catalina.security.SecurityListener.UMASK=0027 -Dignore.endorsed.dirs= -classpath /opt/apache-tomcat-8.5.71/bin/bootstrap.jar:/opt/apache-tomcat-8.5.71/bin/tomcat-juli.jar -Dcatalina.base=/opt/apache-tomcat-8.5.71 -Dcatalina.home=/opt/apache-tomcat-8.5.71 -Djava.io.tmpdir=/opt/apache-tomcat-8.5.71/temp org.apache.catalina.startup.Bootstrap start
root     12206     1  0 Sep27 ?        00:14:44 /usr/bin/java -Djava.util.logging.config.file=/opt/apache-tomcat-8.5.71/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dorg.apache.catalina.security.SecurityListener.UMASK=0027 -Dignore.endorsed.dirs= -classpath /opt/apache-tomcat-8.5.71/bin/bootstrap.jar:/opt/apache-tomcat-8.5.71/bin/tomcat-juli.jar -Dcatalina.base=/opt/apache-tomcat-8.5.71 -Dcatalina.home=/opt/apache-tomcat-8.5.71 -Djava.io.tmpdir=/opt/apache-tomcat-8.5.71/temp org.apache.catalina.startup.Bootstrap start
root     27186 24283  0 09:47 pts/0    00:00:00 grep --color=auto java
```

> 原因

一般关闭不了的情况，是由于程序在`tomcat`中开启了新的线程，而且未设置成`daemon`，造成的主线程不能退出

> 解决方式

`vim bin/shutdown.sh`，修改最后一行`exec "$PRGDIR"/"$EXECUTABLE" stop "$@"`
改为：
```
exec "$PRGDIR"/"$EXECUTABLE" stop -force "$@"
```

参考
- [文档](https://www.cnblogs.com/opma/p/11712314.html)
- [tomcat关不掉的原因](https://blog.csdn.net/seven_zhao/article/details/51684411)