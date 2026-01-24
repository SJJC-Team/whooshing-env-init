#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "OPA 初始化"

# 检测架构
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
fi

log_info "检测到架构: ${ARCH}"

if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then
    log_error "不支持的架构: ${ARCH}"
    exit 1
fi

# 使用 config.sh 中的 OPA 版本或使用默认值
VERSION="${OPA_VERSION:-v1.12.3}"
DOWNLOAD_URL="https://github.com/open-policy-agent/opa/releases/download/${VERSION}/opa_linux_${ARCH}_static"

log_info "正在下载 OPA ${VERSION} (${ARCH})..."
log_info "URL: ${DOWNLOAD_URL}"

# 下载 OPA
curl -L -o opa "${DOWNLOAD_URL}"

if [ $? -ne 0 ]; then
    log_error "下载失败"
    exit 1
fi

log_info "安装 OPA 到 /usr/local/bin/opa..."
chmod +x opa
sudo mv opa /usr/local/bin/opa

if [ $? -eq 0 ]; then
    log_success "OPA 安装成功"
    log_info "验证版本:"
    /usr/local/bin/opa version

    # 配置 .opa 目录
    log_info "配置 .opa 目录..."
    OPA_DIR="/home/${WHOOSHING_USER}/.opa"
    
    ensure_dir "$OPA_DIR" "${WHOOSHING_USER}:whooshing" "755"

    # 配置环境变量
    log_info "配置环境变量..."
    ENV_FILE="/home/${WHOOSHING_USER}/.env"
    update_env "OPA_REGO_DIR" "$OPA_DIR" "$ENV_FILE"

else
    log_error "安装失败"
    exit 1
fi

log_success "OPA 初始化 完成"
