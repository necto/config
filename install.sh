#!/bin/bash
# Note bash is required for pushd/popd commands
cfgdir=$(pwd)
echo "Configuration files are in $cfgdir"
pushd ~
ln -s ${cfgdir}/.emacs .emacs
ln -s ${cfgdir}/.vimrc .vimrc
ln -s ${cfgdir}/.bashrc .bashrc
echo "Downloading Emacs plugins"
if [ ! -d ".emacs.d" ]; then
    mkdir .emacs.d
fi
pushd .emacs.d
echo "Autocompletion"
wget http://cx4a.org/pub/auto-complete/auto-complete-1.3.1.tar.bz2
tar -xjf auto-complete-1.3.1.tar.bz2
mv auto-complete-1.3.1 auto-complete
echo "Stripes"
wget http://www.emacswiki.org/emacs/download/stripes.el
echo "Rectangular selection"
wget http://emacswiki.org/emacs/download/rect-mark.el
echo "Multiterm"
wget http://www.emacswiki.org/emacs/download/multi-term.el
echo "Brief dired mode"
wget http://www.emacswiki.org/emacs/download/dired-details.el
popd
popd