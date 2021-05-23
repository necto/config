
# Check for an interactive session
[ -z "$PS1" ] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rehash='hash -r'
alias gr='grep -r'
PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] '

#export PATH=/opt/mpich2/bin:$PATH
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8


if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0222222" #black
    echo -en "\e]P8222222" #darkgrey
    echo -en "\e]P1803232" #darkred
    echo -en "\e]P9982b2b" #red
    echo -en "\e]P25b762f" #darkgreen
    echo -en "\e]PA89b83f" #green
    echo -en "\e]P3aa9943" #brown
    echo -en "\e]PBefef60" #yellow
    echo -en "\e]P4324c80" #darkblue
    echo -en "\e]PC2b4f98" #blue
    echo -en "\e]P5706c9a" #darkmagenta
    echo -en "\e]PD826ab1" #magenta
    echo -en "\e]P692b19e" #darkcyan
    echo -en "\e]PEa1cdcd" #cyan
    echo -en "\e]P7ffffff" #lightgrey
    echo -en "\e]PFdedede" #white
    clear
elif [ "$TERM" = "dumb" ]; then
    echo 'Keep the "dumb" term from the tramp mode'
else
    export TERM=xterm-256color
fi

export ALTERNATE_EDITOR="vi"
export EDITOR="emacsclient -t"
export VISUAL="emacsclient -c -a emacs"

# necessary for android studio (AVD manager) corectly detecting my 64bit linux
SHELL="/bin/bash"
export SHELL="/bin/bash"
if command -v opam &> /dev/null
then
    eval `opam config env`
fi

# Force java gui to work with Xmonad
export _JAVA_AWT_WM_NONREPARENTING=1

function set_terminal_windowname() {
    echo -ne "\033]2;$(pwd); $(history 1 | sed "s/^[ ]*[0-9]*[ ]*//g")\007"
}

# Automatically measure and display execution time for each command issued
source ~/config/bash-command-timer.sh

function before_every_command() {
    set_terminal_windowname
    BCTPreCommand
}
if [ $TERM = "dumb" ]
then
    # Fix for TRAMP (Emacs remote connection)
    unset opt zle
    PS1='$ '
else
    PROMPT_COMMAND='BCTPostCommand'
    trap 'before_every_command' DEBUG
fi

# Use the latest version of GHC and cabal by default
export PATH=/opt/ghc/bin:$PATH
export PATH=/opt/cabal/bin:$PATH

# Use cabal-installed binaries (mostly pandoc and pandoc-crossref)

export PATH=~/.local/bin:$PATH
export PATH=~/config/xmonad/light:$PATH

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

alias suspend="systemctl -i suspend"

