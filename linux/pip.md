### 配置pip

    mkdir ~/.pip
    cat >> ~/.pip/pip.conf <<EOF
    [global] 
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple
    [install]
    trusted-host = https://pypi.tuna.tsinghua.edu.cn
    EOF