#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- Percona PostgreSQL 卸载 -------------------${n}"

echo -e "${b}终止 PostgreSQL 服务...${n}"
if systemctl list-units --full -all | grep -Fq 'postgresql.service'; then
    echo -e "${b}Stopping PostgreSQL service...${n}"
    sudo systemctl stop postgresql.service
    echo -e "${g}服务已终止${n}"
else
    echo -e "${g}服务未运行${n}"
fi

echo -e "${b}删除 Percona PostgreSQL...${n}"
# 先检查是否有 percona-postgresql 包存在，若不存在则跳过
if dpkg -l 'percona-postgresql-17*' 2>/dev/null | grep -q '^ii'; then
    sudo apt remove percona-postgresql-17* percona-patroni percona-pgbackrest percona-pgbadger percona-pgbouncer -y

    echo -e "${b}删除 PostgreSQL...${n}"
    sudo apt-get --purge remove postgresql postgresql-* -y
else
    echo -e "${g}Percona PostgreSQL 未安装，跳过${n}"
fi

echo -e "${b}清除用户和数据目录...${n}"
if id -nG woo | grep -qw postgres; then sudo gpasswd -d woo postgres; fi
if id "postgres" &>/dev/null; then sudo userdel postgres; fi
if getent group postgres &>/dev/null; then sudo groupdel postgres; fi
rm -rf /data/percona
rm -rf /etc/postgresql
echo -e "${b}完成${n}"

echo -e "${b}------------------- Percona PostgreSQL 卸载 完成 -------------------${n}"