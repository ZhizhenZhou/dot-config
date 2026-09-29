# neovim 引导

安装 neovim 运行环境并接入 zsh。**配置本体在另一个仓库**：
[ZhizhenZhou/neovim-config](https://github.com/ZhizhenZhou/neovim-config)。

## 文件清单

| 文件 | 作用 | 幂等 |
|---|---|---|
| `nvim_config.sh` | `EDITOR`/`VISUAL` → `~/.zshenv`；`alias vim/vi` → `~/.zshrc`。已存在的行跳过 | ✓ |

## 前置要求

| 依赖 | 版本 | 用途 |
|---|---|---|
| neovim | >= 0.10（实测 0.12） | — |
| git | 系统源即可 | 克隆配置与插件 |
| gcc + make | 系统源即可（WSL: `sudo apt install build-essential`） | treesitter 编译语法解析器，缺了首开报错 |
| unzip | 系统源即可（WSL: `sudo apt install unzip`） | mason 安装 zip 格式的工具包（stylua / clangd 等），缺了这些工具会安装失败 |
| ripgrep | 系统源即可（macOS: `brew install ripgrep`；WSL: `sudo apt install ripgrep`） | telescope 全文搜索，**macOS 不自带** |
| node.js | >= 20（任意活跃 LTS，如 20/22/24） | LSP 运行时 |
| [Nerd Font](https://www.nerdfonts.com/font-downloads)（Hack） | 任意 | 图标 |

## Quick start

### 1. 安装 neovim

Linux/WSL 先装齐系统依赖（一条命令）：

```bash
sudo apt install -y build-essential unzip ripgrep
```

> `build-essential`（gcc/make）供 treesitter 编译解析器，`unzip` 供 mason 解压 zip 格式的工具包
> （stylua / clangd 等；缺了时报 `spawn: unzip failed`，不看文档很难联想到），
> `ripgrep` 供 telescope 全文搜索。

macOS：

```bash
brew install neovim ripgrep   # unzip 系统自带，不用装
```

> macOS 自带 `unzip`（mason 解压 zip 工具包要用），但**不自带 `ripgrep`**（telescope 全文搜索要用），
> gcc/make 由 Xcode CLT 提供，`brew install neovim` 时会一并提示安装。

Linux（含 WSL）：发行版源里的 neovim 普遍偏旧，用官方 tarball：

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz
sudo rm -rf /usr/local/nvim
sudo mv nvim-linux-x86_64 /usr/local/nvim
sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
```

> 产物名 `nvim-linux-x86_64` 是 0.12 起的命名；老版本的产物叫 `nvim-linux64`，在老版本的 release 页下载对应文件。

### 2. 接入 zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/neovim/nvim_config.sh)"
```

会改动：`~/.zshenv` 追加 `EDITOR`/`VISUAL`，`~/.zshrc` 追加 `alias vim/vi`。重复执行安全。

### 3. 拉取配置本体

```bash
git clone https://github.com/ZhizhenZhou/neovim-config.git ~/.config/nvim/
```

目录已存在时先备份：`mv ~/.config/nvim ~/.config/nvim.bak`。

## 设计取舍

- **tarball 而非 AppImage**：解压即用，升级 = 换目录重新解压；AppImage 依赖 FUSE，WSL 内经常没装。
- **`EDITOR`/`VISUAL` 放 `.zshenv` 而非 `.zshrc`**：`.zshenv` 被所有 zsh 进程读取——cron、非交互脚本、ssh 远程命令都在其中，编辑器变量只有放这里才能在这些场景生效；`.zshrc` 只被交互 shell 读取，适合放 alias。
- **为什么需要 node.js**：LSP 依赖 node 运行时，没有它部分 language server 起不来。
