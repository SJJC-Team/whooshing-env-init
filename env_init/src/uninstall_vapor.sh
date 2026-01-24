#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_header "Vapor 卸载"

log_info "正在卸载 Vapor..."
sudo rm -f /usr/local/bin/vapor
sudo rm -rf /root/configs/toolbox
sudo rm -rf /root/.vapor
log_success "Vapor 卸载成功"

log_info "正在卸载 Swiftly..."
sudo rm -rf /usr/local/swiftly
sudo rm -f /etc/profile.d/swiftly.sh
log_success "Swiftly 卸载成功"

log_success "Vapor 卸载 完成"