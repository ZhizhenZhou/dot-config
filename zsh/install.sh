#!/bin/sh

# set -e

print_error() {
  printf '\033[31mError\033[0m: %s\n' "$*" >&2
}

if [ "${SHELL#*zsh}" != "$SHELL" ]; then
    if [ -d ${ZSH:-~/.oh-my-zsh} ]; then
        if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
            rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        fi
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

        if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
            rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        fi
        git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

        # 安装自定义的zsh主题
        if [ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/zzz.zsh-theme ]; then
            rm -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/zzz.zsh-theme
        fi
        curl -o ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/zzz.zsh-theme https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/zsh/zzz.zsh-theme

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
        print_error "please install oh-my-zsh first."
        exit 1
    fi
else
    print_error "please set zsh as your default shell."
    exit 1
fi

# . ${HOME:-~}/.zshrc
