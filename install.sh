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

echo "Step2: set up symlinks and copy files"
cp -rf $CURRENT_DIR/static $VIM_DIR/ 
cp -rf $CURRENT_DIR/syntax $VIM_DIR/ 
cp $CURRENT_DIR/vimrc-lcl $VIM_DIR/
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

if [ ! -e $HOME/.vim/.vimtmp/vimbookmark ]
then
    touch $HOME/.vim/.vimtmp/vimbookmark
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

echo "Step5: compile YouCompleteMe"
echo "It will take a long time, just be patient!"
echo "if error, you need to compile it yourself."
cd $VIM_DIR/bundle/YouCompleteMe/
bash -x install.sh --clang-completer

echo "Install Done"
