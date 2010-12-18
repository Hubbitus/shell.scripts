#!/bin/bash

# Search for needle ($1) is in array ($2)
# $1 - needle
# $2 - name of array for indirect access ( http://tldp.org/LDP/abs/html/ivr.html )
in_array(){
# http://www.linuxquestions.org/questions/linux-software-2/[bash]-indirect-array-reference-to-array-with-values-containing-spaces-812166/
eval arr=(\${${2}[@]})

	for item in ${arr[*]}; do
		[ "$item" = "$1" ] && return 0
	done
return 1
}