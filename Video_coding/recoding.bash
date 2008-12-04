#!/bin/bash

PH="./"
READYPH=$PH"/done"
###!Во внешнем Tries!
###BITRATE=-1024000
#BITRATE=917
NICE=15
#ENG=129
#RUS=128
FPS=25
#DATE="`date +%H%M%d`"
#EXT="*.vob *.avi"
#Можно полное имя файла
#EXT="*.avi"

LOGFILE='log.LOG'

ENDPOS=''
#ENDPOS="-endpos 60" #Первые 60 секунд
#FRAMES='-frames 300'

. ./Tries

#VIDEO_OPTIONS_1pass='gmc:vhq=4:me_quality=6:qpel:trellis:chroma_opt:quant_type=h263'
#VIDEO_OPTIONS_1pass='gmc:vhq=4:me_quality=6:trellis:chroma_opt:quant_type=h263'
#VIDEO_OPTIONS_1pass='gmc:vhq=1:qpel:me_quality=6:trellis:chroma_opt:quant_type=h263'
#VIDEO_OPTIONS_1pass='gmc:vhq=1:qpel:me_quality=6:trellis:chroma_opt:quant_type=h263:hq_ac:autoaspect'
#VIDEO_OPTIONS_1pass='gmc:vhq=1:qpel:me_quality=6:trellis:chroma_opt:quant_type=h263:hq_ac:aspect=4/3'
###!Во внешнем Tries!
###VIDEO_OPTIONS_1pass='gmc:vhq=1:qpel:me_quality=6:trellis:chroma_opt:quant_type=h263:hq_ac:autoaspect=1'
VIDEO_OPTIONS_2pass=$VIDEO_OPTIONS_1pass

#AUDIO_OPTIONS='-oac copy'
AUDIO_OPTIONS='-oac mp3lame -lameopts cbr=3:br=128:q=0:aq=0'

#EXT_OPTIONS='-forceidx -noodml -ffourcc divx'
#EXT_OPTIONS='-forceidx -noodml -ffourcc DX50'
###!Во внешнем Tries!
###EXT_OPTIONS='-forceidx -noodml'
#EXT_OPTIONS=''
#EXT_OPTIONS='-ni'

#lb/linblenddeint	-- Linear blend deinterlacing filter that deinterlaces the given block by filtering all lines with a (1 2 1) filter.
#li/linipoldeint 	-- Linear  interpolating  deinterlacing  filter that deinterlaces the given block by linearly interpolating every second line.
#ci/cubicipoldeint	-- Cubic interpolating deinterlacing filter deinterlaces the given block by cubically interpolating every second line.
#md/mediandeint		-- Median deinterlacing filter that deinterlaces the given block by applying a median filter to every second line.
#fd/ffmpegdeint		-- FFmpeg deinterlacing filter that deinterlaces the given block by filtering every second line with a (-1 4 2 4 -1) filter.
#l5/lowpass5		-- Vertically applied FIR lowpass deinterlacing filter that deinterlaces the given block by filtering all lines with a (-1 2 6 2 -1) filter.
#Через запятую, с нее и начинать!
#ADDON_VIDEO_FILTERS=',spp=6,uspp=8'
#ADDON_VIDEO_FILTERS=',hqdn3d=2:1:2,scale=500:400:1:0:0.00:0.50 -sws 2'

#VIDEO_FILTERS='-vf scale=304:240:1:0:0.00:0.50,hqdn3d=2:1:2,pp=fd/hb/vb/dr/al -sws 2'
#VIDEO_FILTERS='-vf hqdn3d=2:1:2,pp=fd/hb/vb/dr/al'
#VIDEO_FILTERS='-vf scale=720:540:1:0:0.00:0.50,hqdn3d=2:1:2,pp=fd/hb/vb/dr/al -sws 2'
###!Во внешнем Tries!
###VIDEO_FILTERS='-vf ilpack,dsize=4/3:-2,scale=720:544:1:0:0.00:0.50,pp=fd/hb/vb/dr/al -sws 2 '

#VIDEO_FILTERS="-vf pp=hb/vb/dr/al/l5${ADDON_VIDEO_FILTERS}"
###VIDEO_FILTERS="-vf pp=fd${ADDON_VIDEO_FILTERS}"


#-pp			-- Enables the specified chain of postprocessing subfilters. (Через Слешь!!)
##-ni (AVI only)		-- Force usage of non-interleaved AVI parser (fixes playback of some bad AVI files).
##-forceidx		-- Force index rebuilding.
##-noskip		-- Do not skip frames.
##-sws <software scaler type> (also see -vf scale and -zoom)
#Specify the software scaler algorithm to be used with the -zoom option. This affects video output drivers which lack hardware acceleration, e.g. x11.
#    Available types are:
#    0	fast bilinear
#    1	bilinear
#    2	bicubic (good quality) (default)
#    3	experimental
#    4	nearest neighbor (bad quality)
#    5	area
#    6	luma bicubic / chroma bilinear
#    7	gauss
#    8	sincR
#    9	lanczos
#    10	natural bicubic spline
#NOTE: Some -sws options are tunable.  The description of the scale video filter has further information.
##/-sws


	if [ $1 ]
	then
	EXT=$1
	else
	echo Нету аргументов. Должен передаваться файл для обработки. Завершаю работу.
	exit
	fi

	#PASS:
	# 1- Перавый проход
	# 2- Второй проход
	# 3- ОБА, прохода
	if [ $2 ]
	then
	PASS=$2
	else
	PASS=3	#2(оба) прохода
	fi

#mencoder CDRR.s2e01.To.the.Rescue.[DisneyJazz].avi -ovc copy -oac mp3lame -lameopts vbr=3:br=192:q=0:aq=0 -o output-mp3.avi

    if [[ 1 = $PASS || 3 = $PASS ]]
    then
#cat $PH/$EXT | nice -n $NICE mencoder - -ofps $FPS -ni \
    (
    echo Первый проход:
    nice -n $NICE mencoder $PH/$EXT $ENDPOS -ofps $FPS $EXT_OPTIONS \
    -ovc xvid -noskip -xvidencopts pass=1:${VIDEO_OPTIONS_1pass} \
    -nosound \
    -o /dev/null \
    $FRAMES $ENDPOS 2>&1) | tee $LOGFILE
    #-ovc xvid -xvidencopts pass=1:vhq=1:qpel:trellis \
    #-o pass1.avi
    fi


#Обрезка вроде не надо
#-vf crop=718:422:2:66,scale=640:356,pp=hb/vb/dr -sws 2 \

    if [[ 2 = $PASS || 3 = $PASS ]]
    then
    #cat $PH/$EXT | nice -n $NICE mencoder - -ofps $FPS -aid $RUS -ni \
    
    (
    # -oac copy
    echo Второй проход:
    nice -n $NICE mencoder $PH/$EXT -ofps $FPS \
    $AUDIO_OPTIONS \
    $EXT_OPTIONS -v \
    -noskip \
    -ovc xvid -xvidencopts pass=2:bitrate=$BITRATE:${VIDEO_OPTIONS_2pass} \
    $VIDEO_FILTERS \
    -o $READYPH/${DONE_PREFIX}$EXT \
    $FRAMES $ENDPOS 2>&1) | tee $LOGFILE
    fi
#-vf pp=lb,hqdn3d=2:1:2 \
#-vf pp=lb,delogo=10:10:100:50:100,hqdn3d=2:1:2 \
#XVID
#-ovc lavc -lavcopts vcodec=snow:vstrict=-2:vqscale=3:pred=1:cmp=1:subcmp=1:mbcmp=1:qpel \
#-ovc xvid -xvidencopts bitrate=$BITRATE:pass=2:vhq=1:qpel:trellis \
#-ovc lavc -lavcopts vcodec=xvid:vpass=2:vhq:vbitrate=$BITRATE:vme=5:keyint=300:v4mv:mv0:qpel:trell:cbp:naq \

#Обрезка вроде не надо
#-vf crop=718:422:2:66,scale=640:356,pp=hb/vb/dr -sws 2 \



#mv divx2pass.log $READYPH/"divx2pass-"$EXT".log"