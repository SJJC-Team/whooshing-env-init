#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- Vapor 初始化 -------------------${n}"

# 安装 Swiftly
echo -e "${b}正在安装 Swiftly...${n}"

mkdir -p /usr/local/bin/swiftly
mkdir -p /usr/local/swiftly

rm -rf /usr/local/swiftly
cp -r "$(dirname "$0")/swiftly_configs" /usr/local/swiftly

mkdir -p /root/.swiftly
wget -P /root/.swiftly https://github.com/swiftlang/swiftly/releases/download/0.3.0/swiftly-$(uname -m)-unknown-linux-gnu
mv /root/.swiftly/swiftly-$(uname -m)-unknown-linux-gnu /usr/local/bin/swiftly/swiftly
chmod +x /usr/local/bin/swiftly/swiftly

source /usr/local/swiftly/env.sh

echo -e "${b}检查 swiftly 安装路径...${n}"
if [ -d "/usr/local/bin/swiftly" ]; then
    echo -e "${b}swiftly 安装路径存在${n}"
    if [ ! -f /etc/profile.d/swiftly.sh ]; then sudo touch /etc/profile.d/swiftly.sh; fi
    if ! grep -q "/usr/local/bin/swiftly" /etc/profile.d/swiftly.sh; then
        echo -e "${b}将 swiftly 路径添加到系统环境变量中...${n}"
        echo "export PATH=\$PATH:/usr/local/bin/swiftly" | sudo tee -a /etc/profile.d/swiftly.sh
        source /etc/profile.d/swiftly.sh
        echo -e "${g}swiftly 路径已添加${n}"
    else echo -e "${g}swiftly 路径已存在于系统环境变量中${n}"; fi
else
    echo -e "${r}swiftly 安装失败${n}"; exit 1
fi

# 安装 Swift
echo -e "${b}正在安装最新版本的 Swift...${n}"
swiftly install latest

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
    git checkout 18.7.5
    make install
    rm -rf /root/.vapor
    echo -e "${g}Vapor 安装成功${n}"
else echo -e "${g}Vapor 已安装${n}"; fi

echo -e "${b}------------------- Vapor 初始化 完成 -------------------${n}"