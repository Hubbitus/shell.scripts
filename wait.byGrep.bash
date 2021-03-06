#!/bin/bash

: ${1?"Not enough arguments: `basename $0` posix-extended-RegExp-for-run-process-command [message on end] [command execute on end]
For parameters extended description see in waitPID.bash script
You may use also variables, f.e:
(sleep 2&); CMD='mpv /usr/share/sounds/gnome/default/alerts/sonar.ogg' ./wait.byGrep.bash sleep
"}

source $(dirname $0)/wait.pid.bash

regexp="$1"
shift

# Fully bufferize into variable first to do not catch self sub-shels in processes (excluding processes with himself)!
PROCESSES=$( pgrep -af "$regexp" | grep -v $( basename $0 ) )

echo "$PROCESSES" | while read pid command; do
	[[ $$ == $pid ]] && continue # exclude self
	echo "Will watch: pid=[$pid], command=[$command]"
	waitPID $pid "$@" &
done
