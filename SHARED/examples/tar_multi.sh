#!/bin/bash

COUNT=`ls -1 $1* | wc -l`

mv $1 $1.part$(( $COUNT-1 ))
echo Part $1.part$(( $COUNT-1 )) created

#А собственно использовать так
#tar -cML40 -F "./tar_multi.sh tara.tar" -f tara.tar ./1_small
