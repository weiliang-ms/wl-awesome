## CentOS7时钟同步问题

最近项目中遇到个比较棘手的问题，虽然配置了时钟同步，但有些主机（虚拟机）时钟偏移量有些离谱（10+秒）

最终通过如下步骤，暂时解决。暂未发现问题。

1. 清理主机上的时钟同步定时任务

由于主机由虚拟机模板创建，默认带了一个时钟同步命令，与现有的地址不一致，故先删除该任务。

确认定时任务

````shell
crontab -l
````

删除定时任务(会清空当前用户下的定时任务，执行前确保无其他定时任务策略)
```shell
crontab -r
```

**注：** 这个场景还是有几率遇到

2. 安装配置`chrony`

```shell
yum install -y chrony
```

配置

- `10.10.10.10`注意替换为你的实际时钟服务器服务端地址

```shell
echo "server 10.10.10.10 iburst" >> /etc/chrony.conf
```

关闭默认地址（内网解析不到）

```shell
sed -i "s;server 0.centos.pool.ntp.org iburst;#server 0.centos.pool.ntp.org iburst;g" /etc/chrony.conf
sed -i "s;server 1.centos.pool.ntp.org iburst;#server 1.centos.pool.ntp.org iburst;g" /etc/chrony.conf
sed -i "s;server 2.centos.pool.ntp.org iburst;#server 2.centos.pool.ntp.org iburst;g" /etc/chrony.conf
sed -i "s;server 3.centos.pool.ntp.org iburst;#server 3.centos.pool.ntp.org iburst;g" /etc/chrony.conf
```

启动
```shell
systemctl enable chronyd --now
```

3. 关闭虚拟机主动同步主机时间

以`vCenter`为例

![](images/vcenter-clock.png)

4. 任选主机观察

查看时钟同步情况（定时刷新）
```shell
watch chronyc sourcestats
```

输出格式如下

```
Every 2.0s: chronyc sourcestats                                                                                        Mon Sep 27 20:23:08 2021

210 Number of sources = 1
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
dns.sdly.hsip.gov.cn.165>  24  11   30m     -0.003      0.032   -255ns    21us
```

观察`Offset`那列即可