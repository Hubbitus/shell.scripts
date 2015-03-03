#!/bin/bash

# Add element to begin (if lesser) or end (if greather) of ordered array if it still not there.
# $1 - name of array for indirect access ( http://tldp.org/LDP/abs/html/ivr.html )
# $2 - element for addition
function array_ordered_unique_add(){
# http://www.linuxquestions.org/questions/linux-software-2/[bash]-indirect-array-reference-to-array-with-values-containing-spaces-812166/
eval local _arr=(\${${1}[@]})

#echo "_arr=${_arr[@]}, \${_arr[\${#_arr[@]} - 1]}=${_arr[@]:(-1)}"

	if [[ $2 -gt ${_arr[@]:(-1)} || -z "${_arr[@]}" ]]; then
	_arr+=( $2 )
	else
		if [ $2 -lt ${_arr[0]} ]; then # Access last element: http://mywiki.wooledge.org/BashFAQ/005
		_arr=( $2 "${_arr[@]}" )
		else
		echo 'Something strange! Element is not less then minimum and not greather then maximum! May be array is not preordered or have not unique elements?'
		return 1
		fi
	fi

# Indirect set array: http://mywiki.wooledge.org/BashFAQ/006 "Here string syntax"
read -r "$1" <<< "${_arr[@]}"
}
#/f array_ordered_unique_add