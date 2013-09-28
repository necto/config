
# Check for an interactive session
[ -z "$PS1" ] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[0;06m\]'

export PATH=/opt/mpich2/bin:$PATH
