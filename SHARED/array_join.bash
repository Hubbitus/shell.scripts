#!/bin/bash

# Function to join array by separator.
# $1 - separator
# $2 - array (declare
# Compilation of recipes from http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array
# Safe for arrays with elements having spaces and multi-symbol separators (unlike solutions on IFS changing)
function array_join() {
	# http://www.linuxquestions.org/questions/programming-9/bash-passing-arrays-with-spaces-611159/#post3012084
	sep=$1
	shift

	#printf "%s\n" "$@"

	IFS=;
	res="${*/#/$sep}"
	echo ${res:${#sep}}
}

# Example of call:
# foo=('foo bar' 'foo baz' 'bar baz')
# array_join '<!>' "${foo[@]}"
# Res: foo bar<!>foo baz<!>bar baz
# Or just:
# array_join '<!>' 'foo bar' 'foo baz' 'bar baz'
# Res: foo bar<!>foo baz<!>bar baz
