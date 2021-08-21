镜像体积小的优势：传输快、加载快、

1、根据场景选取基础镜像

	jdk -> 选取openjdk镜像作为基础镜像 非不是centos ubuntu等操作系统镜像

2、利用`multistage-build`

	Use multistage builds. 
	For instance, you can use the maven image to build your Java application,
	then reset to the tomcat image and copy the Java artifacts into the correct location to deploy your app, 
	all in the same Dockerfile. This means that your final image doesn’t include all of the libraries and dependencies pulled in by the build, 
	but only the artifacts and the environment needed to run them.


	#以下整个流程在一个Dockerfile内实现
	1、选取maven基础镜像进行打包JAVA程序
	2、拷贝Jar至tomcat基础镜像内（spring boot的话直接jdk基础镜像）
	3、发布


**`multistage-build`**样例

	FROM golang:1.7.3
	WORKDIR /go/src/github.com/alexellis/href-counter/
	RUN go get -d -v golang.org/x/net/html  
	COPY app.go .
	RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
	
	FROM alpine:latest  
	RUN apk --no-cache add ca-certificates
	WORKDIR /root/
	COPY --from=0 /go/src/github.com/alexellis/href-counter/app .
	CMD ["./app"]  

显然，只是把多个步骤合并到同一Dockfile呢，降低构造镜像成本。

3、减少层级

**场景一**

	合并命令，每一行命令均产生一个层级

	#合并前
	RUN apt-get -y update
	RUN apt-get install -y python

	#合并后
	RUN apt-get -y update && apt-get install -y python

**场景二**

	#制作适合自己的基础镜像（适用于多个application场景，并且基础层级相同较多的）
	Docker only needs to load the common layers once, and they are cached. 
	This means that your derivative images use memory on the Docker host more efficiently and load more quickly

**场景**
	
	由于测试镜像的话，可能需要安装一些测试软件等，保证两者的区别处于镜像最高层级（还是为了充分复用相同层级）

	To keep your production image lean but allow for debugging, consider using the production image as the base image for the debug image. Additional testing or debugging tooling can be added on top of the production image
	
**场景四**

制作镜像时，打上tag标签

	When building images, always tag them with useful tags which codify version information, intended destination (prod or test, for instance), stability,
	or other information that is useful when deploying the application in different environments. 
	Do not rely on the automatically-created latest tag

4、程序数据持久化问题

	#避免将数据写入容器内部，这样不仅会增加容器体积，并且I/O读写效率比挂载模式要低
	
	Avoid storing application data in your container’s writable layer using storage drivers. This increases the size of your container and is less efficient from an I/O perspective than using volumes or bind mounts.









		

	
	
	