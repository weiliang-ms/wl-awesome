### StorageClass

[变更default StorageClass](https://blog.csdn.net/engchina/article/details/88529380)

     kubectl patch storageclass <your-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
