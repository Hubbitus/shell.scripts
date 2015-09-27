#!/bin/bash

# Borrowed from http://bobcopeland.com/blog/2012/10/goto-in-bash/ (only function renamed to goto) and slightly modified.

# include this boilerplate
function goto(){
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

#start=${1:-"start"}
#
#goto $start
#
#start:
## your script goes here...
#x=100
#goto foo
#
#mid:
#x=101
#echo "This is not printed!"
#
#foo:
#x=${x:-10}
#echo x is $x
#
#results should be:
#
#
#$ ./test.sh
#x is 100
#$ ./test.sh foo
#x is 10
#$ ./test.sh mid
#This is not printed!
#x is 101