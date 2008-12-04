#!/bin/bash
# embedded-arrays.sh
# Вложенные массивы и косвенные ссылки.

# Автор: Dennis Leeuw.
# Используется с его разрешения.
# Дополнен автором документа.


ARRAY1=(
VAR1_1=value11
VAR1_2=value12
VAR1_3=value13
)

ARRAY2=(
VARIABLE="test"
STRING="VAR1=value1 VAR2=value2 VAR3=value3"
ARRAY21=${ARRAY1[*]}
)       # Вложение массива ARRAY1 в массив ARRAY2.


function print () {
OLD_IFS="$IFS"
IFS=$'\n'       #  Вывод каждого элемента массива
#+ в отдельной строке.
TEST1="ARRAY2[*]"
local ${!TEST1} # Посмотрите, что произойдет, если убрать эту строку.
#  Косвенная ссылка.
#  Позволяет получить доступ к компонентам $TEST1
#+ в этой функции.


#  Посмотрим, что получилось.
echo
echo "\$TEST1 = $TEST1"       #  Просто имя переменной.
echo; echo
echo "{\$TEST1} = ${!TEST1}"  #  Вывод на экран содержимого переменной.
#  Это то, что дает
#+ косвенная ссылка.
echo
echo "-------------------------------------------"; echo
echo


# Вывод переменной
echo "Переменная VARIABLE: $VARIABLE"

# Вывод элементов строки
IFS="$OLD_IFS"
TEST2="STRING[*]"
local ${!TEST2}      # Косвенная ссылка (то же, что и выше).
echo "Элемент VAR2: $VAR2 из строки STRING"

# Вывод элемента массива
TEST2="ARRAY21[*]"
local ${!TEST2}      # Косвенная ссылка.
echo "Элемент VAR1_1: $VAR1_1 из массива ARRAY21"
}

print
echo

exit 0