#!/bin/sh

if [ $# -ne 1 ]; then
 exit 1
fi
locode="$1"
if [ ! -e /lib/gluon/domains/${locode}.json ]; then
 locode="zzz"
fi

/usr/bin/jsonfilter -e '@.domain_names' </lib/gluon/domains/${locode}.json | /bin/grep "${1}" | /bin/sed -e 's/{ //g' -e 's/ }//g' -e 's/\"//g' -e 's/: /:/g' | cut -d : -f 2
