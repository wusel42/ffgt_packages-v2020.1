#!/bin/sh

if [ -e /tmp/fbwanspeed.txt ]; then
exit 0
fi

wandefaultgw="$(ip -4 route show | awk '/^default/ {ip=$0; gsub(" dev.*$", "", ip); gsub("^default via ", "", ip); printf("%s", ip);}')"
if [ "$wandefaultgw" != "" ]; then
fbwanspeed="$(wget-nossl --post-file=/lib/gluon/ffgt-speedtest/linkspeed.xml --header='Content-Type: text/xml; charset="utf-8"' --header="SOAPAction:urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1#GetCommonLinkProperties" http://$wandefaultgw:49000/igdupnp/control/WANCommonIFC1 -q -O - | awk -f /lib/gluon/ffgt-speedtest/linkspeed.awk)"
fi
if [ "$fbwanspeed" != "" ]; then
echo "$fbwanspeed" >/tmp/fbwanspeed.txt
fi
echo "$(wget-nossl -O /dev/null --report-speed=bits http://193.26.120.99/100M.dat >/tmp/spd 2>&1 ; awk </tmp/spd '/ saved / {mbps=$3; gsub("(", "", mbps); gsub(")", "", mbps); printf("wget 100M: %s MBps", mbps);}')" >>/tmp/fbwanspeed.txt
