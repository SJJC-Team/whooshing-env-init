#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- Nginx 卸载 -------------------${n}"

if systemctl is-active --quiet nginx; then
    echo -e "${b}正在停止 Nginx 服务...${n}"
    systemctl stop nginx
fi

if systemctl is-enabled --quiet nginx; then
    echo -e "${b}正在禁用 Nginx 服务...${n}"
    systemctl disable nginx
fi

echo -e "${b}正在卸载 Nginx 软件包...${n}"
apt-get purge -y nginx

echo -e "${b}正在清理配置文件...${n}"
rm -rf /etc/nginx /var/log/nginx /var/cache/nginx

echo -e "${b}------------------- Nginx 卸载 完成 -------------------${n}"