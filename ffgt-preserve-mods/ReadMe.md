ffgt-preserve-mods
==================

Provide a framework to automatically re-do changes to
e. g. the network setup of a Gluon node (like moving
the LAN ports to the br-wan instead of br-client).

/lib/gluon/ffgt-preserve-mods.sh
--------------------------------

If existing and executable, it will be executed after
*every* firmware upgrade. You MUST ensure that this
skript will not cause errors nor behaves badly if run
multiple times.

This file is saved across firmware upgrades. Please keep
it tiny!

Example:

root@33332-4830-776a:~# echo -e "#!/bin/sh\ndate >/tmp/bootdate\nexit 0" >>/lib/gluon/ffgt-preserve-mods.sh
root@33332-4830-776a:~# chmod +x /lib/gluon/ffgt-preserve-mods.sh
