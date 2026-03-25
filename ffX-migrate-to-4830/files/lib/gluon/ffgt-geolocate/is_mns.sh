#!/bin/sh

if [ $# -eq 2 ]; then
 lat="$1"
 lon="$2"
else
 lat=$(uci get gluon-node-info.@location[0].latitude 2>/dev/null || echo "0.00")
 lon=$(uci get gluon-node-info.@location[0].longitude 2>/dev/null || echo "0.00")
fi
targetlocode="zzz"

if [ "$lat" != "0.00" -a "$lon" != "0.00" ]; then
 # "Südwestfalen-Lippe"
 if [ "$(echo "$lat;$lon" | awk 'BEGIN{FS=";";} {if (($1 > 51.480527645 && $1 < 51.776337691) && ($2 > 7.129440308 && $2 < 8.588218689)) {printf("true");}}')" = "true" ]; then
  targetlocode="0sw"
 fi
 # Kierspe
 if [ "$(echo "$lat;$lon" | awk 'BEGIN{FS=";";} {if (($1 > 51.104384245 && $1 < 51.333614775) && ($2 > 7.495422363 && $2 < 7.982940674)) {printf("true");}}')" = "true" ]; then
  targetlocode="kse"
 fi
 # Möhnesee
 if [ "$(echo "$lat;$lon" | awk 'BEGIN{FS=";";} {if (($1 > 51.460210721 && $1 < 51.503613792) && ($2 > 8.038215637 && $2 < 8.210906982)) {printf("true");}}')" = "true" ]; then
  targetlocode="mns"
 fi
 # Worpswede
 if [ "$(echo "$lat;$lon" | awk 'BEGIN{FS=";";} {if (($1 > 53.18546 && $1 < 53.34440) && ($2 > 8.80709 && $2 < 9.03643)) {printf("true");}}')" = "true" ]; then
  targetlocode="bhu"
 fi
 # Lüneburg
 if [ "$(echo "$lat;$lon" | awk 'BEGIN{FS=";";} {if (($1 > 53.18855 && $1 < 53.28964) && ($2 > 10.32758 && $2 < 10.52018)) {printf("true");}}')" = "true" ]; then
  targetlocode="lbg"
 fi
 # Soltau-Stenbeck (Luhe)
 if [ "$(echo "$lat;$lon" | awk 'BEGIN{FS=";";} {if (($1 > 52.96580 && $1 < 53.11773) && ($2 > 9.80264 && $2 < 10.09755)) {printf("true");}}')" = "true" ]; then
  targetlocode="uez"
 fi
fi
echo -n ${targetlocode}
