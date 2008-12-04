#!/bin/bash

function and_check(){
#$1 - Where
#$2 - What

#instead of:
#[ 1 = $(( 6 & 1 )) ] && echo 1
#just:
#and_check 6 1 && echo 1

[ $2 = $(( $1 & $2 )) ]
}