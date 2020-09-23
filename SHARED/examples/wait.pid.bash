#!/bin/bash

source ../../wait.pid.bash


#( sleep 1 )&
#Silent:
#waitPID.bash $!

#( sleep 10 )&
#Default message & command
#echo $( waitPID.bash $! )

#( sleep 3 )&
#Custom message
#echo $( waitPID.bash $! 'Process %d finished' )

#( sleep 5 )&
#Custom message & command
#echo $( waitPID.bash $! 'Process %d finished' 'echo TTTTT' )


#Concurrent
( sleep 1 )&
waitPID $! '[%s] command ended. PID: %d' &

( sleep 10 )&
waitPID $! '[%s] command ended. PID: %d' &

( sleep 3 )&
waitPID $! &

( sleep 5 )&
waitPID $! '[%s] command ended. PID: %d' 'echo TTTTT' &

# It is important! Whithout it, subshell output will appear after script end (and will cuted by MC)!
wait

echo DONE
