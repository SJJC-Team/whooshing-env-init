#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

data_dir=$1

echo -e "${b}------------------- 用户权限禁用 -------------------${n}"

echo -e "${g}降级用户 woo 权限, 移除 woo 的 data 文件夹访问权限${n}"
if id -u woo > /dev/null 2>&1; then usermod -G woo woo; fi

echo -e "${b}------------------- 用户权限禁用 完成 -------------------${n}"