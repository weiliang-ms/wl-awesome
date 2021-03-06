## SideCar模式

`SideCar`中文译为边车，是附着在摩托车旁的小型车辆，用于载客。
在编程世界中，其主要功能是将主应用与外围辅助服务进行解耦，提供更灵活的应用部署方式。
其理念符合设计模式中的单一职责原则，让主应用和辅助服务分离，更专注自身功能。

### 使用场景-共享存储

基于`K8S Pod`特性，同一个`Pod`可以共享根容器中挂载的`Volume`。基于该特性，我们可以想到以下`SideCar`应用方式：

> 日志收集上传

我们可以应用日志挂载到共享的`Volume`上，业务容器写日志，`SideCar`容器读日志，并上传日志分析平台，以生产者消费者方式进行解耦。

> 应用`Jar`包挂载

因为`Java`应用需要依赖拥有`Java`运行环境，因此大多使用`open-jdk`等镜像作为基础镜像。
而这类镜像大多上百`M`。通过共享存储，我们可以利用`busybox`这类体积只有几`M`的镜像作为基础镜像，然后将`jar`包拷贝到共享`Volume`下。
并将这个承载`jar`的镜像作为`InitContainer`，主业务容器使用该共享`Volume`下的`jar`包启动业务。
后续应用版本更新，只需要更新`jar`包镜像。这个`jar`包镜像便是一个`SideCar`。

> 
