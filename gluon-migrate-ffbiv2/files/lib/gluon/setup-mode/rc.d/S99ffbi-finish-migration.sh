#!/bin/sh
#/etc/rc.common

START=99

if [ -e /var/gluon/setup-mode ]; then
  SETUP_MODE=1
else
  SETUP_MODE=0
fi

echo "$0: SETUP_MODE is ${SETUP_MODE} at $(date)" | tee -a /root/fw-test.log
echo "$0: Internet access: $(/lib/gluon/ffgt-geolocate/ipv5.sh | sed -e s/ipv5/none/)" | tee -a /root/fw-test.log

if [ -e /etc/config/freifunk ]; then
  # Get former firmware's settings
  domain=$(uci get freifunk.@settings[0].community | sed -e s/badoeynhausen/boy/ -e s/bielefeld/bfe/ -e s/minden/mid/)
  lat="$(uci get freifunk.@settings[0].latitude 2>/dev/null || echo 0)"
  lon="$(uci get freifunk.@settings[0].longitude 2>/dev/null || echo 0)"
  contact="$(uci get freifunk.@settings[0].contact 2>/dev/null)"
  name="$(uci get freifunk.@settings[0].name 2>/dev/null)"
  showonmap="$(uci get freifunk.@settings[0].publish_map)"

  echo "$0: Data gathered: domain=${domain} lat=${lat} lon=${lon} contact=${contact} name=${name} showonmap=${showonmap}" | tee -a /root/ffbi-migration.log

  # Now work on the values rescued, builing a commandfile to auto-configure this node accordingly.
  if [ ! -e /lib/gluon/domains/${domain}.json ]; then
   echo "No match for mesh ${domain} in /lib/gluon/domains/, setting do default (zzz)." | tee -a /root/ffbi-migration.log
   domain=zzz
  fi
  echo "Selected mesh: ${domain}." | tee -a /root/ffbi-migration.log

  # Convert into Gluon setting
  echo "Setting mesh domain: ${domain}." | tee -a /root/ffbi-migration.log
  echo "uci set gluon.core.domain=\"${domain}\" ||:"                   >>/tmp/ffbi-migration.sh
  echo "uci set gluon.core.migrated_from=ffbi ||:"                     >>/tmp/ffbi-migration.sh

  mac="$(echo -e "local util = require 'gluon.util'\nlocal mac=string.sub(util.node_id(), 9);\nprint(mac);" | /usr/bin/lua)"
  if [ "${mac}X" = "X" ]; then
    mac="no-mac"
  fi

  if [ "${name}X" = "X" ]; then
    name="migrated-$(/bin/cat /tmp/sysinfo/board_name)-${mac}"
  fi
  name="$(echo ${name} | sed -e 's/ /-/g' -e 's/_/-/g' -e 's/ä/ae/g' -e 's/ö/oe/g' -e 's/ü/ue/g' -e 's/ß/sz/g' -e 's/Ä/Ae/g' -e 's/Ö/Oe/g' -e 's/Ü/Ue/g')"

  if [ "X${contact}" != "X" ]; then
    echo "uci set gluon-node-info.@owner[0].contact=\"$contact\" ||:"  >>/tmp/ffbi-migration.sh
  fi

  echo "uci set gluon-node-info.@location[0].latitude=\"$lat\" ||:"    >>/tmp/ffbi-migration.sh
  echo "uci set gluon-node-info.@location[0].longitude=\"$lon\" ||:"   >>/tmp/ffbi-migration.sh

  if [ "${showonmap}" = "none" ]; then
    echo "uci set gluon-node-info.@location[0].share_location='0' ||:" >>/tmp/ffbi-migration.sh
  else
    echo "uci set gluon-node-info.@location[0].share_location='1' ||:" >>/tmp/ffbi-migration.sh
  fi

  echo "uci set system.@system[0].hostname=\"$name\" ||:"              >>/tmp/ffbi-migration.sh

  #echo "uci set gluon-setup-mode.@setup_mode[0].configured='1' ||:"    >>/tmp/ffbi-migration.sh
  #echo "uci set gluon-setup-mode.@setup_mode[0].enabled='0' ||:"       >>/tmp/ffbi-migration.sh
  echo "uci commit gluon-setup-mode ||:"                               >>/tmp/ffbi-migration.sh
  echo "uci commit gluon-node-info ||:"                                >>/tmp/ffbi-migration.sh
  echo "uci commit system ||:"                                         >>/tmp/ffbi-migration.sh
  echo "uci commit ||:"                                                >>/tmp/ffbi-migration.sh
  echo "mv /tmp/ffbi-migration.sh /root/ ||:"                          >>/tmp/ffbi-migration.sh

  echo "echo \"\$0: Done migrating FFBI-FW to 4830.org's Gluon at $(date)\" | tee -a /root/ffbi-migration.log" >>/tmp/ffbi-migration.sh

  echo "$0: Running /tmp/ffbi-migration.sh 30 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  ((sleep 30 ; (date ; /bin/sh -x /tmp/ffbi-migration.sh 2>&1) | tee -a /root/ffbi-migration.log)&) ||:

  echo "$0: Running gluon-reconfigure 40 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  ((sleep 40 ; (date ; gluon-reconfigure 2>&1) | tee -a /root/ffbi-migration.log)&)

  echo "$0: Running rgeo.sh 50 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  ((sleep 50 ; (date ; /lib/gluon/ffgt-geolocate/rgeo.sh 2>&1) | tee -a /root/ffbi-migration.log)&)

  echo "$0: Setting gluon-setup-mode to configured in 72 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  ((sleep 72 ; (date ; uci set gluon-setup-mode.@setup_mode[0].configured='1' ||: ; uci set gluon-setup-mode.@setup_mode[0].enabled='0' ||: ; uci commit gluon-setup-mode ||:) 2&>1 tee -a /root/ffbi-migration.log)&)

  echo "$0: Rebooting 75 secs after $(date) ..." | tee -a /root/ffbi-migration.log
  sync
  ((sleep 75 ; sync; sync; sync; sleep 1 ; /sbin/reboot)&)
fi












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
