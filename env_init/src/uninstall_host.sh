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
    sudo rm -f /home/woo/.env
    if [ -n "$WHOOSHING_DATA_DIR" ] && [ -d "$WHOOSHING_DATA_DIR" ]; then
        echo -e "${g}备份和清理数据目录${n}"
        mkdir -p $WHOOSHING_DATA_DIR.bak
        mv $WHOOSHING_DATA_DIR $WHOOSHING_DATA_DIR.bak/$(date +%Y%m%d%H%M%S)
    else echo -e "${g}数据目录不存在,跳过备份...${n}"; fi
else echo -e "${b}环境文件不存在, 跳过...${n}"; fi

echo -e "${b}------------------- 用户权限禁用 完成 -------------------${n}"