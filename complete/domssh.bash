_domssh() {
	local cur prev opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"

	# we have no use for the previous word here
	#prev="${COMP_WORDS[COMP_CWORD-1]}"

	# name of the VM
	if [ $COMP_CWORD = 1 ]; then

		# get list of running VMs
		opts=$(virsh list --name)

	# username
	elif [ $COMP_CWORD = 2 ]; then
		opts="cloud-user vm root"

	# password
	elif [ $COMP_CWORD = 3 ]; then
		opts="vm atomic"

	else
		return 0
	fi

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _domssh domssh
