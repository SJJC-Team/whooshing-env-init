#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_header "Acme 卸载"

log_info "正在删除 acme.sh 安装目录..."
if [ -d "/root/.acme.sh" ]; then
    if confirm_action "是否删除 /root/.acme.sh 及其所有证书 (此操作不可逆)？" "$1"; then
        rm -rf /root/.acme.sh
    fi
fi

log_info "正在删除 certi 配置..."
rm -rf "/etc/certi"
rm -rf "/usr/local/bin/certi"

log_success "Acme 卸载 完成"