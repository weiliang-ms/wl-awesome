<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [StorageClass](#storageclass)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### StorageClass

[变更default StorageClass](https://blog.csdn.net/engchina/article/details/88529380)

     kubectl patch storageclass <your-class-name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
