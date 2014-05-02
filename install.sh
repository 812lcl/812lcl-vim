#!/bin/bash

BASEDIR=$(dirname $0)
cd $BASEDIR
VIM_DIR="$HOME/.vim"
CURRENT_DIR=`pwd`

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi

}

echo "Step1: back up current vim config"
today=`date +%Y%m%d`
for i in $HOME/.vim $HOME/.vimrc; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
for i in $HOME/.vim $HOME/.vimrc; do [ -L $i ] && unlink $i; done

echo "Step2: set up symlinks"
lnif $CURRENT_DIR $VIM_DIR
lnif $VIM_DIR/vimrc-lcl $HOME/.vimrc

if [ ! -d $HOME/.vim/bundle ]
then
    mkdir -p $HOME/.vim/bundle
fi

if [ ! -d $HOME/.vim/.vimtmp/undo ]
then
    mkdir -p $HOME/.vim/.vimtmp/undo
fi

if [ ! -d $HOME/.vim/.vimtmp/unite ]
then
    mkdir -p $HOME/.vim/.vimtmp/unite
fi

if [ ! -d $HOME/.vim/sessions ]
then
    mkdir -p $HOME/.vim/sessions
fi

if [ ! -d $HOME/.vim/view ]
then
    mkdir -p $HOME/.vim/view
fi

if [ ! -d $HOME/.fonts ]
then
    mkdir -p $HOME/.fonts
    cp -rf $VIM_DIR/fonts/* $HOME/.fonts
    fc-cache -vf $HOME/.fonts
fi

echo "Step3: install vundle"
if [ ! -e $VIM_DIR/bundle/vundle ]; then
    echo "Installing Vundle"
    git clone https://github.com/gmarik/vundle.git $VIM_DIR/bundle/vundle
else
    echo "Update Vundle"
    cd "$VIM_DIR/bundle/vundle" && git pull origin master
fi

echo "Step4: update/install plugins using Vundle"
system_shell=$SHELL
export SHELL="/bin/sh"
vim -u "$HOME/.vimrc" +BundleInstall! +BundleClean +qall
export SHELL=$system_shell

if [ ! -d $HOME/.vim/bundle/vimproc.vim ]
then
    cd $HOME/.vim/bundle/vimproc.vim
    make
fi

read -p "Will you install YouCompleteMe? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Step5: compile YouCompleteMe"
    echo "It will take a long time, just be patient!"
    echo "if error, you need to compile it yourself."
    cd $VIM_DIR/bundle/YouCompleteMe/
    bash -x install.sh --clang-completer
fi

echo "Install Done"
