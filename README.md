# Whooshing 系统环境初始化

在受支持的 Linux 系统上准备系统环境，以安装 Whooshing。将安装的工具有：

- [**Nodejs 23(nvm)**](https://nodejs.org/en/download)
- [**Swift 6.0.3(swiftly)**](https://swiftlang.github.io/swiftly/)
- [**Vapor 18.7.5**](https://docs.vapor.codes/install/linux/)
- [**PM2 5.4.3**](https://pm2.keymetrics.io/)
- [**Vault 1.18.3**](https://developer.hashicorp.com/vault/docs/install)
- [**Percona PostgreSQL 17**](https://percona.github.io/pg_tde/main/install.html)

见[主项目](https://github.com/SJJC-Team/whooshing)

## 部署说明

- **Ubuntu amd64 22.04 +**

运行脚本:

```shell
wget https://raw.githubusercontent.com/SJJC-Team/whooshing-env-init/refs/heads/develop/env_init/init.sh
sudo chmod +x init.sh
sudo ./init.sh
```

部署完成后，您可以使用以下命令检查环境是否正确安装：

```shell
node --version
swift --version
pm2 --version
vapor --version
```

## **联系方式**

* 开发者邮箱：contact@official.whooshings.space

* 项目主页：https://whooshings.space
