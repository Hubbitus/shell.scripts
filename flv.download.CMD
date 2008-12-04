#!/bin/bash

#wget -c "http://www.intv.ru/view/?film_id=25581&playNow=1" -O 1.htm

#grep -oP '(?<=value=")(&lt;object.*?)"' 1.htm | php -r 'echo html_entity_decode(file_get_contents("php://stdin"));'
# sed 's/&quot;/"/g' | sed 's/&lt;/</g' | sed 's/&gt;/>/g'

: ${1?"Порядок использования: `basename $0` target-URL save-file-name"}
: ${2?"Порядок использования: `basename $0` target-URL save-file-name"}

#Default system
BASEURL='http://intv.ru/view/?film_id='

	expr "$1" '+' 1
	if [ $? -eq 0 ]; then #Numeric. Get default system URL
	URL="$BASEURL$1"
	else #Full URL provided
	URL="$1"
	fi

#Host: cs.videosaver.ru
#User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9pre) Gecko/2008050614 Remi/fc8 Firefox/3.0pre
#Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
#Accept-Language: ru,en-us;q=0.7,en;q=0.3
#Accept-Encoding: gzip,deflate
#Accept-Charset: windows-1251,utf-8;q=0.7,*;q=0.7
#Keep-Alive: 300
#Connection: keep-alive
#Content-Type: application/x-www-form-urlencoded; charset=UTF-8
#Referer: http://cs.videosaver.ru/form.html?v=0.50&partner=http%3A//videosaver.ru/%3Furl%3Dhttp%3A//www.intv.ru/view/%3Ffilm_id%3D25654%26playNow%3D1
#Content-Length: 62
#Cookie: ucvid=nuBP53wI2R; __utma=188832812.1411373195.1211097450.1211097450.1211101322.2; __utmc=188832812; __utmz=188832812.1211097450.1.1.utmccn=(referral)|utmcsr=64.233.183.104|utmcct=/search|utmcmd=referral; JSESSIONID=abcmFTnt9hK9S9ujse7Nr; __utmb=188832812
#Pragma: no-cache
#Cache-Control: no-cache

function getLinksFromVideosaver(){
# $1 - URL

#wget -O URL.link http://cs.videosaver.ru/url/ --post-data='url=http%3A//www.intv.ru/view/%3Ffilm_id%3D25654%26playNow%3D1'
LINKS=$( wget -O- http://cs.videosaver.ru/url/ --post-data="url=$1" )

echo $LINKS | grep -oP "http://.*?(?=')" || echo "$LINKS"
}

function getLinksFrom0download(){
# $1 - URL

LINKS=$( wget -O- "http://0download.ru/url=$URL" | grep -oP '(?<=href=")http://dl.*?(?=")' )
#echo LINKS=$LINKS

echo $LINKS | grep -oP "http://.*?(?=')" || echo "$LINKS"
}


LINKS=$( getLinksFromVideosaver "$URL" )

#LINKS=$( cat ttt.htm )
echo LINKS=$LINKS

	if [ "$LINKS" = 'INCORRECT_URL' -o "$LINKS" == 'UNFOUND_VIDEO' -o 'INTERNAL_ERROR' = "$LINKS" -o 'RETRIEVE_DATA_ERROR' = "$LINKS" -o '' = "$LINKS" ]; then #try 0download.ru
	LINKS=$( getLinksFrom0download "$URL" )
	fi

#echo LINKS Count=${#LINKS[*]}
tmp=( $LINKS )
echo LINKS Count=${#tmp[@]}

# Download
i=0
	echo "$LINKS" | \
		while read url; do
		file=$( echo "$2" | sed "s/#/$i/" )
			if [ "$2" = $file -a ${#tmp[@]} -gt 1 ] ; then
			file="${2%\.*}_$i.${2##*\.}"
			fi
		echo "Download URL=$url to file=$file"

		wget -c "$url" -O "$file" &

		(( ++i ))
		done || echo 'Link not found'
