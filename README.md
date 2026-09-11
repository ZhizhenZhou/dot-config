# ZZZ's computer configuration.

macOS / Linux(WSL) 个人环境的引导配置：zsh、neovim、ssh。
每个组件一条命令完成安装，脚本幂等，可重复执行。

> **安全模型**：仓库只存**模板**（`*.example`）和**通用脚本**。
> 真实主机名、账号、密钥一律留在本机，不进 git —— 由根目录 `.gitignore` 强制。

## 仓库结构

```
├── zsh/          zsh + oh-my-zsh：插件、自定义主题、一键安装脚本
├── neovim/       neovim 依赖安装脚本（配置本体在另一个仓库）
├── ssh/          ssh 配置模板、SSH_ASKPASS 免密方案、跨平台密码存储指南
└── .gitignore    阻止真实 ssh 配置与密钥材料入库
```

## Quick start

### zsh（前置：oh-my-zsh 已安装，见 [zsh/README.md](./zsh/README.md)）

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/zsh/install.sh)"
```

安装内容：`zsh-autosuggestions`、`zsh-syntax-highlighting` 插件 + 自定义主题 `zzz`，
并改写 `~/.zshrc` 的 `ZSH_THEME` 与 `plugins=` 两行。已存在的插件会跳过，可重复执行。

### neovim（前置：nvim >= 0.10，见 [neovim/README.md](./neovim/README.md)）

```bash
# alias 进 ~/.zshrc；EDITOR/VISUAL 进 ~/.zshenv（已存在则跳过）
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/neovim/nvim_config.sh)"

# 拉取配置本体
git clone https://github.com/ZhizhenZhou/neovim-config.git ~/.config/nvim/
```

### ssh（模板，需手动填值，见 [ssh/README.md](./ssh/README.md)）

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
curl -L -o ~/.ssh/config https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/ssh/config.example
```

## 设计原则

1. **模板进仓库，真实值留本机** —— `config.example` 只含占位符；密码走系统级安全存储
   （Keychain / GNOME Keyring / DPAPI），永不出现在脚本或 dotfile 里。
2. **幂等可重复** —— 所有脚本可重复执行，已存在的组件跳过而不是重装。
3. **副作用先声明** —— 每个脚本在 README 里写明会改哪些文件，再给命令。

## 运行环境备忘

| 依赖 | 版本 | 谁需要它 |
|---|---|---|
| [Nerd Font](https://www.nerdfonts.com/font-downloads)（Hack） | 任意 | zsh 主题图标、neovim 图标 |
| node.js | >= 20（任意活跃 LTS，如 20/22/24） | neovim LSP |
| miniconda | 最新 | Python 环境管理（个人习惯，非本仓库依赖） |
| gcc / g++ | 系统源即可 | neovim treesitter 编译解析器 |
| ripgrep | 系统源即可 | neovim telescope 全文搜索 |
