#!/bin/bash
# Note bash is required for pushd/popd commands
cfgdir=$(pwd)
echo "Configuration files are in $cfgdir"
pushd ~
echo "Deleting .emacs to replace it with .spacemacs"
rm .emacs
echo "Making symlinks to all dotfiles"
ln -s ${cfgdir}/.spacemacs .spacemacs
ln -s ${cfgdir}/.vimrc .vimrc
ln -s ${cfgdir}/.bashrc .bashrc
ln -s ${cfgdir}/.gitconfig .gitconfig
echo "Deleting the emacs plugins directory .emacs.d"
if [ -d ".emacs.d" ]; then
   rm -rf .emacs.d
fi
echo "Downloading Spacemacs"
git clone https://github.com/syl20bnr/spacemacs .emacs.d
popd
