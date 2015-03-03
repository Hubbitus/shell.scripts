#!/bin/bash

#http://gazette.lrn.ru/rus/articles/abs-guide/c13072.html
# http://tldp.org/LDP/abs/html/arrays.html

# Вспомним:
#   $( ... ) -- вызов функции.
#   Функция запускается как подпроцесс.
#   Функции выводят на stdout.
#   Присваивание производится со stdout функции.
#   Запись name[@] -- означает операцию "for-each".

arrayZ=( one two 'three & four' five )
echo "initial array@: ${arrayZ[@]}"
echo "initial array*: ${arrayZ[*]}"

newstr(){
    echo -n "!!!"
}

# Function may be called:
#echo ${arrayZ[@]/%e/$(newstr)}
#Res: on!!! two thre!!! four fiv!!! fiv!!!
echo ${arrayZ[@]/%/$(newstr)}

# Or just:
# echo "${arrayZ[*]/%/<!>}"
# Res: one<!> two<!> three & four<!> five<!>
# echo "${arrayZ[@]/%/<!>}"
# Res: one<!> two<!> three & four<!> five<!>
# But what if we JOIN or IMPLODE there trailing elements differencies:
IFS=;
echo "${arrayZ[*]/%/<!>}"
# Res: one<!>two<!>three & four<!>five<!>
echo "${arrayZ[@]/%/<!>}"
# Res: one<!> two<!> three & four<!> five<!>

echo "${arrayZ[*]/#/<!>}"
#Res: <!>one<!>two<!>three & four<!>five
echo "${arrayZ[@]/#/<!>}"
#Res: <!>one <!>two <!>three & four <!>five

# one!!! two three!!! four five!!! five!!!
# Q.E.D: Замена -- суть есть "присваивание".
#exit

#  Доступ "For-Each" -- ко всем элементам массива
# echo ${arrayZ[@]//*/$(newstr optional_arguments)}
#  Now, if Bash would just pass the matched string as $0
#+ to the function being called . . .

echo
