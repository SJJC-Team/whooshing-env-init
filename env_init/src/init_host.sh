#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "用户权限初始化"

data_dir=$1
file_storage_dir=$2

if [ -z "$data_dir" ]; then log_error "错误: data_dir 未设置。"; exit 1; fi
if [ -z "$file_storage_dir" ]; then log_error "错误: file_storage_dir 未设置。"; exit 1; fi

ensure_dir "$data_dir" "" ""
ensure_dir "$file_storage_dir" "" ""

if ! getent group whooshing > /dev/null; then 
    groupadd whooshing
    log_success "组 'whooshing' 已创建。"
else 
    log_success "组 'whooshing' 已存在。"
fi

log_info "创建用户 '${WHOOSHING_USER}' 并设置权限..."
if ! id -u "$WHOOSHING_USER" > /dev/null 2>&1; then 
    useradd -m "$WHOOSHING_USER"
    log_success "用户 '${WHOOSHING_USER}' 已创建"
fi

usermod -aG whooshing "$WHOOSHING_USER"
usermod -aG whooshing root

chown -R "root:whooshing" "$data_dir"
chmod -R 770 "$data_dir"
chown -R "root:whooshing" "$file_storage_dir"
chmod -R 770 "$file_storage_dir"
log_success "数据目录 '$data_dir' 和 '$file_storage_dir' 的所有权已设置为 whooshing 组，且权限设置完成。"

usermod -s /bin/bash "$WHOOSHING_USER"

log_info "创建环境配置文件..."
# 重置环境文件
rm -f "$ENV_FILE"
touch "$ENV_FILE"
chown "root:whooshing" "$ENV_FILE"
chmod 660 "$ENV_FILE"

echo "export WHOOSHING_DATA_DIR=\"$data_dir\"" >> "$ENV_FILE"
echo "export WHOOSHING_FILESTORAGE_ROOT_DIR=\"$file_storage_dir\"" >> "$ENV_FILE"

OWNER_ID=$(id -u root)
echo "export WHOOSHING_FILESTORAGE_OWNER_ID=\"$OWNER_ID\"" >> "$ENV_FILE"

GROUP_ID=$(getent group whooshing | cut -d: -f3)
echo "export WHOOSHING_FILESTORAGE_GROUP_ID=\"$GROUP_ID\"" >> "$ENV_FILE"

echo "export WHOOSHING_FILESTORAGE_RWX=504" >> "$ENV_FILE"

# 再次确保权限正确
chown "root:whooshing" "$ENV_FILE"
chmod 640 "$ENV_FILE"

log_success "用户权限初始化完成"
