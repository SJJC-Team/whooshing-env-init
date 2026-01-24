#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

read_integer() {
    local label=$1; local default=$2; local max=$3
    while true; do
        read -p "$label" segment; segment=${segment:-$default}
        if [[ "$segment" =~ ^[0-9]+$ ]] && [ "$segment" -gt 0 ] && [ "$segment" -lt $max ]; then echo $segment; break
        else log_error "请输入一个有效的正整数！(0><$max)"; fi
    done
}

if [[ $1 = -n ]]; then noenter=true; else noenter=false; fi

log_header "Vault 初始化"

# 清理环境变量
for var in WHOOSHING_VAULT_ROOT_TOKEN VAULT_TOKEN VAULT_ADDR; do
    sed -i "/${var}=/d" "$ENV_FILE"
done

# 安装 vault
log_info "安装 vault..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
sudo apt-get update && sudo apt-get install vault -y
log_success "Vault 安装完成"

# 复制配置文件
sudo cp "$SCRIPT_DIR/vault.hcl" "$VAULT_CONFIG_DIR/vault.hcl"
log_success "Vault 配置文件已复制"

# 启动服务
sudo systemctl restart vault
log_success "Vault 服务已重启"

# 初始化
if [[ $noenter = true ]]; then segment=5;
else segment=$(read_integer "主密钥切片数量(5): " 5 100); fi
log_success "你选择的主密钥分片数量是：$segment"

if [[ $noenter = true ]]; then threshold=4;
else threshold=$(read_integer "解密所需的最少切片数量(4): " 4 $segment); fi
log_success "你选择的主密钥最少解密数量是：$threshold"

export VAULT_ADDR="$VAULT_ADDR"
set +e; vault_output=$(vault operator init -key-shares=$segment -key-threshold=$threshold 2>&1)
keys=($(echo "$vault_output" | grep -oP 'Unseal Key \d+: \K[^\n]+'))
root_token=$(echo "$vault_output" | grep -oP 'Initial Root Token: \K.*'); set -e

if [[ ${#keys[@]} != $segment ]] || [[ ! $root_token ]]; then
    log_error "$vault_output"
    exit 1
fi

if [[ $noenter = false ]]; then
    log_info "请记下您的主密钥切片，以及 root 令牌:"
    log_info "Unseal Keys:"; for key in "${keys[@]}"; do echo "$key"; done
    read -p "按回车继续..."
fi

# 解封
for ((i=0; i<$threshold; i++)); do
    log_info "使用密钥 ${keys[$i]} 解封 ($((i+1))/$threshold):"
    vault operator unseal ${keys[$i]}
done
log_success "Vault 已成功解封"

log_info "写入到环境变量"
update_env "WHOOSHING_VAULT_ROOT_TOKEN" "$root_token" "$ENV_FILE"
update_env "VAULT_TOKEN" "$root_token" "$ENV_FILE"
update_env "VAULT_ADDR" "$VAULT_ADDR" "$ENV_FILE"

source "$ENV_FILE"

vault login "$root_token" > /dev/null 2>&1 || { log_error "错误: vault 登陆失败！"; exit 1; }

log_info "设置模块备份引擎..."
vault secrets enable -path="module-bak" -version=2 kv

log_info "安装 medusa (${MEDUSA_VERSION})..."
MEDUSA_DIR="/home/${WHOOSHING_USER}/.medusa"
ensure_dir "$MEDUSA_DIR" "" "" # 权限将在稍后处理

log_info "正在安装 medusa..."
# 使用 pushd/popd 安全切换目录
pushd "$MEDUSA_DIR" > /dev/null
ARCH=$(dpkg --print-architecture)
# 下载 URL: ...
wget "${MEDUSA_BASE_URL}/medusa_${MEDUSA_VERSION#v}_linux_${ARCH}.tar.gz"
mkdir bin
tar -xvf "medusa_${MEDUSA_VERSION#v}_linux_${ARCH}.tar.gz" -C bin
mv bin/medusa "$MEDUSA_DIR/medusa"
rm -rf bin "medusa_${MEDUSA_VERSION#v}_linux_${ARCH}.tar.gz"
chmod +x "$MEDUSA_DIR/medusa"
popd > /dev/null

# 设置所有权和权限
chown -R root:whooshing "$MEDUSA_DIR"
chmod -R 750 "$MEDUSA_DIR"

if [[ $noenter = true ]]; then
    log_success "请记下您的主密钥切片(系统永远不会记录这些密钥切片，如果遗失，你将无法恢复数据)"
    log_info "Unseal Keys:"; for key in "${keys[@]}"; do echo "$key"; done
    read -p "按回车继续..."
fi

log_success "Vault 初始化 完成"