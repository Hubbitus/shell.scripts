#!/bin/bash

SLEEP_INTERVAL=0.5 #Seconds

source ~/bin/SHARED/notify.bash

#$1 - PID for wait
#$2 - Message on end. printf format. ( On place "%d" PID will be placed. )
#$3 - Additional Command to execute on end. By defualt invoke web_play.php. One more usefull example is xmessage call.
function waitPID(){
	local command="$(ps -o args= -p $1)"

	while  ps -p $1 &>/dev/null; do
		sleep $SLEEP_INTERVAL
	done

	notify "$( printf "${2-"PID %d (%s) ENDED!"}" $1 "$command" )"

	#In short form: ${3-/usr/bin/php /var/www/temp/web_play.php &>/dev/null} don't worked redirection. It
	# ('&>/dev/null') passed as argument to script. Unless we can made command quite by its arguments, like worked example:
	# ${3-wget -q http://temp/web_play.php -O /dev/null} we can't use that.
	# So, just use full "if" form to avoid this constraints.
	if [ "$3" ]; then
		$3
	else # default variant
		mpv /usr/share/sounds/Oxygen-Sys-App-Positive.ogg &>/dev/null &
	fi
}

# If it is not sourced (by https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced/28776166#28776166)
# then 1 argument required
if ! (return 0 2>/dev/null) then
	: ${1?"Not enough arguments: `basename $0` pid"}
	waitPID "$@"
fi
