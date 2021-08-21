### gem源配置

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