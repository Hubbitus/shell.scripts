#!/bin/bash
# ex33a.sh

# Попробуйте следующие варианты вызова этого сценария.
#   sh ex33a -a
#   sh ex33a -abc
#   sh ex33a -a -b -c
#   sh ex33a -d
#   sh ex33a -dXYZ
#   sh ex33a -d XYZ
#   sh ex33a -abcd
#   sh ex33a -abcdZ
#   sh ex33a -z
#   sh ex33a a
# Объясните полученные результаты.

E_OPTERR=65

#if [ "$#" -eq 0 ]
#	then   # Необходим по меньшей мере один аргумент.
#	echo "Порядок использования: $0 -[options a,b,c]"
#	exit $E_OPTERR
#fi

set -- `getopt "abcd:" "$@"`
# Запись аргументов командной строки в позиционные параметры.
# Что произойдет, если вместо "$@" указать "$*"?

while [ ! -z "$1" ]
do
echo '$1='$1



#	case "$1" in
#		-a) echo "Опция \"a\"";;
#		-b) echo "Опция \"b\"";;
#		-c) echo "Опция \"c\"";;
#		-d) echo "Опция \"d\" $2";;
#		*) break;;
#	esac

	shift
done

#  Вместо 'getopt' лучше использовать встроенную команду 'getopts',
#  См. "ex33.sh".

exit 0