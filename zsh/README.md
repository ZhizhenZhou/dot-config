# zsh

## 安装

用平台包管理器装 `zsh`、`curl`、`git`。

再把 zsh 设为默认 shell：

```bash
chsh -s "$(which zsh)"
```

装 oh-my-zsh：

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## 应用本仓库配置

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/zsh/install.sh)"
```

## 可选

### 隐藏 prompt 中的用户名

主题默认显示 `用户名@主机名`，以下方式隐藏：

```bash
echo "export PROMPT_HIDE_USER=1" >> ~/.zshenv
```

### 终端代理

把 [proxy.sh](./proxy.sh) 放到任意位置（推荐 `~/.oh-my-zsh/custom/`），
在 `~/.zshrc` 末尾加（路径按实际位置替换）：

```bash
PROXY_PORT=<代理端口>
[ -f <路径>/proxy.sh ] && source <路径>/proxy.sh
```

端口是本机值，不要提交进仓库。

同时用多个代理客户端（例如 v2ray + Clash，端口不同）时，改成候选列表，
按顺序取第一个在监听的：

```bash
PROXY_PORTS="<端口1> <端口2>"
```

可用命令：

- `proxy on`：自动挑一个在监听的端口；也可以 `proxy on <端口>` 临时指定
- `proxy off`：清除代理变量
- `proxy status`：显示当前状态，并列出各候选端口是否在监听

新开终端时有候选端口在监听则自动开启，一个都没有就保持关闭。
