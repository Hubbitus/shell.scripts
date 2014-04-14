#!/bin/bash

: ${1?"You must provide cmd-argument: `basename $0` command"}

COOKIE_FILE='.cookie.file'

# Base server URL, without admin and files parts
#URL='http://192.168.100.199:8161'
#URL='http://192.168.100.148:8161'
#URL='http://192.168.100.153:8161'
#URL='http://192.168.100.147:8161'
#URL=${3:-'http://192.168.100.157:8161'}
#URL=${3:-'http://192.168.100.151:8161'}
#URL=${3:-'http://192.168.100.148:8161'}
URL=${3:-'http://192.168.100.147:8161'}

SECRET=$( curl -sS "${URL}/admin/send.jsp" -c "$COOKIE_FILE" | grep -oP '(?<=<input type="hidden" name="secret" value=")[^"]+(?=")'  )
#'

#curl -sS -b "$COOKIE_FILE" --data "JMSDestination=AIS.CMDCONF.IN&JMSDestinationType=queue&JMSMessageCount=1&JMSMessageCountHeader=JMSXMessageCounter&secret=$SECRET" --data "JMSCorrelationID=&JMSPriority=&JMSReplyTo=&JMSTimeToLive=&JMSType=&JMSXGroupID=&JMSXGroupSeq=" --data-urlencode "JMSText=$1" "${URL}/admin/sendMessage.action"

curl -sS -b "$COOKIE_FILE" --data "JMSDestination=${2:-AIS.CMDCONF.IN}&JMSDestinationType=queue&JMSMessageCount=1&JMSMessageCountHeader=JMSXMessageCounter&secret=$SECRET" --data-urlencode "JMSText=$1" "${URL}/admin/sendMessage.action"
rm "$COOKIE_FILE"