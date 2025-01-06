#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

if [[ $1 = -n ]]; then noenter=true; else noenter=false; fi

echo -e "${b}------------------- Vault 卸载 -------------------${n}"

echo -e "${b}正在卸载 Vault...${n}"
if sudo systemctl is-active --quiet vault; then sudo systemctl stop vault; fi
sudo apt-get remove --purge vault -y
sudo rm -rf /etc/vault.d

if id -nG woo | grep -qw vault; then sudo gpasswd -d woo vault; fi
if id "vault" &>/dev/null; then sudo userdel vault; fi
if getent group vault &>/dev/null; then sudo groupdel vault; fi

if [[ $noenter = true ]]; then ans=y
else echo -e -n "${r}删除 Vault 的数据？(y/n): ${n}"; read -p "" ans; fi
if [[ $ans = y ]]; then
    echo -e "${b}删除所有 Vault 的数据.${n}"
    sudo rm -rf /opt/vault
fi

sudo systemctl daemon-reload

echo -e "${b}删除 medusa...${n}"
rm -rf /home/woo/.medusa

echo -e "${b}------------------- Vault 卸载 完成 -------------------${n}"