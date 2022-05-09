#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage: $0 IP" >/dev/stderr
  exit 0
fi

XML='<?xml version="1.0" encoding="utf-8" ?><s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><u:GetCommonLinkProperties xmlns:u="urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1" /></s:Body></s:Envelope>'
(nc $1 49000 | awk 'BEGIN{wan="";} /AccessType/ {wan=$1; gsub("NewWANAccessType", "", wan); gsub("/", "", wan); gsub("<>", "", wan);} /MaxBitRate>/ {val=substr($0, index($0, ">")+1); val=substr(val, 1, index(val, "<")-1); text=substr($0, 2, index($0, ">")-2); gsub("NewLayer1", "", text); gsub("MaxBitRate", "", text); if(val<1) val=0.1; bw[text]=val;} END{if(length(wan)) printf("%s %.0f/%.0f\n", wan, bw["Downstream"]/1024.0, bw["Upstream"]/1024.0);}' ) <<EOF
POST /igdupnp/control/WANCommonIFC1 HTTP/1.1
Content-Type: text/xml; charset="utf-8"
HOST: $1:49000
Content-Length: ${#XML}
SOAPACTION: "urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1#GetCommonLinkProperties"

${XML}
EOF
