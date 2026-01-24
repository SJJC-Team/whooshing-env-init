#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/config.sh"

log_header "Acme 初始化"

# 参数
email=$1
token=$2
account_id=$3
zone_id=$4
google_eab_keyId=$5
google_eab_hmac=$6
domain=$7

acme_dir="/root/.acme.sh"
acme="$acme_dir/acme.sh"

# 输入验证的辅助函数
ask_until_valid() {
    local prompt="$1"
    local validator_func="$2"
    local input
    while true; do
        read -rp "$prompt" input
        if "$validator_func" "$input"; then break
        else echo -e "${RED}❌ 输入不合法，请重新输入。${RESET}"; fi
    done
    VALID_INPUT="$input"
}

is_valid_email() {
    [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

is_non_empty() {
    [ -n "$1" ]
}

is_domain() {
    local domain="$1"
    [[ "$domain" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)+$ ]]
}

cleanup_on_error() {
    log_error "发生错误，执行清理操作"
    rm -rf "$acme_dir"
    # 清理环境变量
    for var in CF_Token CF_Account_ID CF_Zone_ID CERTI_NGINX_DIR CERTI_ROOT_DOMAIN; do
        sudo sed -i "/${var}=/d" "$ENV_FILE"
    done
}

if [ -f "$acme" ]; then 
    log_success "acme.sh 已存在，跳过安装" 
else
    trap cleanup_on_error ERR
    
    # 启动前清理环境变量
    for var in CF_Token CF_Account_ID CF_Zone_ID; do
        sudo sed -i "/${var}=/d" "$ENV_FILE"
    done

    rm -rf "$acme_dir"

    # 如果提供的域名无效，则询问用户
    if ! is_domain "$domain"; then
        log_info "请提供一个域名，将作为 whooshing 服务的根域名"
        ask_until_valid "域名：" is_domain
        domain="$VALID_INPUT"
    fi

    log_success "将使用域名 $domain 作为所有 Whooshing 服务的根域名"

    if ! is_valid_email "$email"; then
        log_error "初始化 acme 却没有提供有效的邮箱"
        log_error "提供一个有效邮箱用于接收来自 cloudflare 的域名服务的各种通知"
        ask_until_valid "提供邮箱：" is_valid_email
        email="$VALID_INPUT"
    fi

    log_info "将使用 $email 作为 cloudflare 域名服务通知邮箱"

    if [ -z "$token" ] || [ -z "$account_id" ] || [ -z "$zone_id" ]; then
        log_error "初始化 acme 却没有提供 Cloudflare 的 API 令牌"
        log_error "请前往 Cloudflare 平台获取 DNS 更新权限 (CF_Token, CF_Account_ID, CF_Zone_ID)"
        ask_until_valid "CF_Token: " is_non_empty; token="$VALID_INPUT"
        ask_until_valid "CF_Account_ID: " is_non_empty; account_id="$VALID_INPUT"
        ask_until_valid "CF_Zone_ID: " is_non_empty; zone_id="$VALID_INPUT"
    fi

    log_success "Cloudflare API 令牌配置成功"

    if [ -z "$google_eab_keyId" ] || [ -z "$google_eab_hmac" ]; then
        log_error "初始化 acme 却没有提供 Google 公共证书颁发机构的 API 令牌"
        log_error "前往您的 Google 云平台，运行下面的命令以取得 Google 免费公共证书申请的权限并获得密钥 (eab-keyId, eab-b64MacKey)"
        log_error "gcloud publicca external-account-keys create"
        ask_until_valid "eab-keyId: " is_non_empty; google_eab_keyId="$VALID_INPUT"
        ask_until_valid "eab-b64MacKey: " is_non_empty; google_eab_hmac="$VALID_INPUT"
    fi

    log_success "Google 公共证书颁发 API 令牌配置成功"

    log_info "正在安装 acme.sh"

    curl https://get.acme.sh | sh -s email="$email"

    "$acme" --upgrade --auto-upgrade
    "$acme" --set-default-ca --server google
    "$acme" --register-account --server google --eab-kid "$google_eab_keyId"  --eab-hmac-key "$google_eab_hmac"

    log_info "写入环境变量"
    update_env "CF_Token" "$token" "$ENV_FILE"
    update_env "CF_Account_ID" "$account_id" "$ENV_FILE"
    update_env "CF_Zone_ID" "$zone_id" "$ENV_FILE"
    update_env "WHOOSHING_ROOT_DOMAIN" "$domain" "$ENV_FILE"
    update_env "CERTI_NGINX_DIR" "/etc/nginx_sites" "$ENV_FILE"
    update_env "CERTI_ROOT_DOMAIN" "$domain" "$ENV_FILE"
fi

# 需要 get_bundle_name.sh
BUNDLE_NAME="$("$SCRIPT_DIR/get_bundle_name.sh")"

rm -rf ~/.certi
mkdir ~/.certi

log_info "下载 certi(CloudFlare Certificate)..."
# URL hardcoded in original
wget "https://github.com/SJJC-Team/cloudflare-dns/releases/latest/download/certi-${BUNDLE_NAME}" -O ~/.certi/certi-${BUNDLE_NAME}
tar -xzvf ~/.certi/certi-${BUNDLE_NAME} -C ~/.certi

log_info "安装 certi"

rm -rf /usr/local/bin/certi
rm -rf /etc/certi
mkdir /etc/certi

# 软链接环境文件
ln -s "$ENV_FILE" /etc/certi/env

cp -r ~/.certi/module/bundle/* /etc/certi
echo '#!/bin/bash
/etc/certi/certi "$@"' | sudo tee /usr/local/bin/certi > /dev/null
chown root:whooshing /usr/local/bin/certi
chmod 750 /usr/local/bin/certi

log_success "Acme 初始化 完成"