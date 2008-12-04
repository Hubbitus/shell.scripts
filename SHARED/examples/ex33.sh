#!/bin/bash
# ex33.sh

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

NO_ARGS=0
E_OPTERROR=65

if [ $# -eq "$NO_ARGS" ]  # Сценарий вызван без аргументов?
then
	echo "Порядок использования: `basename $0` options (-mnopqrs)"
	exit $E_OPTERROR        # Если аргументы отсутствуют -- выход с сообщением о порядке использования скрипта
fi
# Порядок использования: scriptname -options
# Обратите внимание: дефис (-) обязателен

GETOPTS_STRING=":mnopq:rs"

while getopts $GETOPTS_STRING Option
do
#echo $OPTIND
echo '$option='$Option

	if [ $OPTARG ]
	then
	eval "$Option="$OPTARG
#	echo OPTARG=$OPTARG
	else
	let $Option=777
	fi


#	case $Option in
#		m     ) echo "Сценарий #1: ключ -m-";;
#		n | o ) echo "Сценарий #2: ключ -$Option-";;
#		p     ) echo "Сценарий #3: ключ -p-";;
#		q     ) echo "Сценарий #4: ключ -q-, с аргументом \"$OPTARG\"";;
#		# Обратите внимание: с ключом 'q' должен передаваться дополнительный аргумент,
#		# в противном случае отработает выбор "по-умолчанию".
#		r | s ) echo "Сценарий #5: ключ -$Option-"'';;
#		*     ) echo "Выбран недопустимый ключ.";;   # ПО-УМОЛЧАНИЮ
#	esac

done
shift $(($OPTIND - 1))
# Переход к очередному параметру командной строки.

echo '$m='$m
echo '$n='$n
echo '$q='$q
echo '$o='$o

exit 0