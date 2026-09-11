#!/bin/sh
# zsh 集成 neovim（幂等，重复执行安全）
#
# 会改动：
#   1. ~/.zshenv  追加 export EDITOR / VISUAL（已存在则跳过）
#      .zshenv 被所有 zsh 进程读取（含非交互脚本、cron、ssh 远程命令），
#      编辑器变量必须放这里才全局生效
#   2. ~/.zshrc   追加 alias vim / vi -> nvim（已存在则跳过）
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

# 环境变量 -> .zshenv（全局生效）
ensure_line "$HOME/.zshenv" 'export EDITOR=' "export EDITOR='nvim'"
ensure_line "$HOME/.zshenv" 'export VISUAL=' "export VISUAL='nvim'"

# alias -> .zshrc（仅交互 shell）
ensure_line "$HOME/.zshrc" 'alias vim=' "alias vim='nvim'"
ensure_line "$HOME/.zshrc" 'alias vi=' "alias vi='nvim'"

printf '\n完成。重启终端，或执行: source ~/.zshenv && source ~/.zshrc\n'
