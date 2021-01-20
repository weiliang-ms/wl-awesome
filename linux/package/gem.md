<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [配置gem源](#%E9%85%8D%E7%BD%AEgem%E6%BA%90)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 配置gem源

> 查看默认源

```bash
gem sources -l
```    
> 配置代理

修改文件`/usr/bin/gem`

```bash
begin
  args += ['--http-proxy','http://x.x.x.x:port']
  Gem::GemRunner.new.run args
rescue Gem::SystemExitException => e
  exit e.exit_code
end
```
> 修改默认源

```bash
gem sources -r https://rubygems.org/ -a https://gems.ruby-china.com/
bundle config mirror.https://rubygems.org https://gems.ruby-china.com
```


