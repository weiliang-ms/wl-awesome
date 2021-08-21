### 配置pip

> 配置源

```shell
mkdir ~/.pip
cat >> ~/.pip/pip.conf <<EOF
[global] 
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
#proxy=http://xxx.xxx.xxx.xxx:8080
[install]
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
```

> 下载包（只下载不安装）

```shell
pip download -d <directory> -r requirement.txt
```

`requirement.txt`格式内容

```shell
scipy
numpy
jupyter
ipython
easydict
Cython
h5py
numpy
mahotas
requests
bs4
lxml
pillow
redis
torch
torchvision
paramiko
pycrypto
uliengineering
matplotlib
keras==2.1.5
web.py==0.40.dev0
scikit-image==0.15.0
lmdb
pandas
opencv-contrib-python==4.0.0.21
tensorflow-gpu==1.8
```

> 安装（离线导出）包

```shell
pip3 install --no-index --find-links=./pip -r requirement.txt
```