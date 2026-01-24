#!/bin/bash

# 颜色定义
export RED='\033[31m'
export GREEN='\033[32m'
export BLUE='\033[34m'
export RESET='\033[0m'
# 保留简短变量以兼容旧脚本或方便在新脚本中使用
export r=$RED
export g=$GREEN
export b=$BLUE
export n=$RESET

#日志函数
log_info() {
    echo -e "${BLUE}$1${RESET}"
}

log_success() {
    echo -e "${GREEN}$1${RESET}"
}

log_error() {
    echo -e "${RED}$1${RESET}" >&2
}

log_header() {
    echo -e "${BLUE}------------------- $1 -------------------${RESET}"
}

# 检查命令是否存在
check_command() {
    command -v "$1" &> /dev/null
}

# 创建目录并设置权限
ensure_dir() {
    local dir=$1
    local owner=$2
    local perms=$3

    if [ ! -d "$dir" ]; then
        log_info "创建目录: $dir"
        sudo mkdir -p "$dir"
    fi

    if [ -n "$owner" ]; then
        sudo chown -R "$owner" "$dir"
    fi

    if [ -n "$perms" ]; then
        sudo chmod -R "$perms" "$dir"
    fi
}

# 在文件中添加或更新环境变量
update_env() {
    local key=$1
    local value=$2
    local file=$3

    if [ ! -f "$file" ]; then
        log_error "文件 $file 不存在，无法更新环境变量"
        return 1
    fi

    # 删除现有行以避免重复
    sudo sed -i "/^${key}=/d" "$file"
    sudo sed -i "/^export ${key}=/d" "$file"
    
    # 添加新行
    echo "${key}=${value}" | sudo tee -a "$file" > /dev/null
    echo "export ${key}=${value}" | sudo tee -a "$file" > /dev/null
    log_success "已更新 $file: ${key}=${value}"
}

# 确认破坏性操作
# 确认破坏性操作
confirm_action() {
    local message=$1
    local force=$2 # 如果为 "true" 或 "-y"，跳过确认

    if [[ "$force" == "true" || "$force" == "-y" ]]; then
        return 0
    fi

    echo -ne "${RED}${message} (y/N): ${RESET}"
    read -r response
    # 默认为 No (空输入视为 No)
    if [[ -z "$response" ]]; then
        response="n"
    fi
    
    if [[ "$response" != "y" && "$response" != "Y" ]]; then
        log_info "操作已取消，跳过该步骤。"
        return 1
    fi
    return 0
}
