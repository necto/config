## Needed to put into a separate file, as YAML breaks on the
## colon (https__:__//).

echo "Delete the old Emacs plugins: .emacs.d"
rm -rf ~/.emacs.d
git clone https://github.com/syl20bnr/spacemacs --branch develop ~/.emacs.d
emacs --batch -l ~/.emacs.d/before-init.el -l ~/.emacs.d/init.el --kill

