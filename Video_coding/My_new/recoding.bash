#!/bin/bash

set +x

PH="/mnt/maxtor/films_from_net/12"
READYPH="/mnt/maxtor/films_from_net/12"

NICE=17
#ENG=129
#RUS=128
FPS=25
#DATE="`date +%H%M%d`"
#EXT="*.vob *.avi"
#Можно полное имя файла
#EXT="*.avi"

LOGFILE='log.LOG'

###!Во внешнем Tries! основные настройки!
. ./Tries

	if [ $1 ]; then
	EXT=$1
	else
	echo Нету аргументов. Должен передаваться файл для обработки. Завершаю работу.
	exit
	fi

	#PASS:
	# 1- Перавый проход
	# 2- Второй проход
	# 3- ОБА, прохода
	if [ $2 ]; then
	PASS=$2
	else
	PASS=3		#2(оба) прохода
	fi

	if [[ 1 = $PASS || 3 = $PASS ]]
	then
		#cat $PH/$EXT | nice -n $NICE mencoder - -ofps $FPS -ni \
	(
	echo Первый проход:
	nice -n $NICE mencoder "$PH/$EXT" $ENDPOS -ofps $FPS $EXT_OPTIONS \
	$VIDEO_CODING_1pass \
	-nosound \
	-o /dev/null \
	$FRAMES $ENDPOS 2>&1) | tee $LOGFILE
	fi

cp divx2pass.log $READYPH/"${DONE_PREFIX}_${EXT}_divx2pass1.log"

	if [[ 2 = $PASS || 3 = $PASS ]]
	then
	(
	echo Второй проход:
	nice -n $NICE mencoder $PH/$EXT -ofps $FPS \
	$AUDIO_OPTIONS \
	$EXT_OPTIONS \
	$VIDEO_CODING_2pass \
	$VIDEO_FILTERS \
	-o $READYPH/${DONE_PREFIX}$EXT \
	$FRAMES $ENDPOS 2>&1) | tee $LOGFILE
	fi

mv divx2pass.log $READYPH/"${DONE_PREFIX}_${EXT}_divx2pass.log"

#Звук завершения
php /var/www/temp/web_play.php
