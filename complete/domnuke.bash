_domnuke() {
	local cur opts

	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	if [ $COMP_CWORD -ge 1 ]; then
		opts=$(virsh list --all --name)
	else
		return 0
	fi

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _domnuke domnuke
