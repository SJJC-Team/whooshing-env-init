#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

if [[ $1 = -n ]]; then noenter=true; else noenter=false; fi

echo -e "${b}------------------- Vault 卸载 -------------------${n}"

# 检查是否存在 Vault（包、服务、用户、组或配置/数据目录）
found=false
if dpkg -s vault &>/dev/null; then found=true; fi
if systemctl list-unit-files --type=service | grep -q '^vault.service'; then found=true; fi
if id "vault" &>/dev/null; then found=true; fi
if getent group vault &>/dev/null; then found=true; fi
if [ -d /etc/vault.d ] || [ -d /opt/vault ]; then found=true; fi

if ! $found; then
    echo -e "${b}未检测到 Vault 安装或相关文件/用户，跳过卸载。${n}"
else
    echo -e "${b}正在卸载 Vault...${n}"

    # 停止并禁用服务（如果存在）
    if systemctl list-unit-files --type=service | grep -q '^vault.service'; then
        if sudo systemctl is-active --quiet vault; then
            sudo systemctl stop vault
        fi
        sudo systemctl disable vault 2>/dev/null || true
    fi

    # 卸载包（如果已安装）
    if dpkg -s vault &>/dev/null; then
        sudo apt-get remove --purge vault -y
    else
        echo -e "${b}Vault 包未安装，跳过 apt 卸载。${n}"
    fi

    # 删除配置目录（如果存在）
    if [ -d /etc/vault.d ]; then
        sudo rm -rf /etc/vault.d
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
        if [[ $noenter = true ]]; then ans=y
        else
            echo -e -n "${r}删除 Vault 的数据？(y/n): ${n}"
            read -r ans
        fi
        if [[ $ans = y ]]; then
            echo -e "${b}删除所有 Vault 的数据.${n}"
            sudo rm -rf /opt/vault
        else
            echo -e "${b}保留 /opt/vault。${n}"
        fi
    fi

    sudo systemctl daemon-reload
fi

echo -e "${b}删除 medusa...${n}"
if [ -d /home/woo/.medusa ]; then
    rm -rf /home/woo/.medusa
else
    echo -e "${b}/home/woo/.medusa 未找到，跳过。${n}"
fi

echo -e "${b}------------------- Vault 卸载 完成 -------------------${n}"