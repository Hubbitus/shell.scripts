#!/bin/bash

#QQQ=
#timE=
##time read QQQ 2>&1 > qFile

#Работает
#timE=`date +'%s'`
#read QQQ
#(( seconds = `date +'%s'` - $timE ))


#читает что-то в указанную переменную, и считает за сколько СЕКУНД был ответ.
#Время в секундах*, доступно в переменной $ReadSeconds
#* BASH не оперирует числами с плавающей запятой, можно было бы для этого конечно использовать bc,
# и запрашивать дату с наносекундами, да это пока не актуально и менее переносимо
function timedread(){
timeSec=`date +'%s'`
read $1
(( ReadSeconds = `date +'%s'` - $timeSec ))
};


#Пример использования:
#timedread QAZ
#echo "Прочитано следующее: $QAZ"
#echo "Прочитано за $ReadSeconds секунд"
