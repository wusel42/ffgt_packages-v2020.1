#!/bin/sh

/lib/gluon/label_mac.sh 2>&1 | grep "get_mac_label: not found" >/dev/null
if [ $? -eq 0 ]; then
  echo -e "#!/bin/sh\n\ntrue\n" >/bin/get_mac_label && chmod +x /bin/get_mac_label
fi