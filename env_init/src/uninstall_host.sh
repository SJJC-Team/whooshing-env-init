#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_header "用户权限禁用"

log_info "降级用户 woo 权限, 移除 woo 的 data 文件夹访问权限"
if id -u woo > /dev/null 2>&1; then usermod -G woo woo; fi

if [ -f "/home/woo/.env" ]; then 
    log_info "发现环境文件 /home/woo/.env"
    source "/home/woo/.env"
    
    sudo rm -f "/home/woo/.env"

    if [ -n "$WHOOSHING_DATA_DIR" ] && [ -d "$WHOOSHING_DATA_DIR" ]; then
        log_info "备份和清理数据目录..."
        mkdir -p "${WHOOSHING_DATA_DIR}.bak"
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        mv "$WHOOSHING_DATA_DIR" "${WHOOSHING_DATA_DIR}.bak/${TIMESTAMP}"
        log_success "数据已备份至 ${WHOOSHING_DATA_DIR}.bak/${TIMESTAMP}"
    else 
        log_info "数据目录不存在, 跳过备份..."
    fi
else 
    log_info "环境文件不存在, 跳过..."
fi

log_info "清理 apt 缓存"
apt-get autoremove -y

log_success "用户权限禁用 完成"