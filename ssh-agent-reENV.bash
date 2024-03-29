#!/bin/bash

# Used variables: May be set outside
# SSH_AGENT_REUSE[=true]
# SSH_AGENT_REUSE_MUST_BE_SOURCED[=true] - By default, when script is run as regular user, we have not any
#	chance export variables into parent scope. So, this variable should be true in most of cases.
#	BTW, if all this script set as alias(sic!), it may be set to false!

	if [[ ${SSH_AGENT_REUSE_MUST_BE_SOURCED=true} && $SECONDS -lt 2 ]]; then
	echo "This script must be sourced ('. $0') instead of simple run. Exiting."
	echo 'Just use next command to do it:'
	echo . $0
	exit
	fi

#D ECHO_DEBUG=true
function echo_debug(){
	[ "$ECHO_DEBUG" ] && echo "$@"
}

	if ls "$SSH_AUTH_SOCK" &>/dev/null ; then
		echo_debug "Ssh-agent already running. Exit."
		exit 0 ; #All seems OK, search and ReEnv not needed
	else
		echo_debug "Ssh-agent socket [$SSH_AUTH_SOCK] seems to not exist? Search will be performed."
	fi

#Start searching
SSH_AUTH_SOCK=''
SSH_AGENT_PID=''

find /tmp/ -wholename '/tmp/ssh-*/agent.*' -user `id -u` 2>/dev/null | (	# About "(" Read http://bappoy.pp.ru/2008/12/18/bash-pitfalls-part02.html item #7 why we need it!!!
										# We need set SSH_AUTH_SOCK in while-cycle.
	while read socket ; do # Check all, cleanup dead
		agent_pid=$[ ${socket##*.} + 1 ] # I don't known why +1 needed!
		echo_debug socket=$socket
		SSH_AUTH_SOCK="$socket" ssh-add -l &>/dev/null # 0 and 1 ("The agent has no identities.") status is good for us.

		if ! [[ $? -eq 0 || $? -eq 1 ]] ; then
			echo_debug 'Process dead! Cleanup it.'
			rm "$socket"
		else
			echo_debug 'Finded, alive'
			SSH_AUTH_SOCK="$socket"
			break; # First occurancies
		fi
	done

	if [[ ! "$SSH_AUTH_SOCK" && ${SSH_AGENT_REUSE=true} != false ]]; then
		# We there if no working sockets found. So, for ensurance cleanup all process:
		killall --user $USER ssh-agent &>/dev/null

		echo_debug 'Start new ssh-agent'
		eval `/usr/bin/ssh-agent -s | grep -v echo`
	fi

	if [ ! $SSH_AGENT_REUSE_MUST_BE_SOURCED ]; then #For aliasing
		echo "SSH_AUTH_SOCK="$SSH_AUTH_SOCK"; export SSH_AUTH_SOCK"
	else
		export SSH_AUTH_SOCK
	fi
)
