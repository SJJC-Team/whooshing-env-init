#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- 用户权限禁用 -------------------${n}"

echo -e "${g}降级用户 woo 权限, 移除 woo 的 data 文件夹访问权限${n}"
if id -u woo > /dev/null 2>&1; then usermod -G woo woo; fi

if [ -f /home/woo/.env ]; then 
    source /home/woo/.env
    echo -e "${g}备份数据目录${n}"
    mkdir -p $WHOOSHING_DATA_DIR.bak
    mv $WHOOSHING_DATA_DIR $WHOOSHING_DATA_DIR.bak/$(date +%Y%m%d%H%M%S)
    sudo rm -f /home/woo/.env
else echo -e "${b}/home/woo/.env 文件不存在, 跳过...${n}"; fi

echo -e "${b}------------------- 用户权限禁用 完成 -------------------${n}"