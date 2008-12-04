#!/bin/bash


#Навеяно http://ru2.php.net/manual/ru/function.str-pad.php
function strpad(){
#$1(opt, default $ROWS of current terminal) - How many repetitions (chars, if $2 is 1 char) needed
#$2(opt, default "="). May be any string, not only one char.

	if [ '' = "$1" -o '-1' = "$1" -o '0' = "$1" ]; then
	. /home/pasha/bin/SHARED/rows_columns.bash
	else
	COLUMNS=$1
	fi

#2>/dev/null because dd print statistic on stderr like this:
#102+0 записей считано
#102+0 записей написано

	if [ ${#t} -gt 1 ]; then	#Optimisation only
	#Напрямую без tr нельзя, потому что sed почему-то не понимает совершенно \0 и пропускает его, никак не обрабатывая, даже если стоит . на совпадение!
	#Можно для всех случаев использовать. Не оставить только tr потому что нет возможности заменять на строку произвольной длины, только посимвольная замена
	dd if=/dev/zero bs=1 count=$COLUMNS status=noxfer 2>/dev/null | tr '\0' '1' | sed "s/1/${2-=}/g"
	else	#Вариант без множественных преобразований чуууточку быстрее должен быть
	dd if=/dev/zero bs=1 count=$COLUMNS status=noxfer 2>/dev/null | tr "\0" "${2-=}"
	fi
}