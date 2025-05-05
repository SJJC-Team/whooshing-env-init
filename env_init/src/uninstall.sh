#!/bin/bash

set -e

# 卸载 percona postgresql
sudo "$(dirname "$0")/uninstall_percona_pgsql.sh"

# 卸载 vault
sudo "$(dirname "$0")/uninstall_vault.sh" -n

# 卸载 vapor
sudo "$(dirname "$0")/uninstall_vapor.sh"

# 卸载 pm2
sudo "$(dirname "$0")/uninstall_pm2.sh"

# 卸载 nvm
sudo "$(dirname "$0")/uninstall_nvm.sh"

# 卸载 nginx
sudo "$(dirname "$0")/uninstall_nginx.sh"

# 降级用户
sudo "$(dirname "$0")/uninstall_host.sh"