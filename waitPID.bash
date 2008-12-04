#!/bin/bash

SLEEP_INTERVAL=0.5 #Seconds

function waitPID(){
#$1 PID for wait
#$2 - Message on end. printf format. ( On place "%d" PID will be placed. )
#$3 - Additional Command to execute on end. By defualt invoke web_play.php. One more usefull example is xmessage call.

#Debug
#set -x
	{
		while [ `ps -p $1 | wc -l` -gt 1 ]; do
		sleep $SLEEP_INTERVAL
		done

	printf "${2-"PID %d ENDED!"}" $1

	echo
		#In short form: ${3-/usr/bin/php /var/www/temp/web_play.php &>/dev/null} don't worked redirection. It
		# ('&>/dev/null') passed as argument to script. Unless we can made command quite by its arguments, like worked example:
		# ${3-wget -q http://temp/web_play.php -O /dev/null} we can't use that.
		# So, just use full "if" form to avoid this constraints.
		if [ "$3" ]; then
		$3
		else # default variant
		php /var/www/temp/web_play.php &>/dev/null &
		fi
	} 
	# $
	# ^ Now, if you want non-blocking wait, you must add & to call of this function manually

}

	#If arguments not present - file sourced and function must be called after.
	if [ "$1" ]; then #Defaults call
	waitPID "$@"
	fi