#!/bin/bash

unset T
unset TT
unset TTT

IONICE=3
NICE=17

#T='ssh -C %s "if [[ "$IONICE" && \$( ionice -c$IONICE $IONICE_TEST_CMD; echo \$? ) -gt 0 ]]; then $REMOTE_CMD; else ionice -c$IONICE $REMOTE_CMD; fi"'
#TT='==$T=='
#eval "TTT=\"$T\""

#eval 'TTT="$T"'
#eval "TTT='"$T"'"
#echo $TTT


#Worked example:
TEST=ZAQ
T='test "$TEST" text'
T='ssh -C %s "if [[ "$IONICE" && \$( ionice -c$IONICE $IONICE_TEST_CMD; echo \$? ) -gt 0 ]]; then $REMOTE_CMD; else ionice -c$IONICE $REMOTE_CMD; fi"'

#T=$( echo "$T" | sed 's/\"/\\"/g' )
#echo T=$T
#eval "TT=\"$T\""

eval "TT=\"$( echo "$T" | sed 's/\"/\\"/g' )\""
echo "$TT"