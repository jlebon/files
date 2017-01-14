_dom_listing() {
	local cur opts

	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	if [ $COMP_CWORD -eq 1 ]; then
		if [ $1 == domssh ]; then
			# only give running VMs as options
			opts=$(virsh list --name)
		else
			opts=$(virsh list --all --name)
		fi
	else
		return 0
	fi

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _dom_listing domnuke
complete -F _dom_listing domssh
