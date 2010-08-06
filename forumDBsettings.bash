#!/bin/bash

set -e

function getConfIPB(){
# $1 - PHP File (conf_global.php) with full enought path.
# $2 - index in $INFO array. (Ex: sql_user)

# Fields are: sql_user, sql_host, sql_pass, sql_database

php -r "include_once('$1'); echo \$INFO['$2'];"
}
#getConfIPB $FROM_phpConf sql_user


function getConfVB(){
# $1 - PHP File (conf_global.php) with full enought path.
# $2 - index in $INFO array. (Ex: sql_user)

# Fields are: servername, port, username, password, usepconnect

local opt=$2

	# This was written after getConf[IPB]. So, for compatability provide IPB0names translation
	case $2 in                                                                                                           
		sql_user		) opt='username';;
		sql_host		) opt='servername';;
		sql_pass		) opt='password';;
		sql_database	) php -r "include_once('$1'); echo \$config['Database']['dbname'];"; return 0;;
#		*     ) echo "Выбран недопустимый ключ.";;   # ПО-УМОЛЧАНИЮ
	esac

php -r "include_once('$1'); echo \$config['MasterServer']['$opt'];"
}
#getConfIPBVB $FROM_phpConf sql_user

function getConfXcart(){
# $1 - PHP File (conf_global.php) with full enought path.
# $2 - index in $INFO array. (Ex: sql_user)

# Fields are: servername, port, username, password, usepconnect

local opt=$2

	# This was written after getConf[IPB]. So, for compatability provide IPB0names translation
	case $2 in                                                                                                           
		sql_pass	) opt='sql_password';;
		sql_database	) opt='sql_db';;
#		*     ) echo "Выбран недопустимый ключ.";;   # ПО-УМОЛЧАНИЮ
	esac

php -r "define('XCART_START', 1); error_reporting(E_ALL ^ E_NOTICE ^ E_WARNING); include_once('$1'); echo \$$opt;"
}
#getConfXcart $FROM_phpConf sql_user

#Common use:
# DBType=$DBType
#mysqldump --opt -q -u"$( getConf$DBType $FROM_phpConf sql_user )" -h"$( getConf$DBType $FROM_phpConf sql_host )" -p"$( getConf$DBType $FROM_phpConf sql_pass )" "$( getConf$DBType $FROM_phpConf sql_database )" > amurforumDB.dump.sql