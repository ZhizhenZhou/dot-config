#!/bin/sh
# zsh 集成 neovim（幂等，重复执行安全）
#
# 会改动：
#   1. $ZDOTDIR/.zshenv  追加 export EDITOR / VISUAL（已存在则跳过）
#      .zshenv 被所有 zsh 进程读取（含非交互脚本、cron、ssh 远程命令），
#      编辑器变量必须放这里才全局生效
#   2. $ZDOTDIR/.zshrc   追加 alias vim / vi -> nvim（已存在则跳过）
#      alias 只对交互 shell 有意义，放 .zshrc

set -eu

ensure_line() {
    _file="$1"
    _pattern="$2"
    _line="$3"
    [ -f "$_file" ] || touch "$_file"
    if grep -qs "$_pattern" "$_file"; then
        printf 'skip      %s\n' "$_line"
    else
        printf '%s\n' "$_line" >> "$_file"
        printf 'added     %s (-> %s)\n' "$_line" "$_file"
    fi
}

# 尊重 zsh 的 ZDOTDIR：设了它，.zshrc / .zshenv 就不在 $HOME 下
ZDOTDIR="${ZDOTDIR:-$HOME}"

# 环境变量 -> .zshenv（全局生效）
ensure_line "$ZDOTDIR/.zshenv" 'export EDITOR=' "export EDITOR='nvim'"
ensure_line "$ZDOTDIR/.zshenv" 'export VISUAL=' "export VISUAL='nvim'"

# alias -> .zshrc（仅交互 shell）
ensure_line "$ZDOTDIR/.zshrc" 'alias vim=' "alias vim='nvim'"
ensure_line "$ZDOTDIR/.zshrc" 'alias vi=' "alias vi='nvim'"

printf '\n完成。重启终端，或执行: source ~/.zshenv && source ~/.zshrc\n'
