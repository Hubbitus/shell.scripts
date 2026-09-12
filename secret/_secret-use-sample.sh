#!/usr/bin/bash

set -x

#secret-set QAZ3 value1
pass ls Hubbitus/@projects/neinache/dev/
#pass show Hubbitus/@projects/neinache/dev/QAZ3
#secret-get QAZ3

secret-bash-export QAZ QAZ3

source <(secret-bash-export QAZ QAZ3)
echo QAZ=$QAZ