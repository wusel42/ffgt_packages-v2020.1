#!/bin/sh
#/etc/rc.common

START=99

if [ -x /tmp/ffbi-migration.sh ]; then
  echo "Running /tmp/ffbi-migration.sh at $(date) ..." | tee -a /root/ffbi-migration.log
  mv /tmp/ffbi-migration.sh /tmp/ffbi-migration-running.sh
  ((sleep 15 ; /tmp/ffbi-migration-running.sh)&) ||:
fi