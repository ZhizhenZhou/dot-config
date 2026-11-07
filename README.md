# ZZZ's computer configuration.

macOS / Linux(WSL) 个人环境的引导配置：zsh、neovim、ssh。
各组件的安装与配置相互独立，脚本幂等可重复执行。

> **安全模型**：仓库只存**模板**（`*.example`）和**通用脚本**。
> 真实主机名、账号、密钥一律留在本机，不进 git —— 由根目录 `.gitignore` 强制。

## 仓库结构

| 目录 | 内容 | 文档 |
|---|---|---|
| `zsh/` | oh-my-zsh 插件、自定义主题 `zzz`、终端代理开关模板 | [zsh/README.md](./zsh/README.md) |
| `neovim/` | neovim 安装脚本、`EDITOR` / `VISUAL` 与 alias 接入 | [neovim/README.md](./neovim/README.md) |
| `ssh/` | `config` 模板、SSH_ASKPASS 免密方案 | [ssh/README.md](./ssh/README.md) |

neovim 的配置本体在另一个仓库：[ZhizhenZhou/neovim-config](https://github.com/ZhizhenZhou/neovim-config)。

## 设计原则

1. **模板进仓库，真实值留本机** —— `config.example` 只含占位符；密码走系统级安全存储
   （Keychain / GNOME Keyring / DPAPI），永不出现在脚本或 dotfile 里。
2. **幂等可重复** —— 所有脚本可重复执行，已存在的组件跳过而不是重装。
3. **副作用先声明** —— 脚本头部注释列明会改动哪些文件。
