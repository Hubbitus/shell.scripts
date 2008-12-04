#!/bin/bash

# !!!
#При подключении, обазательно должна быть задана переменная $GETOPTS_STRING
#GETOPTS_STRING=":mnopq:rs4:"

# Обработка опций командной строки с помощью 'getopts'.

# Попробуйте вызвать этот сценарий как:
# 'scriptname -mn'
# 'scriptname -oq qOption' (qOption может быть любой произвольной строкой.)
# 'scriptname -qXXX -r'
#
# 'scriptname -qr'    - Неожиданный результат: "r" будет воспринят как дополнительный аргумент опции "q"
# 'scriptname -q -r'  - То же самое, что и выше
#  Если опция ожидает дополнительный аргумент ("flag:"), то следующий параметр
#  в командной строке, будет воспринят как дополнительный аргумент этой опции.

getopt_parse(){
#GETOPTS_STRING=$1
#echo '$GETOPTS_STRING='$GETOPTS_STRING
#echo '$@='$@
#echo '$*='$*
#echo '$1='$1
#echo '$2='$2
#echo '$3='$3
#echo '$4='$4
#NO_ARGS=0
#E_OPTERROR=65

set -- `getopt "$GETOPTS_STRING" "$@"`
#set -- `/usr/bin/getopt --options c: --longoptions longopt "$@"`

	while [ ! -z "$1" -a "$1" != '--' ]; do
	#echo '$1='$1
	#echo '$option='$1'; $OPTARG='$2
	OPTION=${1:1}	#Начальный минус не надо
#	echo '$option='$OPTION'; $OPTARG='$2

		if [ "$OPTION" ]; then
		eval "export OPT$OPTION=\"$2\""
		shift	#$2
		else
		eval "export OPT$OPTION=777"
		fi

#	case "$1" in
#		-a) echo "Опция \"a\"";;
#		-b) echo "Опция \"b\"";;
#		-c) echo "Опция \"c\"";;
#		-d) echo "Опция \"d\" $2";;
#		*) break;;
#	esac
	shift
	done
}

#getopt_parse $@

#echo '$OPT5='$OPT5
#echo '$OPT4='$OPT4
#echo '$OPTs='$OPTs
#echo '$OPTp='$OPTp

