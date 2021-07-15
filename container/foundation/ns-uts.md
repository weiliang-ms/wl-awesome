# UTS命名空间

## 概念

> `UTS namespace`有什么能力？

`UTS`(`UNIX Time-sharing System`) 命名空间提供了主机名（`hostname`）和域名（`/etc/hosts`解析）的隔离。
能够使得子进程有独立的主机名和域名(`hostname`)

这一特性在`Docker`容器技术中被用到，使得`docker`容器在网络上被视作一个独立的节点，而不仅仅是宿主机上的一个进程
    