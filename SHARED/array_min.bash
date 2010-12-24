#!/bin/bash

# Return minimum element from array. Integer elements assumed.
# $1 - name of array for indirect access ( http://tldp.org/LDP/abs/html/ivr.html )
array_min(){
# http://www.linuxquestions.org/questions/linux-software-2/[bash]-indirect-array-reference-to-array-with-values-containing-spaces-812166/
eval arr=(\${${1}[@]})

min=${arr[0]}

	for item in ${arr[*]}; do
		[ $item -lt $min ] && min=$item
	done
echo $min
}
#/f array_min