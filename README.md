# Whooshing 系统环境初始化

在受支持的 Linux 系统上准备系统环境，以安装 Whooshing。将安装的工具有：

- [**Nodejs 23(nvm)**](https://nodejs.org/en/download)
- [**Swift 6.1.0(swiftly)**](https://swiftlang.github.io/swiftly/)
- [**Vapor 19.1.1**](https://docs.vapor.codes/install/linux/)
- [**PM2 6.0.5**](https://pm2.keymetrics.io/)
- [**Vault 1.18.3**](https://developer.hashicorp.com/vault/docs/install)
- [**Percona PostgreSQL 17.4**](https://percona.github.io/pg_tde/main/install.html)
- [**Nginx 1.28.0**](https://nginx.org/en/docs/install.html)


见[主项目](https://github.com/SJJC-Team/whooshing)

## 部署说明

- **Ubuntu 22.04 +**

在 root 环境下运行脚本:

```shell
(bash -c 'wget https://raw.githubusercontent.com/SJJC-Team/whooshing-env-init/refs/heads/develop/env_init/init.sh && chmod +x init.sh && ./init.sh'); rm -f init.sh
```
以上会创建默认的 whooshing 数据目录，位于 ```/whooshing```, 若你想使用不同的数据目录，可以改为运行 ```sudo ./init.sh /path/to/data_dir```

部署完成后，您可以使用以下命令检查环境是否正确安装：

```shell
node --version; echo ------------------
swift --version; echo ------------------
pm2 --version; echo ------------------
vapor --version; echo ------------------
psql --version; echo ------------------
vault --version; echo ------------------
nginx -version
```

## **联系方式**

* 开发者邮箱：contact@official.whooshings.space

* 项目主页：https://whooshings.space
