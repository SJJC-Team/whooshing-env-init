#!/bin/bash

# 软件版本
export NODE_VERSION="23"
export NVM_VERSION="v0.40.1"
export YQ_VERSION="v4.45.1"
export OPA_VERSION="v1.12.3"
export MEDUSA_VERSION="v0.7.3"
export PERCONA_PG_VERSION="17" # 包名的主版本号

# 路径和 URL - 可以推导或静态指定
export YQ_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" # 架构检测通常在脚本中处理，但如果小心使用也可以在这里通用化
export OPA_BASE_URL="https://github.com/open-policy-agent/opa/releases/download/${OPA_VERSION}"
export MEDUSA_BASE_URL="https://github.com/jonasvinther/medusa/releases/download/${MEDUSA_VERSION}"

# 环境变量
export VAULT_ADDR="http://127.0.0.1:9412"
export VAULT_CONFIG_DIR="/etc/vault.d"
export VAULT_DATA_DIR="/opt/vault"
export WHOOSHING_USER="woo"
export ENV_FILE="/home/${WHOOSHING_USER}/.env"

# 通常这里只放变量。函数放在 utils.sh 中。
