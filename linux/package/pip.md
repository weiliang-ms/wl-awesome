### 配置pip

> 配置源

    mkdir ~/.pip
    cat >> ~/.pip/pip.conf <<EOF
    [global] 
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple
    [install]
    trusted-host = https://pypi.tuna.tsinghua.edu.cn
    EOF
    
> 下载包（只下载不安装）

    pip download -d <directory> -r requirement.txt
    
`requirement.txt`格式内容

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
    
> 安装（离线导出）包

    pip3 install --no-index --find-links=./pip -r requirement.txt

    