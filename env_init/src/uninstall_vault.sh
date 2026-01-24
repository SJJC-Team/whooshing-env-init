#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

if [[ $1 = -n ]]; then noenter="-y"; else noenter=""; fi

log_header "Vault 卸载"

# 检查是否存在 Vault
found=false
if check_command dpkg && dpkg -s vault &>/dev/null; then found=true; fi
if systemctl list-unit-files --type=service | grep -q '^vault.service'; then found=true; fi
if id "vault" &>/dev/null; then found=true; fi
if getent group vault &>/dev/null; then found=true; fi
if [ -d /etc/vault.d ] || [ -d /opt/vault ]; then found=true; fi

if ! $found; then
    log_info "未检测到 Vault 安装或相关文件/用户，跳过卸载。"
else
    log_info "正在卸载 Vault..."

    # 停止并禁用服务（如果存在）
    if systemctl list-unit-files --type=service | grep -q '^vault.service'; then
        if sudo systemctl is-active --quiet vault; then
            sudo systemctl stop vault
        fi
        sudo systemctl disable vault 2>/dev/null || true
    fi

    # 卸载包（如果已安装）
    if check_command dpkg && dpkg -s vault &>/dev/null; then
        sudo apt-get remove --purge vault -y
    else
        log_info "Vault 包未安装，跳过 apt 卸载。"
    fi

    # 删除配置目录（如果存在）
    if [ -d /etc/vault.d ]; then
        if confirm_action "是否删除 Vault 配置目录 (/etc/vault.d)？" "$noenter"; then
            log_info "删除配置目录 /etc/vault.d..."
            sudo rm -rf /etc/vault.d
        fi
    fi

    # 删除用户/组（如果存在）并从组中移除 woo
    if id -nG woo &>/dev/null && id -nG woo | grep -qw vault; then
        sudo gpasswd -d woo vault
    fi
    if id "vault" &>/dev/null; then
        sudo userdel vault
    fi
    if getent group vault &>/dev/null; then
        sudo groupdel vault
    fi

    # 询问是否删除数据目录（如果存在）
    if [ -d /opt/vault ]; then
        if confirm_action "是否删除 Vault 的数据 (/opt/vault)？" "$noenter"; then
            log_info "删除所有 Vault 的数据..."
            sudo rm -rf /opt/vault
        fi
    fi

    sudo systemctl daemon-reload
fi

log_info "删除 medusa..."
if [ -d /home/woo/.medusa ]; then
    if confirm_action "是否删除 medusa 备份工具目录 (/home/woo/.medusa)？" "$noenter"; then
        rm -rf /home/woo/.medusa
    fi
else
    log_info "/home/woo/.medusa 未找到，跳过。"
fi

log_success "Vault 卸载 完成"