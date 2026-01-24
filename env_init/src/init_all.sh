#!/bin/bash
# 重构后的 init_all.sh

# 解析脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

set -e

log_header "Whooshing 环境初始化"

data_dir=${1:-/data/whooshing}
file_storage_dir=${2:-/data/file_storage}

# 设置用户和数据目录
log_header "设置用户和数据目录"
sudo "$SCRIPT_DIR/init_host.sh" "$data_dir" "$file_storage_dir"

# 安装 acme
log_header "安装 ACME"
sudo "$SCRIPT_DIR/init_acme.sh" "$data_dir"

# 安装 expect
log_header "安装 Expect"
if ! check_command expect; then
    log_info "正在安装 expect..."
    sudo apt-get update
    sudo apt-get install expect -y
    log_success "expect 安装成功"
else
    log_success "expect 已安装"
fi

# 安装 yq
log_header "安装 YQ"
log_info "正在安装 yq..."
# 使用 dpkg 动态检测架构
ARCH=$(dpkg --print-architecture)
YQ_DL_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}"
wget "$YQ_DL_URL" -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq
sudo apt install yamllint -y

# 安装 nvm
log_header "安装 NVM"
if check_command nvm; then
    # 如果 nvm 已存在，先卸载以确保干净安装（沿用原有逻辑）
    sudo "$SCRIPT_DIR/uninstall_nvm.sh"
fi
sudo "$SCRIPT_DIR/init_nvm.sh"

# 安装 pm2
log_header "安装 PM2"
if ! check_command pm2; then
    sudo "$SCRIPT_DIR/init_pm2.sh"
else
    log_success "pm2 已安装"
fi

# 安装 OPA
log_header "安装 OPA"
if ! check_command opa; then
    sudo "$SCRIPT_DIR/init_opa.sh"
else
    log_success "opa 已安装"
fi

# 安装 vault
log_header "安装 Vault"
if ! check_command vault; then
    sudo "$SCRIPT_DIR/init_vault.sh" -n
else
    log_success "vault 已安装"
fi

# 安装 percona postgresql
log_header "安装 Percona PostgreSQL"
# 保持原有逻辑：先卸载再安装
sudo "$SCRIPT_DIR/uninstall_percona_pgsql.sh"
sudo "$SCRIPT_DIR/init_percona_pgsql.sh"

# 安装 nginx
log_header "安装 Nginx"
sudo "$SCRIPT_DIR/init_nginx.sh"

# 安装 vapor
log_header "安装 Vapor"
if ! check_command vapor; then
    sudo "$SCRIPT_DIR/init_vapor.sh"
else
    log_success "vapor 已安装"
fi

# 安装 wsm
log_header "安装 WSM"
sudo "$SCRIPT_DIR/init_wsm.sh"

log_header "环境初始化完成"