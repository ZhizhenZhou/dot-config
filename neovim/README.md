# neovim

配置本体在 [ZhizhenZhou/neovim-config](https://github.com/ZhizhenZhou/neovim-config)。

## 安装

装最新版。

优先用平台包管理器。有些包管理器不提供最新版，有些仓库里根本没有 neovim，这时用本目录的脚本下官方包：

```
bash neovim-install.sh [-h|--help|--yes]
```

| 变量 | 默认值 |
|---|---|
| `NVIM_INSTALL_DIR` | `/usr/local/nvim` |
| `NVIM_BIN_DIR` | `<install dir>` 的同级 `bin` |
| `NVIM_VERSION` | `latest` |

```bash
# 装到用户目录，不需要 sudo（路径按实际位置替换，推荐 ~/.local/opt/nvim 与 ~/.local/bin）
NVIM_INSTALL_DIR=<安装路径> NVIM_BIN_DIR=<bin 路径> bash neovim-install.sh

# 锁版本
NVIM_VERSION=v0.12.6 bash neovim-install.sh
```

## 接入 zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/neovim/nvim_config.sh)"
```

## 运行依赖

| 依赖 | 用途 |
|---|---|
| `gcc` + `make` | 编译 treesitter 解析器 |
| `unzip` | mason 解压 zip 工具包 |
| `ripgrep` | telescope 全文搜索 |
| `node.js` ≥ 20 | LSP 运行时 |
| Nerd Font | 终端图标 |

优先用平台包管理器装；没有这个包或版本不满足时，用官方安装包。
