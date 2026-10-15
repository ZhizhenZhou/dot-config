# neovim

把 Neovim 装到这台机器上，并把编辑器接进 zsh。配置本体在另一个仓库：
[ZhizhenZhou/neovim-config](https://github.com/ZhizhenZhou/neovim-config)。

---

## 1. 安装方式：官方 tarball

Neovim 我们统一用**官方 release 的 tarball** 安装，不走包管理器：

| 方式 | 结论 | 原因 |
|---|---|---|
| **官方 tarball** | ✅ 采用 | 版本可控（要 0.10+）、x86_64 / arm64 同一套逻辑、升级 = 重跑一次、产物是普通目录好管理 |
| `apt install neovim` | ❌ | 发行版源版本普遍偏旧，拿不到 0.10+，且各发行版版本不一致 |
| `brew install neovim` | ❌ | 仅 macOS；本仓库要在 macOS / Linux(WSL) 之间共用同一套引导 |
| AppImage | ❌ | 依赖 FUSE，WSL 内常常没装，跑不起来还要额外排错 |
| `nix profile` | ❌ | 引入一整套 Nix 体系，超出这个仓库的范围 |

安装布局：解压后的目录放到一个自选位置（默认 `/usr/local/nvim`），再在 `bin` 目录里放一个
`nvim` 软链接指过去。这样"装哪"和"PATH 里怎么找到它"两件事解耦，换目录也不用动 PATH。

> 版本要求：**>= 0.10**（实测 0.12）。neovim-config 用了 0.10 才有的 API。

---

## 2. 提供的脚本

|脚本 | 作用 | 是否需要 root |
|---|---|---|
| `neovim-install.sh` | 下载官方 tarball 并安装 / 升级到指定目录 | 装到用户目录不需要；装 `/usr/local` 才需要 |
| `nvim_config.sh` | 把 `EDITOR` / `VISUAL` 写进 `~/.zshenv`，把 `alias vim/vi` 写进 `~/.zshrc` | 不需要 |

两个脚本都是 **幂等** 的：重复执行安全，已存在的部分跳过或整体覆盖，不会叠加。

### 快速开始

```bash
git clone https://github.com/ZhizhenZhou/dot-config.git
cd dot-config

bash neovim/neovim-install.sh   # 询问安装目录；回车 = /usr/local/nvim
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/neovim/nvim_config.sh)"

git clone https://github.com/ZhizhenZhou/neovim-config.git ~/.config/nvim/
nvim
```

`~/.config/nvim` 已存在时先备份：`mv ~/.config/nvim ~/.config/nvim.bak`。

---

## 3. 脚本说明

### 3.1 `neovim-install.sh`

#### 3.1.1 用法

```
bash neovim-install.sh [-h|--help|--yes]
```

| 写法 | 行为 |
|---|---|
| `bash neovim-install.sh` | 交互式询问安装目录；直接回车用默认值 |
| `bash neovim-install.sh --yes` | 不询问，用默认安装目录 |
| `bash neovim-install.sh -h` / `--help` | 打印脚本头部的用法摘要（改动清单 + 用法 + 环境变量）后退出 |
| `sudo bash neovim-install.sh` | 等价于默认路径 + 显式 root |

#### 3.1.2 环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| `NVIM_INSTALL_DIR` | `/usr/local/nvim` | nvim 安装目录。可交互输入，也可用此变量指定 |
| `NVIM_BIN_DIR` | `<install dir>` 的同级 `bin` | `nvim` 软链接落点，例如 `/usr/local/bin`、`~/.local/bin` |
| `NVIM_VERSION` | `latest` | 指定版本，如 `v0.12.6` |
| `https_proxy` / `all_proxy` | — | 走代理时由你在外部导出，脚本本身不碰代理设置 |

路径优先级：**环境变量 > 交互输入 > 默认值**。设了 `NVIM_INSTALL_DIR` 就不再提问；
没设 `NVIM_BIN_DIR` 时跟随 `NVIM_INSTALL_DIR` 走。

#### 3.1.3 会改动什么

| 对象 | 操作 |
|---|---|
| `<install dir>` | **整体覆盖**（先 `rm -rf` 再放入新版本） |
| `<bin dir>/nvim` | 软链接，强制重建（`ln -sfn`） |
| `PATH` | **不改**。若新 bin 目录不在 PATH 里，只在结尾打印一行 `export` 提示 |
| 任何 dotfile | **不改** |

#### 3.1.4 执行流程

1. 解析安装目录（env → 交互 → 默认），去掉末尾多余的 `/`。
2. 探测目标目录是否可写：
   - 可写 → 不需要 root；
   - 不可写且当前是 root → 直接写；
   - 不可写且不是 root → 有 `sudo` 就自动加 `sudo`，没有就报错退出。
3. 按 `uname -m` 选产物：`x86_64` → `nvim-linux-x86_64.tar.gz`，`aarch64` / `arm64` → `nvim-linux-arm64.tar.gz`；其它架构直接报错退出。
4. 拼下载地址：`latest` 走 `releases/latest/download/<asset>`，指定版本走 `releases/download/<version>/<asset>`。
5. 下载到 `mktemp -d` 的临时目录并解压（`trap` 保证退出时清理）。
6. 定位解压产物目录：先按产物名推断，找不到就退回"临时目录里的第一个子目录"，因此上游改产物命名也不会炸。
7. 覆盖安装 + 重建软链接，打印新版本号。
8. 收尾自检：
   - 若 PATH 上的 `nvim` 指向另一个文件，打印 warning，提示删掉旧的或把新 bin 目录提到 PATH 前面；
   - 若新 bin 目录不在 PATH 里，打印一行 `export PATH=...` 供参考。

#### 3.1.5 前置条件

| 依赖 | 说明 |
|---|---|
| `bash` `curl` `tar` `uname` | 脚本直接调用，缺一不可 |
| 可写的目标目录 | 用户目录天然可写；系统目录需要 root / `sudo` |
| 网络能到 `github.com` | 需要代理时先自行导出 `https_proxy` |

装完之后 Neovim 还需要（系统源即可）：`gcc` + `make`（treesitter 编译解析器，缺了首开报错）、
`unzip`（mason 解压 zip 格式的工具包，如 stylua / clangd，缺了报 `spawn: unzip failed`）、
`ripgrep`（telescope 全文搜索）、`node.js >= 20`（LSP 运行时）、以及终端的 Nerd Font（图标）。
WSL 一条命令：

```bash
sudo apt install -y build-essential unzip ripgrep
```

macOS：

```bash
brew install ripgrep   # unzip 系统自带，gcc/make 由 Xcode CLT 提供
```

#### 3.1.6 幂等性与重复执行

同一条命令重复执行 = 升级到最新版本。因为安装目录是整体替换，不存在残留文件累积；
软链接每次重建，也不会指向被删掉的旧目录。

#### 3.1.7 退出码

| 退出码 | 含义 |
|---|---|
| `0` | 安装成功（可能附带 warning） |
| `1` | 不支持的架构 / 找不到解压产物 / 目标目录不可写且无 `sudo` |
| 其它 | 直接透传失败命令的退出码，例如 `curl` 的 `35`（SSL 连接失败）、`6`（DNS 解析失败） |

#### 3.1.8 示例

```bash
# 装到用户目录，全程不需要 sudo
NVIM_INSTALL_DIR=~/.local/opt/nvim NVIM_BIN_DIR=~/.local/bin bash neovim-install.sh

# 锁版本（可复现环境）
NVIM_VERSION=v0.12.6 bash neovim-install.sh

# 装到 /usr/local，但不想整段命令都 sudo，只让脚本自己判断
bash neovim-install.sh --yes
```

#### 3.1.9 卸载 / 回滚

脚本不做卸载。手动两步即可：

```bash
rm -rf /usr/local/nvim          # 或你的 NVIM_INSTALL_DIR
rm -f /usr/local/bin/nvim       # 或你的 NVIM_BIN_DIR/nvim
```

回滚到旧版本同理：带上旧的 `NVIM_VERSION` 重跑一次即可。

#### 3.1.10 故障排查

| 现象 | 原因 / 处理 |
|---|---|
| `Unsupported architecture: ...` | 脚本只支持 x86_64 与 arm64 |
| `Need write access to ... Re-run with sudo` | 目标目录不可写且系统没有 `sudo`，改用用户目录或手动加 sudo |
| `curl: (35) ...` | 到 `github.com` 的连接被掐，先 `export https_proxy=...` 再跑 |
| `Could not locate extracted Neovim directory` | 下载到的东西不是预期 tarball，清缓存后重试 |
| 装完 `nvim --version` 仍是旧版本 | PATH 上有另一份 nvim 抢在前面，按脚本提示删旧的或调 PATH 顺序 |
| `spawn: unzip failed`（nvim 里） | 系统缺 `unzip`，mason 装不了 zip 包 |
| treesitter 首开报错 | 系统缺 `gcc` / `make` |

> 产物命名说明：`nvim-linux-x86_64` 是 0.12 起的命名，老版本叫 `nvim-linux64`。脚本两种都能处理。

### 3.2 `nvim_config.sh`

#### 3.2.1 作用

把 zsh 接上 neovim，两处改动，缺一不可：

| 文件 | 追加内容 | 为什么放这里 |
|---|---|---|
| `~/.zshenv` | `export EDITOR='nvim'`、`export VISUAL='nvim'` | `.zshenv` 被**所有** zsh 进程读取（交互、非交互脚本、cron、ssh 远程命令）。编辑器变量必须全局生效，否则 cron 里 `git commit` 会退回默认编辑器 |
| `~/.zshrc` | `alias vim='nvim'`、`alias vi='nvim'` | alias 只对交互 shell 有意义，放 `.zshrc` |

#### 3.2.2 用法

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/neovim/nvim_config.sh)"
# 或本地：sh neovim/nvim_config.sh
```

#### 3.2.3 幂等性

按内容匹配去重：目标行已存在就打印 `skip`，不存在才追加；目标文件不存在会先创建。
重复执行不会写出两份 `export EDITOR=`。

---

## 4. 设计取舍

- **tarball 而非 AppImage**：解压即用，升级 = 换目录重新解压；AppImage 依赖 FUSE，WSL 内经常没装。
- **安装目录与 bin 目录分离**：版本本体放在一个目录里当"可整体替换的产物"，
  PATH 只认一个稳定软链接，升级不会影响 PATH 配置。
- **`EDITOR`/`VISUAL` 放 `.zshenv` 而非 `.zshrc`**：见3.2，cron / 非交互脚本里也要生效。
- **脚本不碰 dotfile**：PATH、shell 配置一律只打印提示交给人决定，避免"脚本悄悄改了我的环境"。
- **为什么需要 node.js**：LSP 依赖 node 运行时，没有它部分 language server 起不来。