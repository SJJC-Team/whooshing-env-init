#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "Percona PostgreSQL 初始化"

# 加载环境变量
if [ -f "$ENV_FILE" ]; then source "$ENV_FILE"; fi

# 检查 Vault 是否已解封
log_info "检查 Vault 是否已解封..."
if ! vault status > /dev/null 2>&1; then 
    log_error "错误: Vault 未解封，请先解封 Vault"
    exit 1
fi

log_info "登录 Vault..."
vault login "$WHOOSHING_VAULT_ROOT_TOKEN" > /dev/null 2>&1 || { log_error "发生错误: vault 登陆失败！"; exit 1; }

if ! vault kv get root/woo > /dev/null 2>&1; then 
    log_info "生成新的 Vault 密钥..."
    if ! vault secrets list | grep -q '^root/'; then vault secrets enable -path=root -version=2 kv; fi
    vault kv put root/woo key=$(openssl rand -hex 64)
fi
key=$(vault kv get -field=key root/woo 2>&1) || { log_error "发生错误: 无法获取 Vault 密钥！"; exit 1; }

log_info "创建配置目录..."
ensure_dir "/root/configs" "" ""
cd /root/configs

log_info "下载 Percona Release 包..."
wget "https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb" -O "percona-release_latest.$(lsb_release -sc)_all.deb"

log_info "安装 Percona Release 包..."
sudo dpkg -i "percona-release_latest.$(lsb_release -sc)_all.deb"

log_info "更新包列表..."
sudo apt update

log_info "设置 Percona PostgreSQL 仓库..."
sudo percona-release setup ppg-17

log_info "安装 Percona PostgreSQL 服务器..."
sudo apt install percona-ppg-server-17 -y

log_info "更新环境变量..."
PG_BIN_PATH="/usr/lib/postgresql/17/bin"

if ! grep -q "$PG_BIN_PATH" /etc/profile; then
    echo "export PATH=\$PATH:$PG_BIN_PATH" >> /etc/profile
    source /etc/profile
fi

USER_BASHRC="/home/${WHOOSHING_USER}/.bashrc"
if [ ! -f "$USER_BASHRC" ]; then touch "$USER_BASHRC"; fi

if ! grep -q "$PG_BIN_PATH" "$USER_BASHRC"; then
    # 使用 tee 以 woo 用户身份追加
    echo "export PATH=\$PATH:$PG_BIN_PATH" | sudo -u "$WHOOSHING_USER" tee -a "$USER_BASHRC" > /dev/null
fi

# 设置 woo 用户密码
echo "${WHOOSHING_USER}:$key" | sudo chpasswd

usermod -aG postgres "$WHOOSHING_USER"

log_success "Percona PostgreSQL 初始化 完成"