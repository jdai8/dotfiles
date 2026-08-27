#!/bin/bash
# Sets up environment and copies config files into place
# Run from the home directory

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)

# Copies a file/directory from the dotfiles repo, leaving any existing file alone
install_file() {
    src=$DOTFILES_DIR/$1
    dest=$2
    if [ -e "$dest" ]; then
        echo "Skipping $dest, already exists"
    else
        cp -r "$src" "$dest"
    fi
}

# Clone vim plugins into .vim/pack/jack/start
[ -z "$VIM_PACK_DIR" ] && VIM_PACK_DIR=.vim/pack/jack
mkdir -p $VIM_PACK_DIR/start
git -C $VIM_PACK_DIR/start clone git@github.com:wellle/targets.vim.git
git -C $VIM_PACK_DIR/start clone git@github.com:tpope/vim-commentary.git
git -C $VIM_PACK_DIR/start clone git@github.com:altercation/vim-colors-solarized.git

install_file vim/vimrc .vimrc
mkdir -p .vim/backup
mkdir -p .vim/undo

install_file git/gitconfig .gitconfig
install_file git/gitignore_global .gitignore_global

install_file terminfo .terminfo

install_file shell/zshrc .zshrc
install_file shell/aliases .aliases

install_file tmux.conf .tmux.conf
