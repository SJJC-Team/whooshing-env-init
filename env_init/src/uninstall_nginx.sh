#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_header "Nginx 卸载"

if systemctl is-active --quiet nginx; then
    log_info "正在停止 Nginx 服务..."
    systemctl stop nginx
fi

if systemctl is-enabled --quiet nginx; then
    log_info "正在禁用 Nginx 服务..."
    systemctl disable nginx
fi

log_info "正在卸载 Nginx 软件包..."
apt-get purge -y nginx

log_info "正在清理配置文件..."
if [ -d "/etc/nginx" ] || [ -d "/var/log/nginx" ]; then
    if confirm_action "是否删除 Nginx 配置文件和日志 (/etc/nginx, /var/log/nginx)？" "$1"; then
        rm -rf /etc/nginx /var/log/nginx /var/cache/nginx
    fi
fi

log_success "Nginx 卸载 完成"