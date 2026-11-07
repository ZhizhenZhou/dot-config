# ssh

## 密钥

```bash
ssh-keygen
```

把 `~/.ssh/id_ed25519.pub` 的内容追加到目标机器的 `~/.ssh/authorized_keys`。
OpenSSH < 9.5 默认生成 RSA，需要 Ed25519 时用 `ssh-keygen -t ed25519`。

## 配置

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
curl -L -o ~/.ssh/config https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/ssh/config.example
$EDITOR ~/.ssh/config
```

`config` 中所有 `<...>` 替换为本机实际值。

## 密码自动填充

无法用公钥登录时见 [ssh-passwordless-setup.md](./ssh-passwordless-setup.md)，覆盖 macOS / Linux / Windows。
仓库附带的 `askpass-keychain.sh` 是其中的 macOS 版实现。
