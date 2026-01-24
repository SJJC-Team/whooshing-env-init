#!/bin/bash

# Define colors
r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- OPA 初始化 -------------------${n}"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
fi

echo -e "${b}检测到架构: ${ARCH}${n}"

if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then
    echo -e "${r}不支持的架构: ${ARCH}${n}"
    exit 1
fi

OPA_VERSION="v1.12.3"
DOWNLOAD_URL="https://github.com/open-policy-agent/opa/releases/download/${OPA_VERSION}/opa_linux_${ARCH}_static"

echo -e "${b}正在下载 OPA ${OPA_VERSION} (${ARCH})...${n}"
echo -e "${b}URL: ${DOWNLOAD_URL}${n}"

# Download OPA
curl -L -o opa "${DOWNLOAD_URL}"

if [ $? -ne 0 ]; then
    echo -e "${r}下载失败${n}"
    exit 1
fi

echo -e "${b}安装 OPA 到 /usr/local/bin/opa...${n}"
chmod +x opa
sudo mv opa /usr/local/bin/opa

if [ $? -eq 0 ]; then
    echo -e "${g}OPA 安装成功${n}"
    echo -e "${b}验证版本:${n}"
    /usr/local/bin/opa version

    # Configure .opa directory
    echo -e "${b}配置 .opa 目录...${n}"
    OPA_DIR="/home/woo/.opa"
    if [ ! -d "$OPA_DIR" ]; then
        echo -e "${g}创建目录 $OPA_DIR${n}"
        sudo mkdir -p "$OPA_DIR"
        # Assuming run by user 'woo' or similar, but script seems to handle mix of sudo.
        # Ensure woo user owns it if it exists, otherwise keep as is or set wide permissions?
        # init_vault.sh uses 'chown -R root:whooshing'.
        # Safest is to ensure 'woo' owns it if 'woo' exists.
        if id "woo" &>/dev/null; then
             sudo chown -R woo:whooshing "$OPA_DIR"
        fi
    else
        echo -e "${g}目录 $OPA_DIR 已存在${n}"
    fi

    # Configure .env
    ENV_FILE="/home/woo/.env"
    echo -e "${b}配置环境变量...${n}"
    if [ -f "$ENV_FILE" ]; then
        # Remove existing OPA_REGO_DIR lines to prevent duplicates
        sudo sed -i '/OPA_REGO_DIR=/d' "$ENV_FILE"
        echo "OPA_REGO_DIR=$OPA_DIR" | sudo tee -a "$ENV_FILE" > /dev/null
        echo "export OPA_REGO_DIR=$OPA_DIR" | sudo tee -a "$ENV_FILE" > /dev/null
        echo -e "${g}已添加 OPA_REGO_DIR 到 $ENV_FILE${n}"
    else
        echo -e "${r}$ENV_FILE 不存在，跳过环境变量配置${n}"
    fi

else
    echo -e "${r}安装失败${n}"
    exit 1
fi

echo -e "${b}------------------- OPA 初始化 完成 -------------------${n}"
