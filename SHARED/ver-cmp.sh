#!/bin/sh

function vercompare(){
# $1 - version string one
# $2 - version string two
# Print result (negative values return not allowed) of Integer difference ver1 - ver2.
# WARNING: mean have only sign. Do not rely on difference absolute value.
# Author: Pavel Alexeev (aka Pahan-Hubbitus)

# 1.11, 1.6, # 1.6.1
verarr1=( $( echo "$1" | sed 's/\./ /g' ) )
verarr2=( $( echo "$2" | sed 's/\./ /g' ) )
maxgrade=$( if [ ${#verarr1[@]} -gt ${#verarr2[@]} ]; then echo ${#verarr1[@]}; else echo ${#verarr2[@]}; fi )

	for (( i=0; i<maxgrade; i++)); do
		[ "${verarr1[i]}" = '' ] && verarr1[i]=0
		[ "${verarr2[i]}" = '' ] && verarr2[i]=0
	intver1=${intver1}${verarr1[i]}
	intver2=${intver2}${verarr2[i]}
	done
echo $[ $intver1 - $intver2 ]
}

vercompare "1.6" "1.6.1"