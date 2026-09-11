#!/bin/sh
# zsh + oh-my-zsh 一键配置（幂等，重复执行安全）
#
# 会改动：
#   1. $ZSH_CUSTOM/plugins/  克隆 zsh-autosuggestions、zsh-syntax-highlighting（已存在则跳过）
#   2. $ZSH_CUSTOM/themes/   下载 zzz.zsh-theme（每次覆盖，保证与仓库一致）
#   3. ~/.zshrc              改写 ZSH_THEME 与 plugins= 两行（已配置则跳过；首次改写前备份为 ~/.zshrc.bak）

set -eu

err() { printf '\033[31mError\033[0m: %s\n' "$*" >&2; }

[ "${SHELL:-}" ] && [ "${SHELL#*zsh}" != "${SHELL:-}" ] || { err "please set zsh as your default shell."; exit 1; }
[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" ] || { err "please install oh-my-zsh first. see: zsh/README.md"; exit 1; }
[ -f "$HOME/.zshrc" ] || { err "~/.zshrc not found."; exit 1; }

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
REPO_RAW="${REPO_RAW:-https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/zsh}"

# --- 插件：已存在则跳过，绝不重装 ---

ensure_plugin() {
    _name="$1"
    _url="$2"
    _dir="$ZSH_CUSTOM/plugins/$_name"
    if [ -d "$_dir/.git" ]; then
        printf 'skip      %s (已存在)\n' "$_name"
    else
        git clone --depth 1 -q "$_url" "$_dir"
        printf 'installed %s\n' "$_name"
    fi
}

ensure_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
ensure_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

# --- 主题：每次覆盖下载，保持与仓库一致（目录不存在则创建） ---

mkdir -p "$ZSH_CUSTOM/themes"
curl -fsSL -o "$ZSH_CUSTOM/themes/zzz.zsh-theme" "$REPO_RAW/zzz.zsh-theme"
printf 'installed theme zzz.zsh-theme\n'

# --- ~/.zshrc：已配置则跳过 ---

if grep -q '^ZSH_THEME="zzz"' "$HOME/.zshrc" \
    && grep -q '^plugins=(zsh-syntax-highlighting zsh-autosuggestions z git)' "$HOME/.zshrc"; then
    printf 'skip      ~/.zshrc (已配置)\n'
else
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    # -i.bak2 在 GNU/BSD sed 上行为一致；改写成功后删掉 sed 的临时副本，保留 cp 的备份
    sed -i.bak2 \
        -e 's/^ZSH_THEME=.*/ZSH_THEME="zzz"/' \
        -e 's/^plugins=(.*/plugins=(zsh-syntax-highlighting zsh-autosuggestions z git)/' \
        "$HOME/.zshrc"
    rm -f "$HOME/.zshrc.bak2"
    printf 'installed ~/.zshrc (原文件备份为 ~/.zshrc.bak)\n'
fi

printf '\n完成。重启终端或执行: source ~/.zshrc\n'
