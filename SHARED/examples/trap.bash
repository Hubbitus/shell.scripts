#!/bin/bash

temp_func(){
echo Список переменных --- a = $a  b = $b
echo '$TRUE='$TRUE
}

trap 'temp_func' EXIT
# EXIT -- это название сигнала, генерируемого при выходе из сценария.

a=39

b=36

	while [ "TRUE" ] #Бесконечно
	do
	echo -n .
	sleep 1
	done

#exit 0