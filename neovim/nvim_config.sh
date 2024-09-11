#!/bin/sh

{

    echo "alias vim='nvim'"
    echo "alias vi='nvim'"

    echo "export EDITOR='nvim'"
    echo "export VISUAL='nvim'"
    
} >> ${HOME:-~}/.zshrc
