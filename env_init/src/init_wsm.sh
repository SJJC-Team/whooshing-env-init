#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "WSM 初始化"

# 设置退出清理
cleanup() {
    log_info "清理临时文件..."
    rm -rf ~/.wsm
    echo "清理完成."
}
trap cleanup EXIT

# 确保环境变量已加载
if [ -f "$ENV_FILE" ]; then source "$ENV_FILE"; fi
if [ -z "$WHOOSHING_DATA_DIR" ]; then
    log_warn "WHOOSHING_DATA_DIR 未设置，尝试使用默认值 /data/whooshing"
    WHOOSHING_DATA_DIR="/data/whooshing"
fi

BUNDLE_NAME="$("$SCRIPT_DIR/get_bundle_name.sh")"

clean_wsm_temp() {
    rm -rf ~/.wsm
    mkdir ~/.wsm
}
clean_wsm_temp

log_info "下载 wsm (Whooshing System Manager)..."
# 使用 config 中的 WSM_VERSION 或默认值
VERSION="${WSM_VERSION:-2.2.5}"

DOWNLOAD_URL="https://github.com/SJJC-Team/whooshing.system-manager/releases/download/${VERSION}/woo-sys-wsm-${BUNDLE_NAME}"

log_info "下载 URL: $DOWNLOAD_URL"
wget "$DOWNLOAD_URL" -O ~/.wsm/woo-sys-wsm-${BUNDLE_NAME}
tar -xzvf ~/.wsm/woo-sys-wsm-${BUNDLE_NAME} -C ~/.wsm

log_info "安装 wsm"
rm -rf /usr/local/bin/wsm
rm -rf /opt/wsm

# 安装 WSM
mkdir -p /opt/wsm
cp -r ~/.wsm/module/bundle/* /opt/wsm/

echo '#!/bin/bash
/opt/wsm/wsm "$@"' | sudo tee /usr/local/bin/wsm > /dev/null
chown root:whooshing /usr/local/bin/wsm
chmod 750 /usr/local/bin/wsm

log_info "下载 manager 模块..."
MANAGER_URL="https://github.com/SJJC-Team/whooshing.system-manager/releases/download/${VERSION}/woo-sys-manager-${BUNDLE_NAME}"
log_info "Manager URL: $MANAGER_URL"
wget "$MANAGER_URL" -O ~/.wsm/woo-sys-manager-${BUNDLE_NAME}
tar -xzvf ~/.wsm/woo-sys-manager-${BUNDLE_NAME} -C ~/.wsm

log_info "配置 manager"
MANAGER_WEB_DIR="$WHOOSHING_DATA_DIR/.manager/web"
rm -rf "$MANAGER_WEB_DIR"
mkdir -p "$MANAGER_WEB_DIR"
cp -r ~/.wsm/module/bundle "$MANAGER_WEB_DIR/bundle"

log_info "正在设置权限"
MANAGER_DIR="$WHOOSHING_DATA_DIR/.manager"
# 设置管理器权限
sudo chown -R root:whooshing "$MANAGER_DIR"
chmod -R 770 "$MANAGER_DIR"

log_success "WSM 初始化 完成"