
# Check for an interactive session
[ -z "$PS1" ] && return

PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] '

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
source ~/.config/bash-command-timer.sh

function before_every_command() {
    # Important to have BCTPreCommand first for it to catch the exit status
    # of the last command
    BCTPreCommand
    if [ -z "$INSIDE_EMACS" ]; then
        set_terminal_windowname
    fi
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

export PATH=~/.local/bin:$PATH

# this is too slow to eval on every bash start
# (i.e., every new terminal window)
# moved to bash_profile to run once per login
# eval "$(fzf --bash)"

export PATH="$HOME/.config/emacs/bin:$PATH"

if [ -z "$INSIDE_EMACS" ]; then
    # Add separators for foot terminal emulator
    # to find beginning and end of a command output
    # See https://codeberg.org/dnkl/foot/wiki#bash-2
    PS0+='\e]133;C\e\\'
    command_done() {
        printf '\e]133;D\e\\'
    }
    # Keep the original prompt command last, because bash-command-timer relies
    # on it being last to set the proper time reference point
    PROMPT_COMMAND=command_done${PROMPT_COMMAND:+; $PROMPT_COMMAND}
fi

function tldr() {
    if [ -z "$1" ]; then
        echo "Usage: tldr <command>"
        return 1
    fi
    emacsclient -c -e "(tldr \"$1\")"
}

export "BAT_THEME=base16-256"

## Command history

# append to the history file, don't overwrite it
shopt -s histappend
# Erase duplicates in the history on every command
export "HISTCONTROL=erasedups:ignorespace"
# Number of cached commands. Once it overflows, the old commands are forgotten
export "HISTSIZE=1000"
# Number of lines in the history file saved there once the shell exits
export "HISTFILESIZE=1000000"
# one dot-file less in the home directory
export "HISTFILE=$HOME/.cache/bash_history"

## Optimized clang toolchain (optional)

# optimized-clang-with-lld-toolchain lives in its own profile, outside
# ~/config/manifest.scm, so that `guix pull && guix upgrade' never triggers a
# multi-hour PGO+ThinLTO rebuild.  Install it with
# `install-optimized-clang'; remove it with
# `rm -rf ~/.guix-extra-profiles/optimized-clang'.
#
# Sourced last on purpose: etc/profile *prepends*, so this profile's bin/ and
# its C_INCLUDE_PATH / CPLUS_INCLUDE_PATH / LIBRARY_PATH entries end up ahead
# of the clang-with-lld-toolchain from the manifest, superseding it entirely
# rather than merely shadowing the clang binary.
#
# etc/profile prepends unconditionally, and so do /etc/profile.d/guix.sh and
# ~/.guix-home/profile/etc/profile on every *login* shell.  A nested login shell
# therefore inherits this profile somewhere in PATH while the two stock profiles
# get re-prepended in front of it.  So test what we actually care about -- where
# `clang' resolves -- instead of pattern-matching PATH: that stays correct no
# matter how the entries got reordered, and still no-ops in the common case.
_optimized_clang_profile="$HOME/.guix-extra-profiles/optimized-clang/optimized-clang"
if [ -L "$_optimized_clang_profile" ] &&
       [ "$(command -v clang)" != "$_optimized_clang_profile/bin/clang" ]; then
    GUIX_PROFILE="$_optimized_clang_profile" . "$_optimized_clang_profile/etc/profile"
fi
unset _optimized_clang_profile
