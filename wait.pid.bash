#!/bin/bash

SLEEP_INTERVAL=0.5 #Seconds

source "$(dirname $0)/SHARED/notify.bash"

# Allow redefinition outside!
: ${MESSAGE_FORMAT:="Command [%s] with pid [%d] finished!"}
: ${CMD:=mpv /usr/share/sounds/Oxygen-Sys-App-Positive.ogg}


# Function to wait end of some app by watching PID dissapear in process list.
# See SHARED/examples/wait.pid.bash for usage directions
#
#$1 - PID for wait
#$2 - Message on the end. printf format. ("%s" will be replaced by actual executed command, "%d" - PID will be placed)
#$3 - Additional Command to execute at the end. By defualt play /usr/share/sounds/Oxygen-Sys-App-Positive.ogg
function waitPID(){
	local command="$(ps -o args= -p $1)"

	while ps -p $1 &>/dev/null; do
		sleep $SLEEP_INTERVAL
	done

	notify "$( printf "${2-$MESSAGE_FORMAT}" "$command" $1 )"

	#In short form: ${3-/usr/bin/php /var/www/temp/web_play.php &>/dev/null} don't work redirection. It
	# ('&>/dev/null') passed as argument to script. Unless we can made command quite by its arguments, like:
	# ${3-wget -q http://temp/web_play.php -O /dev/null} we can't use that.
	# So, just use full "if" form to avoid this constraints.
#	if [[ "$3" || "$CMD" ]]; then
#		${3}${CMD}
#	else # default variant
#		
#	fi
	exec ${3-$CMD} &>/dev/null &
}

# If it is not sourced (by https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced/28776166#28776166)
# then 1 argument required
if ! (return 0 2>/dev/null) then
	: ${1?"Not enough arguments: `basename $0` pid"}
	waitPID "$@"
fi
