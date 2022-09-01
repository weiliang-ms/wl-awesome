## 安装oracle jdk

**该种方式跨平台**

1. 准备安装包：

jdk-8u281-linux-x64.tar.gz

2. 解压

```shell
$ http://192.168.174.80:9998/download/deploy/soft/jdk/jdk-8u281-linux-x64.tar.gz
```

3. 解压安装

```shell
$ tar zxvf jdk-8u281-linux-x64.tar.gz -C /usr/local/
$ echo "JAVA_HOME=/usr/local/jdk1.8.0_281" >> ~/.bash_profile
$ echo "export PATH=\$PATH:/usr/local/jdk1.8.0_281/bin" >> ~/.bash_profile
$ source ~/.bash_profile
```

4. 测试

```shell
$ java -version
java version "1.8.0_281"
Java(TM) SE Runtime Environment (build 1.8.0_281-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.281-b09, mixed mode)
$ java -jar golf-cloud-eureka-1.0.0-SNAPSHOT.jar
2022-08-17 09:45:59.230  INFO 11265 --- [           main] trationDelegate$BeanPostProcessorChecker : Bean 'org.springframework.cloud.autoconfigure.ConfigurationPropertiesRebinderAutoConfiguration' of type [org.springframework.cloud.autoconfigure.ConfigurationPropertiesRebinderAutoConfiguration$$EnhancerBySpringCGLIB$$fe6a1bcc] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.6.RELEASE)

2022-08-17 09:45:59.798  INFO 11265 --- [           main] c.n.g.c.eureka.EurekaServerApplication   : The following profiles are active: dev
2022-08-17 09:46:02.041  WARN 11265 --- [           main] o.s.boot.actuate.endpoint.EndpointId     : Endpoint ID 'service-registry' contains invalid characters, please migrate to a valid format.
2022-08-17 09:46:03.936  WARN 11265 --- [           main] c.n.c.sources.URLConfigurationSource     : No URLs will be polled as dynamic configuration sources.
2022-08-17 09:46:06.416  WARN 11265 --- [           main] c.n.c.sources.URLConfigurationSource     : No URLs will be polled as dynamic configuration sources.
2022-08-17 09:46:08.780  INFO 11265 --- [           main] c.n.g.c.eureka.EurekaServerApplication   : Started EurekaServerApplication in 12.333 seconds (JVM running for 13.134)
```

## 安装openjdk

**预编译包**

1. 安装

```shell
$ yum install -y java-1.8.0-openjdk-devel.x86_64
```

2. 测试

```shell
$ java -version
openjdk version "1.8.0_332"
OpenJDK Runtime Environment (build 1.8.0_332-b09)
OpenJDK 64-Bit Server VM (build 25.332-b09, mixed mode)

$ java -jar golf-cloud-eureka-1.0.0-SNAPSHOT.jar
2022-08-17 09:45:59.230  INFO 11265 --- [           main] trationDelegate$BeanPostProcessorChecker : Bean 'org.springframework.cloud.autoconfigure.ConfigurationPropertiesRebinderAutoConfiguration' of type [org.springframework.cloud.autoconfigure.ConfigurationPropertiesRebinderAutoConfiguration$$EnhancerBySpringCGLIB$$fe6a1bcc] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.6.RELEASE)

2022-08-17 09:45:59.798  INFO 11265 --- [           main] c.n.g.c.eureka.EurekaServerApplication   : The following profiles are active: dev
2022-08-17 09:46:02.041  WARN 11265 --- [           main] o.s.boot.actuate.endpoint.EndpointId     : Endpoint ID 'service-registry' contains invalid characters, please migrate to a valid format.
2022-08-17 09:46:03.936  WARN 11265 --- [           main] c.n.c.sources.URLConfigurationSource     : No URLs will be polled as dynamic configuration sources.
2022-08-17 09:46:06.416  WARN 11265 --- [           main] c.n.c.sources.URLConfigurationSource     : No URLs will be polled as dynamic configuration sources.
2022-08-17 09:46:08.780  INFO 11265 --- [           main] c.n.g.c.eureka.EurekaServerApplication   : Started EurekaServerApplication in 12.333 seconds (JVM running for 13.134)
```