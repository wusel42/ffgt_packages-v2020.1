#!/bin/sh
# FIXME, add proper patch into build instead of patching the image ...

START=1

logger "$0: started"

if [ -e /etc/init.d/tunneldigger.init ]; then
  mv /etc/init.d/tunneldigger.init /etc/init.d/tunneldigger ||:
fi

logger "$0: done"
