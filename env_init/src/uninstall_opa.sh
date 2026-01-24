#!/bin/bash

# Define colors
r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- OPA 卸载 -------------------${n}"

if [ -f "/usr/local/bin/opa" ]; then
    echo -e "${b}正在删除 /usr/local/bin/opa...${n}"
    sudo rm -f /usr/local/bin/opa
    
    if [ $? -eq 0 ]; then
        echo -e "${g}OPA 删除成功${n}"
    else
        echo -e "${r}OPA 删除失败${n}"
        exit 1
    fi
else
    echo -e "${g}OPA 未安装 (或不在 /usr/local/bin/opa)${n}"
fi

echo -e "${b}------------------- OPA 卸载 完成 -------------------${n}"
