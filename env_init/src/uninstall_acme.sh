#!/bin/bash

set -e

r='\033[31m'
g='\033[32m'
b='\033[34m'
n='\033[0m'

echo -e "${b}------------------- Acme 卸载 -------------------${n}"

acme_dir="/root/.acme.sh"
rm -rf $acme_dir

echo -e "${b}------------------- Acme 卸载 完成 -------------------${n}"