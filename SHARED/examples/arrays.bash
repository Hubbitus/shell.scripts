#!/bin/bash

#http://gazette.lrn.ru/rus/articles/abs-guide/c13072.html

# Вспомним:
#   $( ... ) -- вызов функции.
#   Функция запускается как подпроцесс.
#   Функции выводят на stdout.
#   Присваивание производится со stdout функции.
#   Запись name[@] -- означает операцию "for-each".

arrayZ=( one two three four five )

newstr() {
#    echo -n "!!!"
	echo =$0=
}

#echo ${arrayZ[@]/%e/$(newstr)}
#echo ${arrayZ[@]/%/$(newstr)}
# on!!! two thre!!! four fiv!!! fiv!!!
# Q.E.D: Замена -- суть есть "присваивание".
#exit

#  Доступ "For-Each" -- ко всем элементам массива
echo ${arrayZ[@]//*/$(newstr optional_arguments)}
#  Now, if Bash would just pass the matched string as $0
#+ to the function being called . . .

echo
