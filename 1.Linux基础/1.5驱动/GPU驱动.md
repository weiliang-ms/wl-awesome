### 卸载nouveau驱动

1. 加入黑名单

```shell
$ echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
```

2. 备份`initramfs`

```shell
mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
```

3. 重建`initramfs`
```shell
$ dracut -v /boot/initramfs-$(uname -r).img $(uname -r) --force
```

4. 重启确认是否`nouveau`已被禁用

```shell
$ reboot
$ lsmod | grep nouveau
```

### 安装Gpu驱动

> 1.查看Gpu版本

```shell
$ yum install -y pciutils
$ lspci | grep NVIDIA
```

执行结果如下

```shell
3b:00.0 3D controller: NVIDIA Corporation GP102GL [Tesla P40] (rev a1)
d8:00.0 3D controller: NVIDIA Corporation GP102GL [Tesla P40] (rev a1)
```

说明版本为`Tesla P40`

> 2.下载驱动

[nvidia驱动](https://www.nvidia.cn/Download/index.aspx?lang=cn)

需要根据`cuda`版本选择，笔者这里`cuda`版本如下:

```shell
$ nvcc -V
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2019 NVIDIA Corporation
Built on Sun_Jul_28_19:07:16_PDT_2019
Cuda compilation tools, release 10.1, V10.1.243
```

下载地址如下：

https://cn.download.nvidia.com/tesla/418.226.00/NVIDIA-Linux-x86_64-418.226.00.run

> 3. 下载cuda

https://developer.nvidia.com/cuda-toolkit-archive

笔者需要下载列表：

- https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run


> 4. 文件确认

此时文件列表：

- NVIDIA-Linux-x86_64-418.226.00.run: GPU驱动文件
- cuda_10.1.105_418.39_linux.run: cuda文件

> 5. 安装依赖

```shell
$ yum -y install kernel-devel kernel-doc kernel-headers gcc gcc-c++
```

> 6. 安装驱动

```shell
$ chmod +x NVIDIA-Linux-x86_64-418.226.00.run
$ ./NVIDIA-Linux-x86_64-418.226.00.run --kernel-source-path=/usr/src/kernels/`uname -r`
```

安装过程：按提示键入交互

安装完毕后，测试显卡驱动

```shell
[root@localhost tmp]# nvidia-smi
Thu Aug 11 02:48:19 2022
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 418.226.00   Driver Version: 418.226.00   CUDA Version: 10.1     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla P40           Off  | 00000000:3B:00.0 Off |                    0 |
| N/A   27C    P0    49W / 250W |      0MiB / 22919MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   1  Tesla P40           Off  | 00000000:D8:00.0 Off |                    0 |
| N/A   25C    P0    49W / 250W |      0MiB / 22919MiB |      2%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

> 7. 安装cuda

```shell
$ chmod +x cuda_10.1.105_418.39_linux.run
$ ./cuda_10.1.105_418.39_linux.run --silent
```

加入PATH

```shell
$ echo "export PATH=\$PATH:/usr/local/cuda-10.1/bin" >> /etc/profile
$ . /etc/profile
```

查看cuda版本

```shell
$ nvcc -V
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2019 NVIDIA Corporation
Built on Fri_Feb__8_19:08:17_PST_2019
Cuda compilation tools, release 10.1, V10.1.105
```

测试

```shell
$ conda create -n yourEnv python=3.6 numpy pandas
$ conda activate yourEnv
$ conda install pytorch==1.6.0 torchvision==0.7.0 cudatoolkit=10.1 -c pytorch
```

测试cuda是否可用

```shell
$ python
>>> import torch
>>> print(torch.cuda.is_available())
True
```
