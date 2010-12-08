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
