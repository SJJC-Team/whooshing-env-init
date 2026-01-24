#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_header "pm2 卸载"

if check_command nvm; then
    # 通常需要 source nvm.sh
    export NVM_DIR="/usr/local/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    log_info "删除 pm2 工具"
    npm uninstall pm2 -g
else
    log_info "nvm 未安装或无法加载，如有必要请手动卸载 pm2"
fi

if [ -d "$HOME/.pm2" ]; then
    sudo rm -rf ~/.pm2
fi
log_success "pm2 删除成功"

log_success "pm2 卸载 完成"