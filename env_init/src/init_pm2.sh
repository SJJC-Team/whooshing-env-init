#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "Pm2 初始化"

# 确保 NVM 可用
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 使用 config.sh 中的 NODE_VERSION
nvm use "$NODE_VERSION"

log_info "安装 pm2..."
npm install pm2 -g

pm2 jlist
log_success "Pm2 初始化 完成"