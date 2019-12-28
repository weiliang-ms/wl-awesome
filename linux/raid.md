### raid

查看raid信息

    cat /proc/mdstat
    
卸载raid

    umount /dev/md0
    mdadm -S /dev/md0
    
创建

    mdadm --create /dev/md0 -l 5 -n  