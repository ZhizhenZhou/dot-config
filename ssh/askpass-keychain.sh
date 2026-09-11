#!/bin/sh
# 从 macOS Keychain 取出一条通用密码，供 SSH_ASKPASS 使用。
#
# 需要两个环境变量指定取哪条记录（不要在本文件里硬编码账号名）：
#   SSH_KEYCHAIN_ACCOUNT  —— Keychain 的 "账户" 字段，通常是登录用户名
#   SSH_KEYCHAIN_SERVICE  —— Keychain 的 "名称" 字段，通常是服务器别名
#
# 存入密码：
#   security add-generic-password -a <account> -s <service> -w
#
# 见 ssh-passwordless-setup.md 了解 SSH_ASKPASS 的完整接线方式。

security find-generic-password \
    -a "${SSH_KEYCHAIN_ACCOUNT:?set SSH_KEYCHAIN_ACCOUNT}" \
    -s "${SSH_KEYCHAIN_SERVICE:?set SSH_KEYCHAIN_SERVICE}" \
    -w 2>/dev/null
