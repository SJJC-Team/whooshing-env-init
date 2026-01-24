#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_header "OPA 卸载"

OPA_BIN="/usr/local/bin/opa"

if [ -f "$OPA_BIN" ]; then
    log_info "正在删除 $OPA_BIN..."
    sudo rm -f "$OPA_BIN"
    log_success "OPA 删除成功"
else
    log_info "OPA 未安装 (或不在 $OPA_BIN)"
fi

# 不删除 .opa 目录，按需保留
log_info "保留 .opa 配置目录 (如存在)"

log_success "OPA 卸载 完成"
