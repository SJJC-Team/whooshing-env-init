#!/bin/bash

# init.sh - Bootstrapper script for Whooshing Environment Initialization
# 这是一个引导脚本，用于克隆仓库并执行初始化。

set -e

# 定义颜色 (与 utils.sh 保持一致，但独立定义以确保无需依赖即可运行)
RED='\033[31m'
GREEN='\033[32m'
BLUE='\033[34m'
RESET='\033[0m'

log_info() {
    echo -e "${BLUE}$1${RESET}"
}

log_success() {
    echo -e "${GREEN}$1${RESET}"
}

data_dir=${1:-/data/whooshing}
file_storage_dir=${2:-/data/file_storage}

# 定义清理函数
cleanup() {
    log_info "正在清理..."
    sudo rm -rf /root/.whooshing
    log_success "清理完成"
}

# 设置 trap 捕获 EXIT 信号，确保清理函数总会执行
trap cleanup EXIT

log_info "准备工作环境..."
sudo rm -rf /root/.whooshing
sudo mkdir -p /root/.whooshing
cd /root/.whooshing

log_info "正在克隆仓库..."
# 注意：这里克隆的是 main 分支，如果当前开发是在其他分支，可能无法拉取到最新的更动
#但在 refactoring 场景下，我们假设 user 会提交更改
git clone https://github.com/SJJC-Team/whooshing-env-init.git
cd whooshing-env-init/env_init

# 授权 src 文件夹中的所有 sh 文件
log_info "正在授权 src 文件夹中的所有 sh 文件..."
find src -type f -name "*.sh" -exec chmod +x {} \;
log_success "授权完成"

log_info "运行卸载程序..."
if [ -f "src/uninstall.sh" ]; then
    sudo src/uninstall.sh
else
    echo -e "${RED}错误: 找不到 src/uninstall.sh${RESET}"
    exit 1
fi

log_info "运行初始化程序..."
if [ -f "src/init_all.sh" ]; then
    sudo src/init_all.sh "$data_dir" "$file_storage_dir"
else
    echo -e "${RED}错误: 找不到 src/init_all.sh${RESET}"
    exit 1
fi

log_success "环境初始化完成"
