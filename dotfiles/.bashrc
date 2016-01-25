# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Expand dir env vars on tab
shopt -s direxpand

# Controls the format of the time in output of `history`
HISTTIMEFORMAT="[%F %T] "

# Infinite history
HISTSIZE=
HISTFILESIZE=

export EDITOR=vim
export VISUAL=vim

export GOPATH=$HOME/code/go
export PATH=$PATH:$GOPATH/bin

# User specific aliases and functions

alias l='ls -l'
alias lt='ls -lt'
alias la='ls -la'
alias ps='ps --width=8000'
alias bashrc='vim ~/.bashrc'
alias bashrc.='source ~/.bashrc'
alias findx='sudo find / -mount -iname'
alias t='tmux'
alias ta='tmux attach'

if [ -e /usr/bin/vimx ]; then
   alias vim='/usr/bin/vimx'
fi

alias g='grep -nr'
alias gg='grep -nr --exclude-dir=.git'

# Git aliases

alias gita='git add'
alias gitb='git branch'
alias gits='git status'

alias gitd='git diff'
alias gitds='git diff --staged'

alias gitl='git log --pretty=oneline'
alias gitla="git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"
alias gitlg="git log --graph --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"

source /usr/share/git-core/contrib/completion/git-prompt.sh

function stdprompt() {

   echo -n "["
   echo -n "\u "

   echo -n "\[\033[0;35m\]" # Dark grey
   echo -n "\W"
   echo -n "\[\033[0m\]"

   echo -n "\[\033[0;34m\]" # Light blue
   echo -n "\$(__git_ps1 \" (%s)\")"
   echo -n "\[\033[0m\]"

   echo -n "]"
}

PS1="\$(if [[ \$? == 0 ]]; then echo \"$(stdprompt)\$\"; else \
   echo \"$(stdprompt)\[\033[0;31m\]\$\[\033[00m\]\"; fi) "
