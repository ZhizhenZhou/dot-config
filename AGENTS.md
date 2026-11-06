# 给 agent 的说明

本仓库是这台机器的环境引导：zsh、neovim、ssh。各目录的 README 是权威细节，
这里只写**目标和验收**，具体怎么装由你按平台判断。

## 平台

macOS / Linux(WSL)。Windows 不支持。需要 `curl`、`git`、`tar`；macOS 另需 Xcode CLT。

## 安装顺序

1. **zsh**：`zsh/install.sh`（前置：oh-my-zsh 已安装、`~/.zshrc` 已存在）
2. **neovim**：用当前平台最合适的方式装**最新版**——macOS 上有 brew 就用
   `brew install neovim`，否则用官方 release 的 tarball 或系统包。
   没有 agent 的机器可以用 `neovim/neovim-install.sh` 兜底。
3. **接入**：`neovim/nvim_config.sh`（写 `EDITOR` / `VISUAL` 与 `vim` / `vi` alias）
4. **ssh**：把 `ssh/config.example` 复制成 `~/.ssh/config`。占位符 `<...>` 必须由本人填写，**不要猜**

## 验收

- `nvim --version` ≥ 0.12（配置依赖 nvim-treesitter 的 `main` 分支）。
  不达标就换掉，不要改配置去迁就它：brew 装的 `brew upgrade neovim`；
  tarball 装的用 `NVIM_VERSION=latest` 重跑 `neovim/neovim-install.sh`
- PATH 上只有一份 `nvim`（`command -v nvim` 与 `nvim --version` 指向同一处）
- `zsh -lic true` 不报错

## 不要做

- 不要提交真实的 SSH 配置、密钥、代理端口、账号
- 不要制造第二份 neovim 安装
- 拿不准时先读对应目录的 README，不要凭猜测拼下载地址
