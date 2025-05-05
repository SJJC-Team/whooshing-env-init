#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- Nginx 初始化 -------------------${n}"

nginxPath=/etc/nginx
wooNginxPath=$nginxPath/whooshing-modules

if command -v nginx >/dev/null 2>&1; then
    echo -e "${g}Nginx 已经安装，跳过安装步骤${n}"
else
    # 更新包管理器并安装 Nginx
    echo -e "${b}更新包管理器...${n}"
    sudo apt update
    echo -e "${b}安装 Nginx...${n}"
    sudo apt install -y nginx
fi

sed -i '/WHOOSHING_NGINX_DIR=/d' /home/woo/.env

echo -e "${b}配置 Nginx 文件${n}"
mkdir -p $wooNginxPath
sudo cp "$(dirname "$0")/mime.types" $nginxPath/mime.types
sudo cp "$(dirname "$0")/nginx.conf" $nginxPath/nginx.conf
chown -R woo:whooshing $nginxPath
chmod -R 700 $nginxPath

echo -e "${b}将 Nginx 配置写入环境变量${n}"
echo "WHOOSHING_NGINX_DIR=$wooNginxPath" >> /home/woo/.env
echo "export WHOOSHING_NGINX_DIR=$wooNginxPath" >> /home/woo/.env
source /home/woo/.env

# 启动 Nginx 服务
echo -e "${b}启动 Nginx 服务${n}"
sudo systemctl restart nginx
sudo systemctl enable nginx

echo -e "${g}Nginx 安装完成！${n}"
echo -e "${b}------------------- Nginx 初始化 完成 -------------------${n}"
