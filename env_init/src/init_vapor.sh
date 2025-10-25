#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- Vapor 初始化 -------------------${n}"

# 安装 make 以及 vapor 工具链的编译依赖项
echo -e "${b}正在安装 make...${n}"
apt update
apt install -y make build-essential clang binutils

# 安装 Swiftly
echo -e "${b}正在安装 Swiftly...${n}"

rm -rf /usr/local/swiftly

export SWIFTLY_HOME_DIR="/usr/local/swiftly"
export SWIFTLY_BIN_DIR="/usr/local/swiftly/bin"
export SWIFTLY_TOOLCHAINS_DIR="/usr/local/swiftly/toolchains"
mkdir -p /root/.swiftly
cd /root/.swiftly
curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
tar zxf swiftly-$(uname -m).tar.gz && \
./swiftly init -y --quiet-shell-followup && \
. "${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}/env.sh" && \
hash -r

# 为所有用户设置 swiftly 初始化
echo '. /usr/local/swiftly/env.sh' | sudo tee /etc/profile.d/swiftly.sh
source /root/.profile

# 安装 Swift
echo -e "${b}正在安装最新版本的 Swift...${n}"
swiftly install latest
swiftly link -y

rm -rf /root/.swiftly

# 测试 swift 是否安装
if ! command -v swift &> /dev/null; then echo -e "${r}Swift 安装失败${n}"; exit 1
else echo -e "${g}Swift 安装成功${n}"; fi

# 检查 vapor 是否已安装
echo -e "${b}检查 Vapor 是否已安装...${n}"
if ! command -v vapor &> /dev/null; then
    echo -e "${b}Vapor 未安装，正在安装 Vapor Toolbox...${n}"
    mkdir -p /root/.vapor; cd /root/.vapor
    rm -rf /root/.vapor/toolbox
    git clone https://github.com/vapor/toolbox.git
    cd toolbox
    git fetch --tags && git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
    make install
    rm -rf /root/.vapor
    echo -e "${g}Vapor 安装成功${n}"
else echo -e "${g}Vapor 已安装${n}"; fi

echo -e "${b}------------------- Vapor 初始化 完成 -------------------${n}"