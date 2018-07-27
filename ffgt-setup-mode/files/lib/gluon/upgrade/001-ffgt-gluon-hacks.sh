#!/bin/sh
# Another big fat ugly hack ...
# Rationale: we don't want to change too much on Gluons core files,
# but we need to replace some for practical reasons. Thus we clone
# the original, stash them in the firmware as -ffgt versions and
# on first boot replace the Gluon ones with their FFGT counterparts.
# Yes, what we would need is some kind of overlay packages that may
# replace existig files during image creation.
#
# Hmm, looks like it's possible to have Gluon apply patches to itself?
# Anyone willing to explain that magic to me? -- wusel, 2018-07-19 FIXME!

START=1

if [ -e /lib/gluon/config-mode/wizard/0400-geo-location-ffgt.lua ]; then
  mv /lib/gluon/config-mode/wizard/0400-geo-location-ffgt.lua /lib/gluon/config-mode/wizard/0400-geo-location.lua
fi

if [ -e /lib/gluon/config-mode/wizard/0200-domain-select-ffgt.lua ]; then
  mv /lib/gluon/config-mode/wizard/0200-domain-select-ffgt.lua /lib/gluon/config-mode/wizard/0200-domain-select.lua
fi

if [ -e /etc/crontabs/root ]; then
  mv /etc/crontabs /etc/crontabs_notused
fi

if [ -e /lib/gluon/config-mode/controller/admin/privatewifi-ffgt.lua ]; then
  mv /lib/gluon/config-mode/controller/admin/privatewifi-ffgt.lua /lib/gluon/config-mode/controller/admin/privatewifi.lua
fi

if [ -e /lib/gluon/config-mode/wizard/0100-hostname-ffgt.lua ]; then
  mv /lib/gluon/config-mode/wizard/0100-hostname-ffgt.lua /lib/gluon/config-mode/wizard/0100-hostname.lua
fi

if [ -e /lib/gluon/config-mode/controller/admin/wifi-config-ffgt.lua ]; then
  mv /lib/gluon/config-mode/controller/admin/wifi-config-ffgt.lua /lib/gluon/config-mode/controller/admin/wifi-config.lua
fi