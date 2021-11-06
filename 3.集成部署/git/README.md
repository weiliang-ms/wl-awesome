## gitlab安装

> 添加源

```bash
$ cat> /etc/yum.repos.d/gitlab-ce.repo<< EOF
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/  
gpgcheck=0
enabled=1
EOF
```

> 安装

```bash
$ yum install curl policycoreutils-python openssh-server gitlab-ce -y
```

> 调整配置

- [精简配置](https://cloud.tencent.com/developer/article/1847435)

调整`/etc/gitlab/gitlab.rb`

- `external_url`(若80被占用建议使用8888)
- 数据目录

```bash
git_data_dirs({
  "default" => {
    "path" => "/data/gitlab/data"
   }
})
```

> 重载配置

```bash
$ gitlab-ctl reconfigure
```

> 启动

```bash
$ gitlab-ctl start
```

> 初始化`root`用户

建立连接，需要大约半分钟左右
```bash
$ gitlab-rails console
```

初始化

```bash
u=User.where(id:1).first
u.password='Gitlab@321'
u.password_confirmation='Gitlab@321'
u.save!
quit
```

## git-cli安装

### 编译安装

```bash
$ curl -L https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.xz -o ./git-2.9.5.tar.xz -k
$ yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker -y
$ tar xvf git-2.9.5.tar.xz

$ cd git-2.9.5
$ ./configure --prefix=/usr/local/git
$ make && make install

$ cat >> ~/.bash_profile <<EOF
PATH=\$PATH:/usr/local/git/bin
EOF

$ . ~/.bash_profile
```

## 重写大的历史提交

使用以下命令可以查看占用空间最多的五个文件：

```shell
weiliang@DESKTOP-O8QG6I5:/mnt/d/github/easyctl$ git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -5 | awk '{print$1}')
"
8d403ce945dc4254dfd9be92febe85ae17fb7276 _output/easyctl
f3872705299ba5846ecd4007669a2d41510d8f4e _output/easyctl
b9d2a6fdd7ad22462245d7f2b030aea145789ac5 easyctl
f9a38dd0d17fb44d6da3661d3eaf5c74ff8b92dd easyctl
b497ec95ee10e51f32af488e5caf47f19b564f29 easyctl
```

`_output/easyctl`、`easyctl`为二进制文件，可以删除


```shell
$ git stash
$ git filter-branch --force --index-filter 'git rm -rf --cached --ignore-unmatch _output/easyctl' --prune-empty --tag-name-filter cat -- --all
```

推送

```shell
$ git push origin master --force
```

清理回收空间

```shell
$ rm -rf .git/refs/original/
$ git reflog expire --expire=now --all
$ git gc --prune=now
```

