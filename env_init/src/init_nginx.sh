#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "Nginx 初始化"

log_info "检查 nginx 是否已安装..."
if ! check_command nginx; then
    log_info "nginx 未安装，正在安装 nginx..."
    sudo apt-get update
    sudo apt-get install nginx -y
    log_success "nginx 安装成功"
else
    log_success "nginx 已安装"
fi

log_info "配置 nginx..."
sudo cp "$SCRIPT_DIR/nginx.conf" /etc/nginx/nginx.conf
sudo cp "$SCRIPT_DIR/mime.types" /etc/nginx/mime.types

if [ -d "/etc/nginx_sites" ]; then
    log_info "清理旧的配置目录 /etc/nginx_sites..."
    sudo rm -rf "/etc/nginx_sites"
fi
ensure_dir "/etc/nginx_sites" "" ""

log_info "重启 nginx 服务..."
sudo systemctl restart nginx
log_success "Nginx 初始化 完成"
