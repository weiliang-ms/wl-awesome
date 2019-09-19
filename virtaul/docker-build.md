## 定义转义符 ##

适用于`windows平台`

	# escape=`

	FROM microsoft/nanoserver
	COPY testfile.txt c:\
	RUN dir c:\

## 环境变量 ##

	FROM busybox
	ENV foo /bar
	WORKDIR ${foo}   # WORKDIR /bar
	ADD . $foo       # ADD . /bar
	COPY \$foo /quux # COPY $foo /quux

`${variable_name}`支持bash一些标准：


1. ${variable:-word} variable为空则取word的值


1. ${variable:+word} variable非空则取word的值

**支持环境变量得到docker指令如下：**

1. ADD
2. COPY
3. ENV
4. EXPOSE
5. FROM
6. LABEL
7. STOPSIGNAL
8. USER
9. VOLUME
10. WORKDIR

## 文件忽略 ##

当执行构建`build`时docker-cli会先在指定的上下文目录中，寻找`.dockerignore`文件，docker-cli根据文件内容，排除context的路基目录或文件，随后再将信息发送给docker-daemon

**例子如下：**

	# comment
	*/temp*
	*/*/temp*
	temp?

![](./images/docker_build_ignore.png)

## FROM

**`FROM`可以在一个`Dockerfile`出现多次**

**`ARG`与`FROM`交互**

	ARG  CODE_VERSION=latest
	FROM base:${CODE_VERSION}
	CMD  /code/run-app
	
	FROM extras:${CODE_VERSION}
	CMD  /code/run-extras

**ARG生命周期**

在FROM之前声明的ARG位于构建阶段之外，因此不能在FROM之后的任何指令中使用它。若要使用第一个FROM之前声明的ARG的默认值，请使用构建阶段中没有值的ARG指令

	ARG VERSION=latest
	FROM busybox:$VERSION
	ARG VERSION
	RUN echo $VERSION > image_version