#!/bin/bash

#Used variables: May be set outside
#SSH_AGENT_REUSE[=true]
#SSH_AGENT_REUSE_MUST_BE_SOURCED[=true] - By default, when script is runned as regular user, we have not any
#	chance export variables into parent scope. So, this variable should be true in most of cases.
#	BTW, if all this scrip set as alias(sic!), it may be set to false!

	if [[ ${SSH_AGENT_REUSE_MUST_BE_SOURCED=true} && $SECONDS -lt 2 ]]; then
	echo "This script must be sourced ('. $0') instead of simple run. Exiting."
	echo 'Just use next command to do it:'
	echo . $0
	exit
	fi

SSH_AUTH_SOCK=$( ls /tmp/ssh-*/agent.* 2>/dev/null )
	if [[ ! "$SSH_AUTH_SOCK" && ${SSH_AGENT_REUSE=true} != false ]]; then
	eval `/usr/bin/ssh-agent -s | grep SSH_AUTH_SOCK`
	fi

	if [ ! $SSH_AGENT_REUSE_MUST_BE_SOURCED ]; then #For aliasing
	echo "SSH_AUTH_SOCK="$SSH_AUTH_SOCK"; export SSH_AUTH_SOCK"
	else
	export SSH_AUTH_SOCK
	fi
