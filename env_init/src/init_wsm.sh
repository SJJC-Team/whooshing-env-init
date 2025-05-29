#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- WSM 初始化 -------------------${n}"

# 定义清理函数
cleanup() {
    echo -e "${b}清理${n}"
    # rm -rf ~/.wsm
    echo -e "${g}清理完成.${n}"
}

# 设置 trap 捕获 EXIT 信号，确保清理函数总会执行
trap cleanup EXIT

source /home/woo/.env

rm -rf ~/.wsm
mkdir ~/.wsm

echo -e "${b}下载 wsm(Whooshing System Manager)...${n}"

wget https://github.com/SJJC-Team/whooshing.system-manager/releases/latest/download/wsm-ubuntu24.04-$(uname -m)-static.tar.gz -O ~/.wsm/wsm-ubuntu24.04-$(uname -m)-static.tar.gz
tar -xzvf ~/.wsm/wsm-ubuntu24.04-$(uname -m)-static.tar.gz -C ~/.wsm

echo -e "${b}安装 wsm${n}"

rm -rf /usr/local/bin/wsm
cp ~/.wsm/wsm /usr/local/bin/wsm
chown root:whooshing /usr/local/bin/wsm
chmod 750 /usr/local/bin/wsm

echo -e "${b}下载 manager 模块...${n}"

wget https://github.com/SJJC-Team/whooshing.system-manager/releases/latest/download/manager-ubuntu24.04-$(uname -m)-static.tar.gz -O ~/.wsm/manager-ubuntu24.04-$(uname -m)-static.tar.gz
tar -xzvf ~/.wsm/manager-ubuntu24.04-$(uname -m)-static.tar.gz -C ~/.wsm

echo -e "${b}配置 manager${n}"

rm -rf "$WHOOSHING_DATA_DIR/.manager/web/bundle"
mkdir -p "$WHOOSHING_DATA_DIR/.manager/web/bundle"
cp ~/.wsm/pm2.config.json "$WHOOSHING_DATA_DIR/.manager/web/bundle/pm2.config.json"
cp ~/.wsm/App "$WHOOSHING_DATA_DIR/.manager/web/bundle/App"

echo -e "${b}正在设置权限${n}"

sudo chown -R root:whooshing "$WHOOSHING_DATA_DIR/.manager"
chmod -R 770 "$WHOOSHING_DATA_DIR/.manager"

echo -e "${b}------------------- WSM 初始化 完成 -------------------${n}"