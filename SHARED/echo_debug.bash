#!/bin/bash

#D ECHO_DEBUG=true
ECHO_DEBUG_file=${ECHO_DEBUG_file:-/dev/stdout}

function echo_debug(){
	[ "$ECHO_DEBUG" ] && echo "$@" >> "$ECHO_DEBUG_file"
}
