#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

# 设置用户和数据目录
echo -e "${b}设置用户和数据目录...${n}"
sudo "$(dirname "$0")/init_host.sh"

# 安装 expect
echo -e "${b}检查 expect 是否已安装...${n}"
if ! command -v expect &> /dev/null; then
    echo -e "${b}expect 未安装，正在安装 expect...${n}"
    sudo apt-get update
    sudo apt-get install expect -y
    echo -e "${g}expect 安装成功${n}"
else echo -e "${g}expect 已安装${n}"; fi

# 安装 nvm
echo -e "${b}检查 nvm 是否已安装...${n}"
if command -v nvm &> /dev/null; then
    sudo "$(dirname "$0")/uninstall_nvm.sh"
fi
sudo "$(dirname "$0")/init_nvm.sh"

# 安装 pm2
echo -e "${b}检查 pm2 是否已安装...${n}"
if ! command -v pm2 &> /dev/null; then
    sudo "$(dirname "$0")/init_pm2.sh"
else echo -e "${g}pm2 已安装${n}"; fi

# 安装 vapor
echo -e "${b}检查 vapor 是否已安装...${n}"
if ! command -v vapor &> /dev/null; then
    sudo "$(dirname "$0")/init_vapor.sh"
else echo -e "${g}vapor 已安装${n}"; fi

# 安装 vault
echo -e "${b}检查 vault 是否已安装...${n}"
if ! command -v vault &> /dev/null; then
    sudo "$(dirname "$0")/init_vault.sh" -n
else echo -e "${g}vault 已安装${n}"; fi

# 安装 percona postgresql
sudo "$(dirname "$0")/uninstall_percona_pgsql.sh"
sudo "$(dirname "$0")/init_percona_pgsql.sh"