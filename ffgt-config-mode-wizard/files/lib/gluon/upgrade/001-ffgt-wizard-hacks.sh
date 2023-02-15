#!/bin/sh
# Another big fat ugly hack ...
# But as we don't want to completely rework the Wizardry, we neet to patch our
# Firmware once after upgrade.

START=1

logger "$0: started"

# HACK, FIXME; if /bin/wget does not exists, create a symlink from /usr/bin/wget
if [ ! -e /bin/wget ]; then test -e /usr/bin/wget && ln -s /usr/bin/wget /bin/wget ; fi

if [ -e /lib/gluon/config-mode/model/gluon-config-mode/wizard-ffgt.lua ]; then
  mv /lib//gluon/config-mode/model/gluon-config-mode/wizard-ffgt.lua /lib/gluon/config-mode/model/gluon-config-mode/wizard.lua
fi

if [ -e /lib/gluon/config-mode/wizard-ffgt ]; then
  mv /lib/gluon/config-mode/wizard /lib/gluon/config-mode/wizard-legacy
  sync
  mv /lib/gluon/config-mode/wizard-ffgt /lib/gluon/config-mode/wizard
  for i in 0050-autoupdater-info.lua 0250-outdoor.lua 0300-mesh-vpn.lua
  do
    if [ -e /rom/lib/gluon/config-mode/wizard/$i ]; then
      cp -p /rom/lib/gluon/config-mode/wizard/$i /lib/gluon/config-mode/wizard/
    fi
  done
  for i in 0100-hostname.lua 0400-geo-location.lua 0500-contact-info.lua
  do
    if [ -e /lib/gluon/config-mode/wizard/$i ]; then
      /bin/rm /lib/gluon/config-mode/wizard/$i
    fi
  done
fi

if [ -e /lib/gluon/config-mode/reboot-ffgt ]; then
  mv /lib/gluon/config-mode/reboot /lib/gluon/config-mode/reboot-legacy
  mv /lib/gluon/config-mode/reboot-ffgt /lib/gluon/config-mode/reboot
fi

logger "$0: done"
