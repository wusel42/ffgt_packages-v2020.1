#!/bin/sh
#/etc/rc.common

exit 0

START=99

if [ -x /tmp/ffbi-migration.sh ]; then
  mv /tmp/ffbi-migration.sh /tmp/ffbi-migration-running.sh
  echo "uci set gluon-setup-mode.@setup_mode[0].configured='1' ||:"     >>/tmp/ffbi-migration-running.sh
  echo "uci set gluon-setup-mode.@setup_mode[0].enabled='0' ||:"        >>/tmp/ffbi-migration-running.sh
  echo "uci commit gluon-setup-mode ||:"                                >>/tmp/ffbi-migration-running.sh

  echo "$0: Running /tmp/ffbi-migration-running.sh 10 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  ((sleep 10 ; date ; /bin/sh -x /tmp/ffbi-migration-running.sh 2&>1 | tee -a /root/ffbi-migration.log)&) ||:
  cp -p /tmp/ffbi-migration-running.sh /root/ ||:

  echo "$0: Running rgeo.sh 20 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  ((sleep 20 ; date ; /lib/gluon/ffgt-geolocate/rgeo.sh 2>&1 | tee -a /root/ffbi-migration.log)&)

  echo "$0: Running gluon-reconfigure 30 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  ((sleep 30 ; date ; gluon-reconfigure 2>&1 | tee -a /root/ffbi-migration.log)&)

  echo "$0: Rebooting 45 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  sync
  ((sleep 45 ; /sbin/reboot)&)
fi
