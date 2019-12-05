## git安装

### tarball

    curl -L https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.xz -o ./git-2.9.5.tar.xz -k
    yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker -y
    tar xvf git-2.9.5.tar.xz
    
    cd git-2.9.5
    ./configure --prefix=/usr/local/git
    make && make install
    
    cat >> ~/.bash_profile <<EOF
    PATH=\$PATH:/usr/local/git/bin
    EOF
    
    . ~/.bash_profile