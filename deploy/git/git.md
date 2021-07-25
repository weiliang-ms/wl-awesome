## gitlab安装

> 添加源

```shell script
cat> /etc/yum.repos.d/gitlab-ce.repo<< EOF
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/  
gpgcheck=0
enabled=1
EOF
```

> 安装

```shell script
yum install curl policycoreutils-python openssh-server gitlab-ce -y
```

> 调整配置

- [精简配置](https://cloud.tencent.com/developer/article/1847435)

调整`/etc/gitlab/gitlab.rb`

- `external_url`(若80被占用建议使用8888)
- 数据目录

```shell script
git_data_dirs({
  "default" => {
    "path" => "/data/gitlab/data"
   }
})
```

> 重载配置

```shell script
gitlab-ctl reconfigure
```

> 启动

```shell script
gitlab-ctl start
```

> 初始化`root`用户

建立连接，需要大约半分钟左右
```shell script
gitlab-rails console
```

初始化

```shell script
u=User.where(id:1).first
u.password='Gitlab@321'
u.password_confirmation='Gitlab@321'
u.save!
quit
```

## git-cli安装

### 编译安装

```shell script
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
```