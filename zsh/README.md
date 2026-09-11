# zsh 引导

zsh + oh-my-zsh 的安装与配置：两个插件、一个自定义主题、`~/.zshrc` 两行改写。

## 文件清单

| 文件 | 作用 | 幂等 |
|---|---|---|
| `install.sh` | 装插件 + 下主题 + 改 `~/.zshrc` | ✓ |
| `zzz.zsh-theme` | 自定义主题（极简 prompt + 右侧返回码/时间） | — |

## Quick start

### 1. 安装 zsh 并设为默认

```bash
# macOS 自带；Linux 用系统源（全新 WSL/Debian 常连 curl、git 都没有，一并装上）
sudo apt install -y zsh curl git
chsh -s "$(which zsh)"
```

### 2. 安装 oh-my-zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. 应用本仓库配置

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/zsh/install.sh)"
```

会改动（详见 `install.sh` 头部注释，脚本内容见仓库）：

| 目标 | 动作 | 重复执行 |
|---|---|---|
| `$ZSH_CUSTOM/plugins/` | clone `zsh-autosuggestions`、`zsh-syntax-highlighting` | 已存在则跳过 |
| `$ZSH_CUSTOM/themes/zzz.zsh-theme` | 从本仓库下载 | 每次覆盖，保持同步 |
| `~/.zshrc` | 改写 `ZSH_THEME` 与 `plugins=` 两行 | 已配置则跳过；首次改写前备份为 `~/.zshrc.bak` |

### 4. （可选）本机隐藏 prompt 的用户名

主题默认显示 `用户名@主机名`；只在自己的机器上隐藏它：

```bash
echo "export PROMPT_HIDE_USER=1" >> ~/.zshenv    # 不要把这一行提交进仓库
```

## `.zshenv` vs `.zshrc`

| 文件 | 谁读它 | 放什么 |
|---|---|---|
| `~/.zshenv` | **所有** zsh 进程（交互、脚本、cron、ssh 远程命令） | 环境变量：`EDITOR`、`SSH_ASKPASS`、`PROMPT_HIDE_USER` … |
| `~/.zshrc` | 仅交互 shell | 主题、插件、alias、补全 |

判断标准：**cron / 非交互脚本里也要生效的 → `.zshenv`；只在终端里有意义的 → `.zshrc`**。
例：`EDITOR` 只放 `.zshrc` 的话，cron 里跑 `git commit` 会退回默认编辑器。

## 排错

- 主题图标乱码 → 终端没设 Nerd Font，见根 [README](../README.md)
- 改完不生效 → `exec zsh` 或重开终端
- 想撤销配置 → 恢复 `~/.zshrc.bak`，删 `$ZSH_CUSTOM/plugins/` 下两个目录和 `themes/zzz.zsh-theme`
