#!/bin/sh
#/etc/rc.common

START=50

# Run every 15 seconds ...
/lib/gluon/config-mode/notify-setup.sh force
((sleep 15 ; /lib/gluon/setup-mode/rc.d/S50ffgt-tell-setup.sh)&)
# Reboot if configured AND in setup mode for more that 3600 seconds (i. e. 1 hour) -- accidental invocation?
configured=$(/sbin/uci get gluon-setup-mode.@setup_mode[0].configured 2>/dev/null)
rc=$?
#if [ ${rc} -eq 0 -a "${configured}" == "1" ]; then
# /usr/bin/awk < /proc/uptime '{if($1 > 3600.0) {printf("/sbin/reboot\n");} else {printf("echo -n\n");}}'| /bin/sh
#fi
