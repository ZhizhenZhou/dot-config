# ssh-config

## Import config
Generating Keys (OpenSSH >= 9.5 直接 `ssh-keygen` 默认就是 Ed25519):
```
ssh-keygen
```
> 更老的 OpenSSH（< 9.5）默认生成 RSA 3072，如需 Ed25519 请显式 `ssh-keygen -t ed25519`。
Then append local `~/.ssh/id_ed25519.pub`（老系统则是 `id_rsa.pub`）to remote file `~/.ssh/authorized_keys`.

Import configuration. `config.example` 是模板，复制后替换掉所有 `<...>`（新机器没有 `~/.ssh` 目录，先创建并收紧权限）：
```
mkdir -p ~/.ssh && chmod 700 ~/.ssh
curl -L -o ~/.ssh/config https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/ssh/config.example
$EDITOR ~/.ssh/config
```

### 优先用公钥登录
上面 `ssh-keygen` + `authorized_keys` 这条路是首选：无密码可泄露、可被 `ssh-agent` 托管、换机器只需搬公钥。仓库里**不要**放任何需要密码登录的凭据。

### SSH 免密登录（密码自动填充）— 仅在无法用公钥时
某些机器（共享账号、没权限写 `authorized_keys`）只能用密码。这时用 `SSH_ASKPASS` 把密码交给系统级安全存储（macOS Keychain / GNOME Keyring / Windows DPAPI），而不是写在脚本或 dotfile 里。

需要 `askpass-keychain.sh`（从 macOS Keychain 取密码），并在 `~/.zshenv` 里设置两个环境变量（Keychain 记录的账户名与服务名）：
```
curl -L -o ~/.ssh/askpass-keychain.sh https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/ssh/askpass-keychain.sh
chmod 700 ~/.ssh/askpass-keychain.sh
export SSH_KEYCHAIN_ACCOUNT=<账户名> SSH_KEYCHAIN_SERVICE=<服务名>   # 放进 ~/.zshenv
```

详情见 [ssh-passwordless-setup.md](./ssh-passwordless-setup.md)（通用指南，支持 macOS / Linux / Windows）。
