#!/bin/bash
# Sets up environment and symlinks

cd ~/dotfiles/vim
mkdir dotvim/backup
mkdir dotvim/undo
cp -r pathogen/autoload dotvim/autoload
cd ~

ln -s dotfiles/vim/vimrc .vimrc
ln -s dotfiles/vim/dotvim .vim

ln -s dotfiles/git/gitconfig .gitconfig
ln -s dotfiles/git/gitignore_global .gitignore_global

ln -sT dotfiles/terminfo .terminfo

ln -s dotfiles/shell/zshrc .zshrc
ln -s dotfiles/shell/aliases .aliases

ln -s dotfiles/tmux.conf .tmux.conf
