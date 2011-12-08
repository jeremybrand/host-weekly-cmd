#!/bin/bash --

# Include /bin:/usr/bin for standard tools this script needs and 
# enherit user PATH for everything else afterwards.
PATH=/bin:/usr/bin:$PATH

# 2011, Jeremy Brand
# https://github.com/jeremybrand/host-weekly-cmd

# TODO. no-op and display day of week that this host translates to for informational purposes.
# TODO. usage().

set +e

HNAME=`hostname`
TODAY_DIGIT=`date +%w`

h=`echo $HNAME | cut -d '.' -f 1 | sed -r -e 's/[^0-9]//g'`

if [ "$h" = "" ]; then
	# no number
	nums=""
	if [ "$nums" = "" ]; then
		out=`host $HNAME`
		if [ "$?" = "0" ]; then
			nums=`echo $out | grep -v NXDOMAIN | grep $HNAME | sed -r -e 's/[^0-9]//g'`
		fi
	fi
	if [ "$nums" = "" ]; then
		nums=`echo $HNAME | openssl md5 | sed -r -e 's/[^0-9]//g'`
	fi
	if [ "$nums" = "" ]; then
		nums=`hostid | sed -r -e 's/[^0-9]//g'`
	fi
	if [ "$nums" = "" ]; then
		# Amazing none of the above did not match. Don't give up. Let's just assign this to
		# Thursday instead.
		nums=4
	fi
	
	
else
	# it's got a number, do something
	true
	nums=$h
	
fi

host_mod=`echo "$nums % 7" | bc`

# echo host_mod: $host_mod
# echo TODAY_DIGIT: $TODAY_DIGIT

if [ $host_mod -ge 0 ] && [ $host_mod -le 6 ]; then
	true # noop
else	
	echo "weekly mod is not valid. exiting." 1>&2
	exit 1
fi

if [ $TODAY_DIGIT -ge 0 ] && [ $TODAY_DIGIT -le 6 ]; then
	true # noop
else	
	echo "date command did not return day of week. invalid. exiting." 1>&2
	exit 1
fi

if [ "$*" = "" ]; then
	echo "no command given on command line. Exit error." 1>&2
	exit 1
fi

if [ "$host_mod" = "$TODAY_DIGIT" ]; then
	# Do the command
	echo running the command
	exec $*
else
	exit 0
fi

# because we got this far, it must be an error.
exit 1


