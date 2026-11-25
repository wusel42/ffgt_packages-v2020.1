#!/bin/sh
# This script is supposed to be run (once) from lua
IW="/usr/sbin/iw"
if [ ! -e $IW ]; then
 echo >/tmp/fake_iw -e "#!/bin/sh\ncat /dev/null"
 chmod +x /tmp/fake_iw
 IW="/tmp/fake_iw"
fi
export IW

WLANDEV="$(${IW} dev | /usr/bin/awk 'BEGIN{idx=1;} /Interface client/ {iface[idx]=$2; ifacemap[$2]=idx; idx++};  /Interface wlan/ {iface[idx]=$2; ifacemap[$2]=idx; idx++}; END{for(i=1; i<idx; i++) {printf("%s ", iface[i]);}}')"
if [ "X${WLANDEV}" = "X" ]; then
 echo "$0: no WiFi device detected"
 logger "$0: no WiFi device detected"
 exit 0
fi

runnow=0
force=0
respawn=0

isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null`"
if [ "$isconfigured" != "1" ]; then
 isconfigured=0
fi

if [ ! -e /tmp/run/geolocate-data-sent ]; then
 runnow=1
fi

if [ $# -eq 1 ]; then
  if [ "$1" = "force" ]; then
    runnow=1
    force=1
    if [ -e /tmp/run/geolocate-data-sent ]; then
      rm /tmp/run/geolocate-data-sent
    fi
  fi
fi

if [ ${runnow} -eq 1 ]; then
 IPVXPREFIX="`/lib/gluon/ffgt-geolocate/ipv5.sh`"
 if [ "Y$IPVXPREFIX" == "Y" -o "$IPVXPREFIX" == "ipv5." ]; then
  logger "$0: IPv5 not implemented, respawning in 150 seconds."
  ((sleep 150 ; /lib/gluon/ffgt-geolocate/geolocate-lite.sh force)&)
  exit 1
 fi

 mac=`/sbin/uci get network.bat0.macaddr`
 for dev in ${WLANDEV}
 do
  ${IW} dev ${dev} scan >/dev/null 2>&1
  if [ $? -ne 0 ]; then
   /sbin/ifconfig ${dev} up
   sleep 2
  fi
 done
 wget -q -O /dev/null "$( (for dev in ${WLANDEV}; do ${IW} ${dev} scan; done) | /usr/bin/awk -v mac=$mac -v ipv4prefix=$IPVXPREFIX -f /lib/gluon/ffgt-geolocate/preparse.awk)" && /bin/touch /tmp/run/geolocate-data-sent
 # On success only ...
 if [ -e /tmp/run/geolocate-data-sent ]; then
  if [ ${force} -eq 1 ]; then
    curlat=""
  else
    curlat="$(/sbin/uci get gluon-node-info.@location[0].longitude 2>/dev/null)"
  fi
  if [ "X${curlat}" = "X" ]; then
   sleep 5
   wget -q -O /tmp/geoloc.out "http://setup.${IPVXPREFIX}4830.org/geoloc.php?list=me&node=$mac"
   if [ -e /tmp/geoloc.out ]; then
    haslocation="$(/sbin/uci get gluon-node-info.@location[0] 2>/dev/null)"
    if [ "${haslocation}" != "location" ]; then
     /sbin/uci add gluon-node-info location ||:
    fi
    while read -r key value; do
     case "$key" in
      LAT:) field=latitude;;
      LON:) field=longitude;;
      ADR:) field=addr;;
      CTY:) field=city;;
      ZIP:) field=zip;;
      LOC:) field=migration_locode;;
      *) continue;;
     esac
     if [ "${field}" = "latitude" ]; then
       if [ "${value}" = "51.916478" ]; then
         value="0.000"
         respawn=1
       fi
     fi
     if [ "${field}" = "longitude" ]; then
       if [ "${value}" = "8.310817" ]; then
         value="0.000"
         respawn=1
       fi
     fi
     if [ "${value}" != "0.000" ]; then
       uci set gluon-node-info.@location[0].${field}="${value}" ||:
     else
       uci delete gluon-node-info.@location[0].${field} ||:
     fi
    done </tmp/geoloc.out
    uci commit gluon-node-info
    if [ ${respawn} -eq 1 ]; then
      logger "$0: Geolocation failed, respawning in 150 seconds."
      ((sleep 150 ; /lib/gluon/ffgt-geolocate/geolocate-lite.sh force)&)
    fi
   fi
  fi
 fi
fi
