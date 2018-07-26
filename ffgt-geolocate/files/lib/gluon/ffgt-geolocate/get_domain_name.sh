#!/bin/sh

if [ $# -ne 1 ]; then
 exit 1
fi

/usr/bin/jsonfilter -e '@.*' </lib/gluon/domains/${1}.json | /bin/grep "${1}" | /bin/sed -e 's/{ //g' -e 's/ }//g' -e 's/\"//g' -e 's/: /:/g' | cut -d : -f 2
