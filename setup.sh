#!/bin/bash
# Sets up environment and symlinks

# Clone vim plugins into .vim/pack/jack/start
[ -z "$VIM_PACK_DIR" ] && VIM_PACK_DIR=.vim/pack/jack
mkdir -p $VIM_PACK_DIR/start
git -C $VIM_PACK_DIR/start clone git@github.com:wellle/targets.vim.git
git -C $VIM_PACK_DIR/start clone git@github.com:tpope/vim-commentary.git
git -C $VIM_PACK_DIR/start clone git@github.com:altercation/vim-colors-solarized.git

[ ! -e .vimrc ] && ln -s dotfiles/vim/vimrc .vimrc
mkdir -p .vim/backup
mkdir -p .vim/undo

[ ! -e .gitconfig ] && ln -s dotfiles/git/gitconfig .gitconfig
[ ! -e .gitignore_global ] && ln -s dotfiles/git/gitignore_global .gitignore_global

[ ! -e .terminfo ] && ln -s dotfiles/terminfo .terminfo

[ ! -e .zshrc ] && ln -s dotfiles/shell/zshrc .zshrc
[ ! -e .aliases ] && ln -s dotfiles/shell/aliases .aliases

[ ! -e .tmux.conf ] && ln -s dotfiles/tmux.conf .tmux.conf
