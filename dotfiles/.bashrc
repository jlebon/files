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

	# create the bash alias
	eval alias $1=\"git $2 $3 $4\"

	# add autocomplete support if we find the right functions
	if [ "$(type -t __git_complete)" == "function" ]; then
		if [ "$(type -t _git_$2)" == "function" ]; then
			__git_complete $1 _git_$2
		else
			gitalias=$(git config alias.$2)
			if [ $? -eq 0 ]; then
				__git_complete $1 _git_${gitalias% *}
			fi
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

if [ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]; then

	source /usr/share/git-core/contrib/completion/git-prompt.sh

	function stdprompt_hostname() { # $1 = color
		echo -n "\[\033[0;${1}m\]"
		echo -n "\h"
		echo -n "\[\033[0m\]"
	}

	function stdprompt_time() { # $1 = color
		echo -n "\[\033[0;${1}m\]"
		echo -n "$(date +%H:%M:%S)"
		echo -n "\[\033[0m\]"
	}

	function stdprompt_dir() { # $1 = dir, $2 = git root

		# Get the real path to the repo's root
		local repo_realpath=$(git rev-parse --show-toplevel 2> /dev/null)

		# Get the current dir, but abbreviate homedir if present
		local pwd=$PWD
		if [[ $PWD == $HOME ]]; then
			pwd='~'
		elif [[ $PWD == $HOME/* ]]; then
			pwd='~'${pwd:${#HOME}}
		fi

		# Are we even in a repo?
		if [[ -n "$repo_realpath" ]]; then

			# OK, get the real path to the current dir
			local cur_realpath=$(realpath .)

			# Calculate how deep we are in the repo
			local diff=$((${#cur_realpath} - ${#repo_realpath}))

			# Get the name of the repo (we use pwd instead of repo_realpath in
			# case the repo name is itself a symlink)
			local repo_name=$(basename ${pwd:0:$((${#pwd} - $diff))})

			# Calculate the paths before and after the repo name
			local head=${pwd:0:$((${#pwd} - $diff - ${#repo_name}))}
			if [ $diff -gt 0 ]; then
				local tail=${pwd:$((-$diff))}
			fi

			echo -n "\[\033[0;${1}m\]"
			echo -n "$head"

			echo -n "\[\033[0;${2}m\]"
			echo -n "$repo_name"

			echo -n "\[\033[0;${1}m\]"
			echo -n "$tail"
		else
			echo -n "\[\033[0;${1}m\]"
			echo -n "\w"
		fi

		echo -n "\[\033[0m\]"
	}

	function stdprompt_gitbranch() { # $1 = color
		echo -n "\[\033[0;${1}m\]"
		echo -n "\$(__git_ps1 \"%s\")"
		echo -n "\[\033[0m\]"
	}

	function stdprompt() {

		local rc=$?

		# print hostname
		echo -n "["

		# blue for normal, red for root
		if [ $UID -ne 0 ]; then
			stdprompt_hostname 34
		else
			stdprompt_hostname 31
		fi

		echo -n " "

		# print dir in yellow, git root in green
		stdprompt_dir 33 32

		# purple branch
		if [[ -n "$(git rev-parse --show-toplevel 2>/dev/null)" ]]; then
			echo -n " "
			stdprompt_gitbranch 35
		fi

		echo -n "]"

		if [ $rc -ne 0 ]; then
			echo -n "\[\033[0;31m\]"
		fi

		if [ $UID -ne 0 ]; then
			echo -n "$ "
		else
			echo -n "# "
		fi

		echo -n "\[\033[0m\]"
	}

	PROMPT_COMMAND="PS1=\$(stdprompt)"
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

# little function to easily edit known_hosts when we try to connect to an IP
# whose key changed.
# $1 -- line number of offending RSA key
function delete_known_host() {
	sed -i ${1}d ~/.ssh/known_hosts
}

# source any local mods
if [ -f ~/.bashrc.local ]; then
	source ~/.bashrc.local
fi
