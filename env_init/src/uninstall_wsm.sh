#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_header "WSM 卸载"

log_info "删除 wsm..."
rm -rf /usr/local/bin/wsm
rm -rf /opt/wsm

log_success "WSM 卸载 完成"