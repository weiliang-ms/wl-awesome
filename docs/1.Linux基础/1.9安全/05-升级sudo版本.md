## 升级sudo版本

`CVE-2021-3156`等

- [sudo-1.9.7-3.el7.x86_64.rpm](https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_7p2/sudo-1.9.7-3.el7.x86_64.rpm)

```shell
rpm -Uvh sudo-1.9.7-3.el7.x86_64.rpm
```

验证

```shell
sudo -V
```