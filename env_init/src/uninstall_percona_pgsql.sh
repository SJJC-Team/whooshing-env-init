#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
# source "$SCRIPT_DIR/config.sh" # 如果不使用版本变量，则非必须，但如果不从 config 获取版本，这是一个好习惯

log_header "Percona PostgreSQL 卸载"

log_info "终止 PostgreSQL 服务..."
if systemctl list-units --full -all | grep -Fq 'postgresql.service'; then
    log_info "正在停止 PostgreSQL 服务..."
    sudo systemctl stop postgresql.service
    log_success "服务已终止"
else
    log_success "服务未运行"
fi

log_info "删除 Percona PostgreSQL..."
# 检查软件包是否存在
if dpkg -l 'percona-postgresql-17*' 2>/dev/null | grep -q '^ii'; then
    sudo apt remove percona-postgresql-17* percona-patroni percona-pgbackrest percona-pgbadger percona-pgbouncer -y
    
    log_info "删除 PostgreSQL..."
    sudo apt-get --purge remove postgresql postgresql-* -y
else
    log_success "Percona PostgreSQL 未安装，跳过"
fi

log_info "清除用户..."
if id -nG woo | grep -qw postgres; then sudo gpasswd -d woo postgres; fi
if id "postgres" &>/dev/null; then sudo userdel postgres; fi
if getent group postgres &>/dev/null; then sudo groupdel postgres; fi

# 破坏性操作
if [ -d "/data/percona" ] || [ -d "/etc/postgresql" ]; then
    if confirm_action "是否删除数据目录 /data/percona 和 /etc/postgresql (此操作不可逆)？" "$1"; then
        if [ -d "/data/percona" ]; then
            log_info "正在删除 /data/percona..."
            rm -rf /data/percona
        fi

        if [ -d "/etc/postgresql" ]; then
            log_info "正在删除 /etc/postgresql..."
            rm -rf /etc/postgresql
        fi
    fi
fi

log_success "Percona PostgreSQL 卸载 完成"