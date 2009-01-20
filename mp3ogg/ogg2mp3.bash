#!/bin/bash
# Based on python ogg2mp3 by Srdjan Andjelkovic <srdjan . andjelkovic _AT_ gmail . com>
# http://forum.ns-linux.org/cgi-bin/yabb2/YaBB.pl?num=1142887938

#Modify following.
# Output bitrate:
BR=128
# Temporary directory:
TMP="/tmp/"
#Delete .ogg
#Delete=true
Delete=false

function MP3Conv(){
	for name in *.mp3; do
	echo "Process: $name"
	echo -e "\t decoding..."
	nice -n 10 mpg321 -q -w "${TMP}temp.wav" "$name"
	echo -e "\t normalizing..."
#	nice -n 10 normalize --no-progress "${TMP}temp.wav"
	nice -n 10 normalize "${TMP}temp.wav"
	echo -e "\t encoding..."
	nice -n 10 lame -q 7 --nohist --abr "$BR" "${TMP}temp.wav" "$name.ogg"
	rm -f "${TMP}temp.wav"
		if [ $Delete ]; then
		rm "$name"
		fi
	echo "DONE!"
	done
}

function OGGConv(){
	for name in *.ogg; do
	echo "Process: $name"
	echo -e "\t decoding..."
	nice -n 10 oggdec -Q -o "${TMP}temp.wav" "$name"
	echo -e "\t normalizing..."
#	nice -n 10 normalize --no-progress "${TMP}temp.wav"
	nice -n 10 normalize "${TMP}temp.wav"
	echo -e "\t encoding..."
	nice -n 10 lame -q 7 --nohist --abr "$BR" "${TMP}temp.wav" "$name.mp3"
	rm -f "${TMP}temp.wav"
		if [ $Delete ]; then
		rm "$name"
		fi
	echo "DONE!"
	done
}

#OGGConv
MP3Conv