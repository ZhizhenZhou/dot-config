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
