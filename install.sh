#!/bin/sh

set -e

print_error() {
  printf '%sError: %s%s\n' "$*" >&2
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if [ "${SHELL#*zsh}" != "$SHELL" ]; then
    if ! command_exists omz; then
        if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        else
            rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        fi

        if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        else
            rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
            git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        fi

        # 安装自定义的zsh主题
        if [ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/zzz.zsh-theme ]; then
            curl -o ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/zzz.zsh-theme https://raw.githubusercontent.com/ZhizhenZhou/zsh-config/main/zzz.zsh-theme
        else
            rm -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/zzz.zsh-theme
            curl -o ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/zzz.zsh-theme https://raw.githubusercontent.com/ZhizhenZhou/zsh-config/main/zzz.zsh-theme
        fi

        sed -i 's/ZSH_THEME=".*"/ZSH_THEME="zzz"/g' ${HOME:-~}/.zshrc
        sed -i 's/plugins=(.*)/plugins=(zsh-syntax-highlighting zsh-autosuggestions z git)/g' ${HOME:-~}/.zshrc

        # 这里应该放到neovim的配置里
        # {
        #     echo "alias vim='nvim'"
        #     echo "alias vi='nvim'"
        #
        #     echo "export EDITOR='nvim'"
        #     echo "export VISUAL='nvim'"
        # } >> ${HOME:-~}/.zshrc
    else
        echo "please install oh-my-zsh first."
    fi
else
    echo "please set zsh your default shell."
    exit 1
fi

source ${HOME:-~}/.zshrc

