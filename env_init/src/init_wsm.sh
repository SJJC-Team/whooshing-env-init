#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- WSM 初始化 -------------------${n}"

# 定义清理函数
cleanup() {
    echo -e "${b}清理${n}"
    # rm -rf ~/.wsm
    echo -e "${g}清理完成.${n}"
}

# 设置 trap 捕获 EXIT 信号，确保清理函数总会执行
trap cleanup EXIT

source /home/woo/.env




LABEL="swift"
SWIFT_VERSION="6.1"

set - e

# ------------------------------------------------

# Expand system name and version
OS_NAME=""
OS_VERSION=""

UNAME_S=$(uname -s)

case "$UNAME_S" in
  Darwin)
    # macOS or iOS (simulator or device via cross-compile)
    if [[ "$(uname -m)" == "x86_64" || "$(uname -m)" == "arm64" ]]; then
      PRODUCT_NAME=$(sw_vers -productName)
      PRODUCT_VERSION=$(sw_vers -productVersion)
      if [[ "$PRODUCT_NAME" == "macOS" || "$PRODUCT_NAME" == "Mac OS X" ]]; then
        OS_NAME="macos"
        OS_VERSION="$PRODUCT_VERSION"
      else
        OS_NAME="ios"  # fallback
        OS_VERSION="unknown"
      fi
    fi
    ;;
  Linux)
    # Check for Ubuntu, Debian, etc.
    if command -v lsb_release >/dev/null 2>&1; then
      OS_NAME=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
      OS_VERSION=$(lsb_release -rs)
    elif [ -f /etc/os-release ]; then
      # Fallback for containers or Alpine
      . /etc/os-release
      OS_NAME=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
      OS_VERSION=$VERSION_ID
    else
      OS_NAME="linux"
      OS_VERSION="unknown"
    fi
    ;;
  *)
    OS_NAME="unknown"
    OS_VERSION="unknown"
    ;;
esac

# Format with underscores and lowercase
OS_NAME_CLEAN=$(echo "$OS_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
OS_VERSION_CLEAN=$(echo "$OS_VERSION" | tr '[:upper:]' '[:lower:]' | tr '.' '-')

OS="${OS_NAME_CLEAN}-${OS_VERSION_CLEAN}"

# ------------------------------------------------

ARCH=$(uname -m)
BUNDLE_NAME="${OS}-${ARCH}-${LABEL}-${SWIFT_VERSION}.tar.gz"





rm -rf ~/.wsm
mkdir ~/.wsm

echo -e "${b}下载 wsm(Whooshing System Manager)...${n}"

wget https://github.com/SJJC-Team/whooshing.system-manager/releases/latest/download/woo-sys-wsm-${BUNDLE_NAME} -O ~/.wsm/woo-sys-wsm-${BUNDLE_NAME}
tar -xzvf ~/.wsm/woo-sys-wsm-${BUNDLE_NAME} -C ~/.wsm

echo -e "${b}安装 wsm${n}"

rm -rf /usr/local/bin/wsm
rm -rf /opt/wsm
mkdir /opt/wsm
cp -r ~/.wsm/wsm /opt
echo '#!/bin/bash
/opt/wsm/wsm "$@"' | sudo tee /usr/local/bin/wsm > /dev/null
chown root:whooshing /usr/local/bin/wsm
chmod 750 /usr/local/bin/wsm

echo -e "${b}下载 manager 模块...${n}"

wget https://github.com/SJJC-Team/whooshing.system-manager/releases/latest/download/woo-sys-manager-${BUNDLE_NAME} -O ~/.wsm/woo-sys-manager-${BUNDLE_NAME}
tar -xzvf ~/.wsm/woo-sys-manager-${BUNDLE_NAME} -C ~/.wsm

echo -e "${b}配置 manager${n}"

rm -rf "$WHOOSHING_DATA_DIR/.manager/web"
mkdir -p "$WHOOSHING_DATA_DIR/.manager/web"
cp -r ~/.wsm/bundle "$WHOOSHING_DATA_DIR/.manager/web/bundle"

echo -e "${b}正在设置权限${n}"

sudo chown -R root:whooshing "$WHOOSHING_DATA_DIR/.manager"
chmod -R 770 "$WHOOSHING_DATA_DIR/.manager"

echo -e "${b}------------------- WSM 初始化 完成 -------------------${n}"