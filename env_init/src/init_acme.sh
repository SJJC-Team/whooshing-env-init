#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

# 注册邮箱，用于接收来自 cloudflare 的域名服务的各种通知
email=$1
# cloudflare API 的 token
token=$2
# cloudflare 的账号 ID
account_id=$3
# cloudflare 的 DNS ID
zone_id=$4
# google 公共证书颁发机构的 Key
google_eab_keyId=$5
# google 公共证书颁发机构的 HMAC 验证码
google_eab_hmac=$6

acme_dir="/root/.acme.sh"
acme="$acme_dir/acme.sh"

echo -e "${b}------------------- Acme 初始化 -------------------${n}"

ask_until_valid() {
    local prompt="$1"
    local validator_func="$2"
    local input
    while true; do
        read -rp "$prompt" input
        if "$validator_func" "$input"; then break
        else echo "❌ 输入不合法，请重新输入。"; fi
    done
    VALID_INPUT="$input"
}

is_valid_email() {
    [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

is_non_empty() {
    [ -n "$1" ]
}

cleanup() {
    echo -e ${r}发生错误，执行清理操作${n}
    rm -rf $acme_dir
    sed -i '/CF_Token=/d' /home/woo/.env
    sed -i '/CF_Account_ID=/d' /home/woo/.env
    sed -i '/CF_Zone_ID=/d' /home/woo/.env
}

if [ -f "$acme" ]; 
    then echo -e ${g}acme.sh 已存在，跳过安装${n} 
else
    trap cleanup ERR
    
    sed -i '/CF_Token=/d' /home/woo/.env
    sed -i '/CF_Account_ID=/d' /home/woo/.env
    sed -i '/CF_Zone_ID=/d' /home/woo/.env

    rm -rf $acme_dir

    if ! is_valid_email "$email"; then
        echo -e ${r}初始化 acme 却没有提供有效的邮箱${n}
        echo -e ${r}提供一个有效邮箱用于接收来自 cloudflare 的域名服务的各种通知${n}
        ask_until_valid "提供邮箱：" is_valid_email
        email="$VALID_INPUT"
    fi

    echo -e ${b}将使用 $email 作为 cloudflare 域名服务通知邮箱${n}

    if [ -z "$token" ] || [ -z "$account_id" ] || [ -z "$zone_id" ]; then
        echo -e ${r}初始化 acme 却没有提供 Cloudflare 的 API 令牌${n}
        echo -e ${r}请前往 Cloudflare 平台获取 DNS 更新权限 "(CF_Token, CF_Account_ID, CF_Zone_ID)"${n}
        ask_until_valid "CF_Token: " is_non_empty; token="$VALID_INPUT"
        ask_until_valid "CF_Account_ID: " is_non_empty; account_id="$VALID_INPUT"
        ask_until_valid "CF_Zone_ID: " is_non_empty; zone_id="$VALID_INPUT"
    fi

    echo -e ${b}Cloudflare API 令牌配置成功${n}

    if [ -z "$google_eab_keyId" ] || [ -z "$google_eab_hmac" ]; then
        echo -e ${r}初始化 acme 却没有提供 Google 公共证书颁发机构的 API 令牌${n}
        echo -e ${r}前往您的 Google 云平台，运行下面的命令以取得 Google 免费公共证书申请的权限并获得密钥 "(eab-keyId, eab-b64MacKey)"${n}
        echo -e ${r}gcloud publicca external-account-keys create${n}
        ask_until_valid "eab-keyId: " is_non_empty; google_eab_keyId="$VALID_INPUT"
        ask_until_valid "eab-b64MacKey: " is_non_empty; google_eab_hmac="$VALID_INPUT"
    fi

    echo -e ${b}Google 公共证书颁发 API 令牌配置成功${n}

    echo -e ${b}正在安装 acme.sh${n}

    curl https://get.acme.sh | sh -s email=$email

    $acme --upgrade --auto-upgrade
    $acme --set-default-ca --server google
    $acme --register-account --server google --eab-kid $google_eab_keyId  --eab-hmac-key $google_eab_hmac

    echo -e ${b}写入环境变量${n}

    echo "CF_Token=$token" >> /home/woo/.env
    echo "export CF_Token=$token" >> /home/woo/.env
    echo "CF_Account_ID=$account_id" >> /home/woo/.env
    echo "export CF_Account_ID=$account_id" >> /home/woo/.env
    echo "CF_Zone_ID=$zone_id" >> /home/woo/.env
    echo "export CF_Zone_ID=$zone_id" >> /home/woo/.env
fi

echo -e "${b}------------------- Acme 初始化 完成 -------------------${n}"