#!/bin/bash
# assert.sh
# Got from: http://tldp.org/LDP/abs/html/debugging.html

#######################################################################
assert ()                 #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.
E_ASSERT_FAILED=99

	if [ ! $1 ]; then
	echo "Assertion failed:  \"$1\""
	echo "Caller (line, file): $( caller )"
	exit $E_ASSERT_FAILED
	fi
}
#######################################################################
