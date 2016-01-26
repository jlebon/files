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

export VAGRANT_DEFAULT_PROVIDER=libvirt
export LIBVIRT_DEFAULT_URI=qemu:///system

export EDITOR=vim
export VISUAL=vim

function whichpkg() {

	file=$(which $1)
	if [ $? -ne 0 ]; then
		return
	fi

	# could be an alias/something not a file
	if [ ! -e "$file" ]; then
		which $1
	else
		rpm -qf $file
	fi
}

alias l='ls -l'
alias lt='ls -lt'
alias la='ls -la'
alias ps='ps --width=8000'

alias bashrc='vim ~/.bashrc'
alias vimrc='vim ~/.vimrc'

alias findf='find . -iname'
alias findx='sudo find / -mount -iname'

alias t='tmux'
alias ta='tmux attach'

if [ -e /usr/bin/vimx ]; then
	alias vim='/usr/bin/vimx'
fi

alias g='grepx'
alias gi='grepxi'
alias gg='grepx --exclude-dir=.git'

# Git aliases

# pre-load here to get access to the _git_$cmd autocompletion functions
if [ -f /usr/share/bash-completion/completions/git ]; then
	source /usr/share/bash-completion/completions/git
fi

# create an alias from $1 to "git $2 $3", then tries to also enable
# auto-completion for it (with support for git aliases)
function mkgitalias {
	eval alias $1=\"git $2 $3\"
	if [ "$(type -t _git_$2)" == "function" ]; then
		__git_complete $1 _git_$2
	else
		gitalias=$(git config alias.$2)
		if [ $? -eq 0 ]; then
			__git_complete $1 _git_${gitalias% *}
		fi
	fi
}

# core commands

mkgitalias gits status
mkgitalias gitb branch
mkgitalias gita add
mkgitalias gite edit
mkgitalias gitc commit

# logging commands

mkgitalias gitl l
mkgitalias gitla la
mkgitalias gitlg lg
mkgitalias gith hh

# diff commands

mkgitalias gitd diff
mkgitalias gitdw diff --word-diff=color
mkgitalias gitds diff --staged
mkgitalias gitdsw diff --staged --word-diff=color

# add support for bash-git-prompt
# https://github.com/magicmonty/bash-git-prompt

if [ -d ~/.bash-git-prompt ] && \
   [ -z "$GIT_PROMPT_DISABLE" ]; then

	GIT_PROMPT_THEME=Solarized_Modded
	GIT_PROMPT_FETCH_REMOTE_STATUS=0

	function prompt_callback {

		# This callback is meant to work with Solarized_Modded only

		# Get the real path to the repo's root
		local repo_realpath=$(git rev-parse --show-toplevel 2> /dev/null)

		# Are we even in a repo?
		if [[ -n "$repo_realpath" ]]; then

			# OK, get the real path to the current dir
			local cur_realpath=$(realpath .)

			# Calculate how deep we are in the repo
			local diff=$((${#cur_realpath} - ${#repo_realpath}))

			# Get the name of the repo (we use PWD instead of repo_realpath in case
			# the repo name is itself a symlink)
			local repo_name=$(basename ${PWD:0:$((${#PWD} - $diff))})

			# Calculate the paths before and after the repo name
			local head=${PWD:0:$((${#PWD} - $diff - ${#repo_name}))}
			if [ $diff -gt 0 ]; then
				local tail=${PWD:$((-$diff))}
			fi

			# Print the full path
			echo -n "$head$(tput setaf 2)$repo_name$(tput setaf 3)$tail$(tput setaf 0)"
		else
			echo -n "\w$(tput setaf 0)"
		fi
	}

	source ~/.bash-git-prompt/gitprompt.sh

elif [ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]; then

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
	# " <-- sacrificial quotes to satisfy bash syntax colouring parsing
fi

# Same thing as prompt_callback, but print the root only.
# This is better than git rev-parse --show-toplevel because
# it keeps symlinks.
function git_root {

    # Get the real path to the repo's root
    local repo_realpath=$(git rev-parse --show-toplevel 2> /dev/null)

    # Are we even in a repo?
    if [[ -n "$repo_realpath" ]]; then
      local cur_realpath=$(realpath .)
      local diff=$((${#cur_realpath} - ${#repo_realpath}))
      local repo_name=$(basename ${PWD:0:$((${#PWD} - $diff))})
      local head=${PWD:0:$((${#PWD} - $diff - ${#repo_name}))}
      echo -n "$head$repo_name"
    fi
}

alias gitr='cd $(git_root)'

# we need this little wrapper so that we can change dir in the current shell
function code() {
	dir=$(/usr/local/bin/code "$@")
	if [ $? -ne 0 ] || [ ! -d "$dir" ]; then
		echo "$dir"
		return 1
	fi
	cd $dir
}

# source any local mods
if [ -f ~/.bashrc.local ]; then
	source ~/.bashrc.local
fi
