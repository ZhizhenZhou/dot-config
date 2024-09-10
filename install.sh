#!/bin/sh

set -e

print_error() {
  printf '%sError: %s%s\n' "$*" >&2
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

if command_exists zsh; then
    if [ "${SHELL#*zsh}" != "$SHELL" ]; then
        echo "zsh is default shell."
        zsh_version=$(zsh --version | awk '{print $2}')
        required_version="5.0.8"
        if [ "$(printf '%s\n' "$required_version" "$zsh_version" | sort -V | head -n1)" = "$required_version" ]; then
            if ! command_exists omz; then
                sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
            fi
        else
            print_error "you have \`zsh $zsh_version\` installed. But \`oh-my-zsh\` needs \`zsh 5.0.8\` or more recent."
        fi
    else
        chsh -s $(which zsh)
    fi

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # 安装自定义的zsh主题
    curl -o ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/zzz.zsh-theme https://raw.githubusercontent.com/ZhizhenZhou/zsh-config/main/zzz.zsh-theme

    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="zzz"/g' ${HOME:-~}/.zshrc
    sed -i 's/plugins=(.*)/plugins=(zsh-syntax-highlighting zsh-autosuggestions z git)/g' ${HOME:-~}/.zshrc

    {
        echo "alias vim='nvim'"
        echo "alias vi='nvim'"

        echo "export EDITOR='nvim'"
        echo "export VISUAL='nvim'"
    } >> ${HOME:-~}/.zshrc


    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

    source ${HOME:-~}/.zshrc

    nvm install 20

    echo "脚本执行完成。请重新登录以应用更改。"
else
    print_error "zsh is not installed."
fi

