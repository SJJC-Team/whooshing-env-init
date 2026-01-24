#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log_header "Nvm 卸载"

log_info "1. 删除环境变量"
# 只能在当前 shell unset，无法在父 shell unset
unset NVM_DIR NVM_BIN NVM_CD_FLAGS NVM_RC_VERSION

log_info "2. 删除 nvm 工具"
sudo rm -f /usr/local/bin/nvm
sudo rm -rf /usr/local/nvm

log_info "3. 更新用户的 .bashrc 文件"
for user_dir in /home/* /root; do
    user_bashrc="$user_dir/.bashrc"
    if [ -f "$user_bashrc" ]; then
        # 使用 sed 删除我们添加的行
        sed -i '/. nvm use/d' "$user_bashrc"
    fi
done

log_success "Nvm 卸载 完成"