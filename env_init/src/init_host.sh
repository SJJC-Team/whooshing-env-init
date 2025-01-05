#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

data_dir=$1

echo -e "${b}------------------- 用户权限初始化 -------------------${n}"

if [ -z "$data_dir" ]; then echo -e "${r}错误: data_dir 未设置。${n}"; exit 1; fi
if [ ! -d "$data_dir" ]; then mkdir -p "$data_dir"; fi

if ! getent group whooshing > /dev/null; then groupadd whooshing; echo -e "${g}组 'whooshing' 已创建。${n}"
else echo -e "${g}组 'whooshing' 已存在。${n}"; fi

echo -e "${g}创建用户 'woo' 并设置权限...${n}"
if ! id -u woo > /dev/null 2>&1; then useradd -m -g woo woo; echo -e "${g}用户 'woo' 已创建${n}"; fi

usermod -aG whooshing woo;
usermod -aG whooshing root
sudo chown -R root:whooshing "$data_dir"
chmod -R 770 "$data_dir"
echo -e "${g}数据目录 '$data_dir' 的所有权已设置为 whooshing 组，且权限设置完成。${n}"

usermod -s /bin/bash woo

echo -e "${g}创建环境配置文件...${n}"
rm -f /home/woo/.env
touch /home/woo/.env && chown root:whooshing /home/woo/.env && chmod 660 /home/woo/.env
echo "export WHOOSHING_DATA_DIR='$data_dir'" >> /home/woo/.env

echo -e "${b}------------------- 用户权限初始化完成 -------------------${n}"
