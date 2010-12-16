#!/bin/bash
# assert.sh
# Got from: http://tldp.org/LDP/abs/html/debugging.html

#######################################################################
# $1 - assertion to test
# $2 - (optional) - text of error to add in output if assertion failed
assert ()                 #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.
E_ASSERT_FAILED=99

	if [ ! $1 ]; then
	echo "Assertion failed:  \"$1\". $2"
	echo "Caller (line, file): $( caller )"
	exit $E_ASSERT_FAILED
	fi
}
#######################################################################


# When command executed in pipe it acts in subshell according to bash man
# (and http://webcache.googleusercontent.com/search?q=cache:MgGItz54hdgJ:steve-parker.org/sh/functions.shtml+bash+exit+in+piped+function&cd=4&hl=ru&ct=clnk&gl=ru )
# There no standard way to terminate parent (main script) in this case regard of used "return" or "exit" statements in function:
# http://stackoverflow.com/questions/4419952/difference-between-return-and-exit-in-bash-functions , http://stackoverflow.com/questions/1816824/exit-entire-program-from-a-function-call-in-shell .
# Exception from that I found solution kill himself like "kill $$" - http://www.unix.com/shell-programming-scripting/138182-functions-exit-kill-bash.html
# It may work in this particular solution, but also have some downsides like unavailable pass status code, may kill not intended script when it sourced and so on.
# Another way do that job is explicitly check $PIPESTATUS special variable (More examples and detailes: http://unix.derkeiler.com/Newsgroups/comp.unix.shell/2005-06/1079.html )
# So, to provide also exit code from assert I wrote this small helper function.
#
# Example of usage:
# assert '1 -gt 2' | tee LOG
# pipe_check_exit ${PIPESTATUS: -1}
#
# $1 - pipestatus code
function pipe_check_exit(){
#	[ ${PIPESTATUS: -1} -gt 0 ] && exit ${PIPESTATUS: -1}
	[ $1 -gt 0 ] && exit $1
}
#/f pipe_check_exit

# $1 = message to log
function log(){
	echo "$1" | tee -a "$LOG"
}
#/f log