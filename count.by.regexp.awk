#!/usr/bin/awk -f

BEGIN{
	if (ARGC < 2){
		print "\n\
	Script to count occurancies of subpattern by regular expression parenthesis (up to 9).\n\
	1 argument - regexp to match\n\
	All other (1 or more) - files ot process\n\
	F.e. call with arguments: 'on host \\[(.+)\\] failed: first network error, wait for ([[:digit:]]+) seconds' fileName\n\
	on file contains:\n\
	====\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [pskovrg] failed: first network error, wait for 15 seconds\n\
	on host [kurskrg] failed: first network error, wait for 15 seconds\n\
	on host [kurskrg] failed: first network error, wait for 15 seconds\n\
	on host [ntek] failed: first network error, wait for 15 seconds\n\
	on host [yarrg] failed: first network error, wait for 15 seconds\n\
	on host [kemerovorg] failed: first network error, wait for 15 seconds\n\
	on host [kurganrg] failed: first network error, wait for 15 seconds\n\
	on host [ulianovskrg] failed: first network error, wait for 15 seconds\n\
	====\n\
\n\
	will produce next output:\n\
	[1:yarrg][2:15]=1\n\
	[1:kemerovorg][2:15]=10\n\
	[1:kurganrg][2:15]=1\n\
	[1:ntek][2:15]=1\n\
	[1:ulianovskrg][2:15]=1\n\
	[1:kurskrg][2:15]=2\n\
	[1:pskovrg][2:15]=1";

	exit 1;
	}

#print "ARGV[1]=" ARGV[1]
#print "ARGV[2]=" ARGV[2]
regexp=ARGV[1]
# Delete to do not process arguments as file names
delete ARGV[1]
#print "regexp=" regexp
}
{
	delete m
	if ( match($0, regexp, m) ) {
#	print "Matched: " $0;
#	print "Elements (count:" m[0, "length"] "): [0:" m[0] "] [1:" m[1] "] [2:" m[2] "][3:" m[3] "]";
	key="";
	for (i = 1; i<=9; i++){
		if (length(m[i]) != 0){# Not just if (m[i]) because it discard matched "0" value! (http://stackoverflow.com/a/11952924/307525)
#			if (m[i]) print "m["i"]=" m[i];
			key = key "[" i ":" m[i] "]";
		}
	}
	if (res[key]) res[key]++;
	else res[key] = 1;
#		for (e in m){
#			if (length(e) > 0){
#				print "elem: " e
#			}
#		}
	}
}
END{
	for (r in res){
		print r "=" res[r]
	}
}
