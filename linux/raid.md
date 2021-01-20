<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [raid](#raid)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### raid

查看raid信息

    cat /proc/mdstat
    
卸载raid

    umount /dev/md0
    mdadm -S /dev/md0
    
创建

    mdadm --create /dev/md0 -l 5 -n  