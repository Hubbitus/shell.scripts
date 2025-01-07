#!/usr/bin/bash

# Preferred applications
_notify_command=$( which notify-send 2>/dev/null || which xcowsay 2>/dev/null || which xmessage 2>/dev/null )

# From commandline sent notification. By default try to be persistent (without auto hide timer)!
# If particular command doew not distinguish title and body (like xcowsay) - it will be merged into monotone text
# $1 - body
# $2 - title (optional). If not provided date-time in --rfc-3339 format will be used.
function notify(){
	cmd-$(basename $_notify_command) "$1" "${2:-$(date --rfc-3339=seconds)}" &
}

# $1 - body
# $2 - title (optional)
function cmd-notify-send(){
	${_notify_command} -u critical -i emblem-default "$2" "$1"
}

# $1 - body
# $2 - title (optional)
function cmd-xcowsay(){
	${_notify_command} --time=0 "$2: $1"
}

# $1 - body
# $2 - title (optional)
function cmd-xmessage(){
	${_notify_command} -button Ok "$2: $1"
}

# If it is not sourced (by https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced/28776166#28776166)
# then 1 argument required
if ! (return 0 2>/dev/null) then
	: ${1?"Not enough arguments: `basename $0` text-body [title]"}
	notify "$1" "$2"
fi
