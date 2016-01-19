#!/bin/bash
# Note bash is required for pushd/popd commands
cfgdir=$(pwd)

Y_opt=""
Emerge_emacs=false
while test $# -gt 0
do
    case "$1" in
        -y | --yes) Y_opt="-y"
            ;;
        --emacs) Emerge_emacs=true
                 ;;
        *) echo "unexpected argument $1"
           exit 1
           ;;
    esac
    shift
done

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
if [ Emerge_emacs -eq true]
then
    so ./emerge-emacs-snapshot-ubuntu.sh $Y_opt
fi
