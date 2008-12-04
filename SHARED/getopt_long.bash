#!/bin/bash

# !!!
#При подключении, обазательно должна быть задана переменная $GETOPTS_STRING
#GETOPT_STRING=":mnopq:rs4:"
#LONG_GETOPT_STRING="longopt-one, longopt-two:, longoptthree::"

#Переписано с использованием длинных опций, взяв за пример http://software.frodo.looijaard.name/getopt/docs.php

getopt_CMD=/usr/bin/getopt

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

long_getopt_parse(){
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

set -- `$getopt_CMD -u --options "$GETOPT_STRING" --longoptions "$LONG_GETOPT_STRING" "$@"`
#set -- `/usr/bin/getopt --options c: --longoptions longopt "$@"`

	while [ ! -z "$1" -a "$1" != '--' ]; do
	#echo '$1='$1
	#echo '$option='$1'; $OPTARG='$2
	#Начальный "-" или "--" не надо
	OPTION=${1/#-/}		#One
	OPTION=${OPTION/#-/}	#May be two
#	echo '$OPTION='$OPTION'; $OPTARG='$2

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
#Echo tail, to renew in caller
echo $@
}

#getopt_parse $@

#echo '$OPT5='$OPT5
#echo '$OPT4='$OPT4
#echo '$OPTs='$OPTs
#echo '$OPTp='$OPTp

