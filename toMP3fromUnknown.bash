#!/bin/bash

: ${1?"Порядок использования: `basename $0` any-file-playable-by-mplayer"}

#http://www.linux.org.ru/view-message.jsp?msgid=3136457

FIFO_NAME=myfifo

mkfifo "$FIFO_NAME"
#mplayer -ss 00:03 -ao pcm:file=myfifo "$1" &
mplayer $MPLAYER_ADDON_OPTS -ao pcm:file="$FIFO_NAME" "$1" &
lame ${LAME_OPTS:-'-m m --vbr-new -b 32 -s 22.05'} myfifo "$1.mp3"
rm "$FIFO_NAME"
