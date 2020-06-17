#!/bin/sh
# This script is supposed to be run every hour via micron.d.
#
# FIXME: do not uci commit all the time! That would kill the FLASH rather soonish :(
#
# Try to fetch config data from setup server (supposed to be used for fixups).

UPSECS=$(cut -d ' ' -f 1 /proc/uptime)
UPSECS=$(printf %.0f $UPSECS)
if [ $UPSECS -lt 300 ]; then exit 0 ; fi

runnow=1
isconfigured="`/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null`"
if [ "$isconfigured" != "1" ]; then
 isconfigured=0
fi

if [ -e /tmp/run/gotcfg ]; then
 runnow=0
fi

if [ $# -eq 1 ]; then
  forcerun=1
  runnow=1
else
  forcerun=0
fi

GWL=$(batctl gwl | grep MBit | wc -l)

#if [ $GWL -eq 0 ]; then
#  runnow=0
#fi

if [ ${runnow} -eq 0 ]; then
 exit 0
fi

# We're now supposed to run ...
LASTOCTET=$(cut -d : -f6 /lib/gluon/core/sysconfig/primary_mac)
DELAYSECS=$(printf %d 0x${LASTOCTET})
# ... but delay hammering the server pseudo-randomly
sleep ${DELAYSECS}

mac=`/sbin/uci get network.bat0.macaddr`
curlat="`/sbin/uci get gluon-node-info.@location[0].latitude 2>/dev/null`"
curlon="`/sbin/uci get gluon-node-info.@location[0].longitude 2>/dev/null`"
if [ "X${curlat}" = "X" ]; then curlat="0"; fi
if [ "X${curlon}" = "X" ]; then curlon="0"; fi
/bin/wget -q -O /tmp/getcfg.out "http://setup.ipv6.4830.org/getcfg.php?node=${mac}&lat=${curlat}&lon=${curlon}"
if [ -e /tmp/getcfg.out ]; then
  grep "CFG: ok" /tmp/getcfg.out >/dev/null
  if [ $? -eq 0 ]; then
    #
    touch /tmp/run/gotcfg
  fi
fi
