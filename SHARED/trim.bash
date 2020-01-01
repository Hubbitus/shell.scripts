#!/bin/bash

# $1 - string to trim spaces from begin and end of.
function trim(){
	echo $1 | sed -r 's/^\s*(.+)\s*$/\1/'
}
