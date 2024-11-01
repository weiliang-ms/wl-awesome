# nexus3迁移小记

## 跨nexus实例同步指定maven类型repository

> 下载指定 repo 文件

```shell
curFolder=`pwd`
filters=("\\.jar$" "\\.pom$" "\\.zip$")
sourceServer=http://xxx.xxxx.xxx.xxxx:xxxx/nexus
sourceRepo=leaf-releases
sourceUser=xxxx
sourcePassword=xxxxx
logfile=$sourceRepo-backup.log
outputFile=$sourceRepo-artifacts.txt


[ -e $outputFile ] && rm $outputFile

# ======== GET DOWNLOAD URLs =========
url=$sourceServer"/service/rest/v1/assets?repository="$sourceRepo
contToken="initial"
while [ ! -z "$contToken" ]; do
    if [ "$contToken" != "initial" ]; then
        url=$sourceServer"/service/rest/v1/assets?continuationToken="$contToken"&repository="$sourceRepo
    fi
    echo Processing repository token: $contToken | tee -a $logfile
    response=`curl -ksSL -u "$sourceUser:$sourcePassword" -X GET --header 'Accept: application/json' "$url"`
    
    #readarray -t artifacts < < (jq  '[.items[].downloadUrl]' <<< "$response")
    echo "-------------------------------"
    artifacts=`jq  '[.items[].downloadUrl]' <<< "$response"`
    echo "$artifacts"
    echo "-------------------------------"
    printf "%s\n" "${artifacts[@]}" > artifacts.temp
    sed 's/\"//g' artifacts.temp > artifacts1.temp
    sed 's/,//g' artifacts1.temp > artifacts2.temp
    sed 's/[][]//g' artifacts2.temp > artifacts3.temp
    cat artifacts3.temp | grep "$sourceFolder" >> $outputFile
    contToken=( $(echo $response | sed -n 's|.*"continuationToken" : "\([^"]*\)".*|\1|p') )
done


# ======== DOWNLOAD EVERYTHING =========
    echo Downloading artifacts...
    IFS=$'\n' read -d '' -r -a urls < $outputFile
    for url in "${urls[@]}"; do
        url="$(echo -e "${url}" | sed -e 's/^[[:space:]]*//')"
        path=${url#https://*/*/*/}
        dir=""$sourceRepo"/"${path%/*}""
        curFolder=$(pwd)
        mkdir -p $dir
        cd $dir
        url="$(echo -e "${url}" | sed -e 's/\s/%20/g')"
        curl -vks -u "$sourceUser:$sourcePassword" -D response.header -X GET "$url" -O  >> /dev/null 2>&1
        responseCode=`cat response.header | sed -n '1p' | cut -d' ' -f2`
        if [ "$responseCode" == "200" ]; then
            echo Successfully downloaded artifact: $url
        else
            echo ERROR: Failed to download artifact: $url  with error code: $responseCode
        fi
        rm response.header > /dev/null 2>&1
        cd $curFolder
    done
```

> 上传至目标 nexus 对应 repository

**需要修改以下内容：**

- `-u "xxx:xxx"`: 目标 nexus 用户名:密码
- `http://x.x.x.x/nexus/repository/xxx`: 目标 nexus repository 地址

```shell
find . -type f  -not -path '*/\.*' -not -path '*/\^archetype\-catalog\.xml*' -not -path '*/\^maven\-metadata\-local*\.xml' -not -path '*/\^maven\-metadata\-deployment*\.xml' -not -path '*/\.xml' | sed "s|^\./||" | xargs -I '{}' curl -u "xxx:xxx" -X PUT -v -T {} http://x.x.x.x/nexus/repository/xxx/{} ;
```

## 跨nexus实例同步指定npm类型repository

**注意：**需要python环境（建议python3 并安装requests库）

> 批量下载脚本

注意修改以下变量内容:

- url = "http://xxxxx:xxxx/nexus/service/rest/repository/browse/your-npm-repo-name/"
- save_dir = '/opt/nexus/npm-snapshots'

```shell
# coding:utf-8

import os
import re
import requests
from urllib.parse import unquote

def decode_urls(url_list):
    decoded_urls = [unquote(url) for url in url_list]
    return decoded_urls

def download_url(url, save_dir):
    response = requests.get(url)

    if response.status_code == 200:
        # 获取URL的基本路径
        base_url = '/'.join(url.split('/')[:-1])

        # 解析HTML内容
        html_content = response.text

        # 搜索所有链接
        links = find_links(html_content)
        # 遍历链接
        for link in links:
            file_url = base_url +"/"+ link


            # 检查链接是否为目录
            if link.endswith('/'):

                # 创建本地目录
                save_subdir = os.path.join(save_dir, link)
                os.makedirs(save_subdir, exist_ok=True)

                # 递归下载子目录
                download_url(file_url, save_subdir)
            else:
                # 下载文件
                save_file = link.split("/")[-1]
                download_file(link, save_dir+save_file)


def find_links(html_content):
    # 使用正则表达式或HTML解析库解析HTML内容，提取所有链接
    # 例如，可以使用正则表达式 r'<a\s+href=[\'"](.*?)[\'"]\s*>' 来提取链接
    # 返回一个包含所有链接的列表
    # 使用正则表达式匹配链接
    pattern = r'<a\s+href=[\'"](.*?)[\'"]\s*>'
    matches = re.findall(pattern, html_content)
    matches = decode_urls(matches)
    if '../' in matches:
        matches.remove('../')
    print(matches)

    # 返回匹配到的链接列表
    return matches


def download_file(url, save_path):
    response = requests.get(url, stream=True)

    # 检查响应状态码
    if response.status_code == 200:
        with open(save_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)


# 指定下载URL和保存目录
url = "http://xxxxx:xxxx/nexus/service/rest/repository/browse/your-npm-repo-name/"
save_dir = '/opt/nexus/npm-snapshots'

# 创建保存目录（如果不存在）
os.makedirs(save_dir, exist_ok=True)

# 开始下载
download_url(url, save_dir)
```

> 上传脚本

注意修改以下内容:

- url='http://x.x.x.x/nexus/service/rest/v1/components?repository=npm-proxy8888-snapshots'
- directory='/opt/nexus/npm-snapshots'
- username='admin'
- password='123456'

```shell
#!/bin/bash
#需要上传到的仓库url
url='http://x.x.x.x/nexus/service/rest/v1/components?repository=npm-proxy8888-snapshots'
#使用python下载的仓库目录
directory='/opt/nexus/npm-snapshots'
#nexus有上传权限的账户密码
username='admin'
password='123456'

for file in $(find $directory -name "*.tgz"); do
  echo "准备上传${file}文件"
  curl -X POST $url \
    -H 'accept: application/json' \
    -H 'NX-ANTI-CSRF-TOKEN: 0.05104117117544127' \
    -H 'X-Nexus-UI: true' \
    -F "npm.asset=@$file;type=application/x-compressed" \
    -u "$username:$password"
done
```
