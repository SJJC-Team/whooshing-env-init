#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "Vapor 初始化"

# 安装构建依赖
log_info "正在安装 make 及构建依赖..."
sudo apt update
sudo apt install -y make build-essential clang binutils

# 安装 Swiftly
log_info "正在安装 Swiftly..."

# 清理旧的安装
sudo rm -rf /usr/local/swiftly

export SWIFTLY_HOME_DIR="/usr/local/swiftly"
export SWIFTLY_BIN_DIR="/usr/local/swiftly/bin"
export SWIFTLY_TOOLCHAINS_DIR="/usr/local/swiftly/toolchains"

# 确保临时目录存在
log_info "下载 Swiftly..."
SWIFTLY_TEMP="/root/.swiftly"
ensure_dir "$SWIFTLY_TEMP" "" ""
cd "$SWIFTLY_TEMP"
ARCH=$(uname -m)
curl -O "https://download.swift.org/swiftly/linux/swiftly-${ARCH}.tar.gz"
tar zxf "swiftly-${ARCH}.tar.gz"

log_info "初始化 Swiftly..."
# Run init
./swiftly init -y --quiet-shell-followup

# 加载 swiftly 环境
if [ -f "${SWIFTLY_HOME_DIR}/env.sh" ]; then
    . "${SWIFTLY_HOME_DIR}/env.sh"
else
    # 这里严格遵循原逻辑，如果在 local share 下则加载
    . "$HOME/.local/share/swiftly/env.sh" 2>/dev/null || true
fi
hash -r

# 设置全局 profile
log_info "为所有用户设置 swiftly 初始化..."
echo ". /usr/local/swiftly/env.sh" | sudo tee /etc/profile.d/swiftly.sh > /dev/null
source /root/.profile

# 安装 Swift
log_info "正在安装最新版本的 Swift..."
# 使用完整路径以防万一
if check_command swiftly; then
    swiftly install latest
    swiftly link -y
else
    # 尝试显式路径
    "$SWIFTLY_BIN_DIR/swiftly" install latest
    "$SWIFTLY_BIN_DIR/swiftly" link -y
fi

rm -rf "$SWIFTLY_TEMP"

# 测试 swift
log_info "测试 Swift 安装..."
if ! check_command swift; then
    log_error "Swift 安装失败"
    exit 1
else
    log_success "Swift 安装成功"
fi

# 检查 vapor
log_header "检查 Vapor"
if ! check_command vapor; then
    log_info "Vapor 未安装，正在安装 Vapor Toolbox..."
    VAPOR_TEMP="/root/.vapor"
    ensure_dir "$VAPOR_TEMP" "" ""
    rm -rf "$VAPOR_TEMP/toolbox" 
    
    cd "$VAPOR_TEMP"
    git clone https://github.com/vapor/toolbox.git
    cd toolbox
    # 检出最新标签
    LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
    git fetch --tags && git checkout "$LATEST_TAG"
    
    make install
    cd /
    rm -rf "$VAPOR_TEMP"
    log_success "Vapor 安装成功"
else
    log_success "Vapor 已安装"
fi

log_success "Vapor 初始化 完成"