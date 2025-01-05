#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- Percona PostgreSQL 初始化 -------------------${n}"

source /home/woo/.env

# 检查 Vault 是否已解封
echo -e "${b}检查 Vault 是否已解封...${n}"
if ! vault status > /dev/null 2>&1; then echo -e "${r}错误: Vault 未解封，请先解封 Vault${n}"; exit 1; fi

echo -e "${b}登录 Vault...${n}"
vault login "$WHOOSHING_VAULT_ROOT_TOKEN" > /dev/null 2>&1 || { echo -e "${r}发生错误: vault 登陆失败！${n}" >&2; exit 1; }
if ! vault kv get root/woo > /dev/null 2>&1; then 
    echo -e "${b}生成新的 Vault 密钥...${n}"
    if ! vault secrets list | grep -q '^root/'; then vault secrets enable -path=root -version=2 kv; fi
    vault kv put root/woo key=$(openssl rand -hex 64)
fi
key=$(vault kv get -field=key root/woo 2>&1) || { echo -e "${r}发生错误: 无法获取 Vault 密钥！${n}" >&2; exit 1; }

echo -e "${g}创建配置目录...${n}"
mkdir -p /root/configs
cd /root/configs

echo -e "${g}下载 Percona Release 包...${n}"
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb

echo -e "${g}安装 Percona Release 包...${n}"
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb

echo -e "${g}更新包列表...${n}"
sudo apt update

echo -e "${g}设置 Percona PostgreSQL 仓库...${n}"
sudo percona-release setup ppg-17

echo -e "${g}安装 Percona PostgreSQL 服务器...${n}"
sudo apt install percona-ppg-server-17 -y
echo -e "${g}更新环境变量...${n}"
if ! grep -q '/usr/lib/postgresql/17/bin' /etc/profile; then
    echo 'export PATH=$PATH:/usr/lib/postgresql/17/bin' >> /etc/profile
    source /etc/profile
fi

if [ ! -f /home/woo/.bashrc ]; then touch /home/woo/.bashrc; fi
if ! grep -q '/usr/lib/postgresql/17/bin' /home/woo/.bashrc; then
    sudo -u woo echo 'export PATH=$PATH:/usr/lib/postgresql/17/bin' >> /home/woo/.bashrc
fi

echo "woo:$key" | sudo chpasswd

usermod -aG postgres woo;

echo -e "${b}------------------- Percona PostgreSQL 初始化 完成 -------------------${n}"