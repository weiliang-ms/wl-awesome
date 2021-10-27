## choco

管理员运行`cmd`，执行

```bash
@powershell -NoProfile -ExecutionPolicy Bypass -Command 
       "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=
       %PATH
       %;
       %ALLUSERSPROFILE
       %\chocolatey\bin
```