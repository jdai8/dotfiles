@echo off
rem Sets up environment and symlinks
rem Run as admin from home directory

rem Vim setup
cd dotfiles\vim
mkdir dotvim\autoload
mkdir dotvim\backup
mkdir dotvim\undo
copy pathogen\autoload\pathogen.vim dotvim\autoload
cd ..\..

del _vimrc _gvimrc vimfiles .vim
mklink _vimrc dotfiles\vim\vimrc
mklink _gvimrc dotfiles\vim\gvimrc
mklink vimfiles dotfiles\vim\dotvim
rem cygwin looks in ~/vim
mklink .vim dotfiles\vim\dotvim
