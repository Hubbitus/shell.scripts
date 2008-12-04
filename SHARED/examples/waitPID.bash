#!/bin/bash

. /home/pasha/bin/waitPID.bash


#( sleep 1 )&
#Silent:
#waitPID.bash $!

#( sleep 10 )&
#Default message & command
#echo $( waitPID.bash $! )

#( sleep 3 )&
#Custom message
#echo $( waitPID.bash $! 'Процесс %d закончился' )

#( sleep 5 )&
#Custom message & command
#echo $( waitPID.bash $! 'Процесс %d закончился' 'echo TTTTT' )


#Concurrent
( sleep 1 )&
waitPID $! "=1= %d" &

( sleep 10 )&
waitPID $! "=2= %d" &

( sleep 3 )&
waitPID $! '=3= %d' &

( sleep 5 )&
waitPID $! '=4= %d' 'echo TTTTT' &

# It is important! Whithout it, subshell output will appear after script end (and will cuted by MC)!
wait

echo DONE