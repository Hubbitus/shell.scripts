#!/bin/bash

ROWS=$( stty size | cut -d' ' -f1 )
COLUMNS=$( stty size | cut -d' ' -f2 )
LINES=$COLUMNS	#just alias