#!/bin/bash

function checkYN(){
# $1 - message to user. "y/n" will be added automaticaly
# $2 - Default value (How threat empty value: 1 - Yes, 0 - No, other - nothing threat).
# Return 1 in case of answer "yes", 0 - otherwise

local default=''
local RES=-1
local ANS=''

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

	if [[ ( '' == "$ANS" && '' == $default ) || ( 'y' != "$ANS" && 'n' != "$ANS" && '' != "$ANS" ) ]]; then
	checkYN "$1" "$2" #recursive call
	exit
	fi

	if [[ 'y' == "$ANS" || 1 -eq $default ]]; then
	RES=1
	else
	RES=0
	fi
echo $RES;
return $RES
}

#Examples:

#checkYN "Do you want money?" 1
#checkYN "Do you want money?" 0
#checkYN "Do you want money?"