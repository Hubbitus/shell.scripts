#!/bin/bash

: ${1?"You must provide argument: `basename $0` command [optional parammeters]"}

${WHILE_CMD_PRE_EXECUTE:-:}

	# Infinity try exec command untill success
	while ! $@; do
		date ${WHILE_CMD_DATE_FORMAT:---rfc-3339=seconds}
		sleep ${WHILE_CMD_TRY_INTERVAL_SECONDS:-2}
	done

${WHILE_CMD_AFTER_EXECUTE:-:}