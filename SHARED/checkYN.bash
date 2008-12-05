#!/bin/bash

function checkYN(){
# $1 - message to user. "y/n" will be added automaticaly
# $2 - Default value (How threat empty value: 1 - Yes, 0 - No, other - nothing threat).
# Return 1 in case of answer "yes", 0 - otherwise

local default=-1
local ANS=''
local non_return_mode=0

	#In "set -e" mode, retun non-0 value stop batch. It is not possible in this case
	#In additional in this mode we can't use grep because it return 1 if not found pattern
	if [ '' == "${-##*e*}" ]; then
	echo 'Warning: Non-return mode. Result *only* in $checkYN_result'
	checkYN_result=-1
	non_return_mode=1
	fi

	if [ ${2:--1} -eq 1 ]; then
	echo "$1 (Y/n)"
	default=1
	else
		if [ ${2:--1} -eq 0 ]; then
		echo "$1 (y/N)"
		default=0
		else
		echo "$1 (y/n)"
		fi
	fi

read ANS
ANS=$( echo $ANS | tr 'A-Z' 'a-z' )

#echo ANS=$ANS
#echo default=$default

	if [[ ( '' == "$ANS" && -1 -eq $default ) || ( 'y' != "$ANS" && 'n' != "$ANS" && '' != "$ANS" ) ]]; then
	checkYN "$1" "$2" #recursive call
	#checkYN_result=$?
	[ 1 == $non_return_mode ] || return $checkYN_result
	exit
	fi

	if [[ 'y' == "$ANS" || ( '' == "$ANS" && 1 -eq $default ) ]]; then
	checkYN_result=1
	else
	checkYN_result=0
	fi

[ 1 == $non_return_mode ] || return $checkYN_result
}

#Examples:
#checkYN "Do you want money?" 1
#checkYN "Do you want money?" 0
#checkYN "Do you want money?"