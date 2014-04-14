#!/bin/bash

# For such long hack see http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=415451
echo -e "sleep 1\nstr $(date +'%H')\nkeydown Shift_L\nkey colon\nkeyup Shift_L\nsleep 0.2\nstr $(date +'%M')\nkeydown Shift_L\nkey colon\nkeyup Shift_L\nstr $(date +'%S')" | xte
