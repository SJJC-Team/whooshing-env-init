#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "Nvm 初始化"

log_info "1. 清除 NVM_DIR 变量"
unset NVM_DIR

log_info "2. 下载并安装 nvm (${NVM_VERSION})"
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

log_info "3. 复制 nvm.sh 到 /usr/local/bin"
# 复制 nvm 包装脚本
sudo cp "$SCRIPT_DIR/nvm.sh" /usr/local/bin/nvm
sudo chmod +x /usr/local/bin/nvm

log_info "4. 移除旧的 nvm 目录并移动新的 nvm 目录"
# 将 root 安装的 nvm 移动到全局目录
if [ -d "/root/.nvm" ]; then
    sudo rm -rf /usr/local/nvm
    sudo mv /root/.nvm /usr/local/nvm
fi

log_info "5. 安装并使用 Node.js 版本 ${NODE_VERSION}"
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"

log_info "6. 更新用户的 .bashrc 文件"
# 遍历用户
for user_dir in /home/* /root; do
    user_bashrc="$user_dir/.bashrc"
    if [ -f "$user_bashrc" ]; then
        if ! grep -q ". nvm use ${NODE_VERSION}" "$user_bashrc"; then
            log_success "更新 $user_bashrc"
            echo -e "\n. nvm use ${NODE_VERSION}" >> "$user_bashrc"
        fi
        sed -i '/export NVM_DIR=/d' "$user_bashrc"
        sed -i '/# This loads nvm$/d' "$user_bashrc"
        sed -i '/# This loads nvm bash_completion$/d' "$user_bashrc"
    fi
done

log_info "7. 重新加载 /root/.bashrc"
source /root/.bashrc

log_success "Nvm 初始化 完成"