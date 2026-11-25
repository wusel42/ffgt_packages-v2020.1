#!/bin/sh
# Gluon migration helper. stdout is reserved for successfully committed results.
# No argument: send one scan per boot and fill in missing/invalid coordinates.
# force: request a fresh fix even if a valid location already exists.
# --check: exit 0 if the stored coordinates are valid; no side effects.

export LC_ALL=C
umask 077
location='gluon-node-info.@location[0]'
state=/tmp/run
sent=$state/geolocate-data-sent
iw=/usr/sbin/iw
scheme=${GEOLOCATE_SCHEME:-http}
max_attempts=3
retry_delay=150

log() { logger -t geolocate-lite "$*" >&2; }
fail() { log "$*"; exit 1; }

# Parse a whole reply before emitting any fields. Preserve the decimal spelling
# for UCI, but compare the sentinel values as numbers. Missing optional fields
# are left alone; an explicitly empty optional field clears that option.
parse_location() {
	awk '
		BEGIN {
			n = split("LAT: LON: ADR: CTY: ZIP: LOC:", keys)
			split("latitude longitude addr city zip migration_locode", names)
			for (i = 1; i <= n; i++) known[keys[i]] = 1
			decimal = "^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$"
		}
		{
			sub(/\r$/, "")
			key = $1
			if (!(key in known)) next
			if (seen[key]++) bad = 1
			sub(/^[ \t]*[^ \t]+[ \t]*/, "")
			sub(/[ \t]+$/, "")
			value[key] = $0
		}
		END {
			lat = value["LAT:"]; lon = value["LON:"]
			if (bad || lat !~ decimal || lon !~ decimal) exit 1
			a = lat + 0; b = lon + 0
			if (a < -90 || a > 90 || b < -180 || b > 180 ||
			    (a == 0 && b == 0) || (a == 51.916478 && b == 8.310817)) exit 1
			for (i = 1; i <= n; i++)
				if (seen[keys[i]]) print names[i], value[keys[i]]
		}'
}

stored_location_ok() {
	local lat lon
	lat=$(uci -q get "$location.latitude") && lon=$(uci -q get "$location.longitude") || return 1
	printf 'LAT: %s\nLON: %s\n' "$lat" "$lon" | parse_location >/dev/null
}

case "$#:${1-}" in
	0:) force=0 ;;
	1:force) force=1 ;;
	1:--check) stored_location_ok; exit $? ;;
	*) echo "Usage: $0 [force|--check]" >&2; exit 2 ;;
esac
case "$scheme" in http|https) ;; *) fail "Invalid GEOLOCATE_SCHEME: $scheme" ;; esac
[ -x "$iw" ] || { log "No iw installed, skipping WiFi geolocation"; exit 0; }
mkdir -p "$state" || exit 1
exec 9>"$state/geolocate-lite.lock" || exit 1
flock -n 9 || fail "Could not acquire the geolocation lock"
if [ "$force" = 0 ] && [ -f "$sent" ] && stored_location_ok; then exit 0; fi

work=$(mktemp -d "$state/geolocate-lite.XXXXXX") || exit 1
raised=
restore_interface() {
	[ -n "$raised" ] || return 0
	ip link set dev "$raised" down || return 1
	raised=
}
cleanup() {
	restore_interface || log "Could not restore WiFi interface $raised"
	rm -rf "$work"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

scan_wifi() {
	local dev devices flags
	"$iw" dev >"$work/devices" || return 1
	devices=$(awk '$1 == "Interface" && $2 ~ /^(client|wlan)/ {print $2}' "$work/devices") || return 1
	[ -n "$devices" ] || { log "No client/wlan interface, skipping WiFi geolocation"; exit 0; }
	: >"$work/scans" || return 1
	for dev in $devices; do
		# IFF_UP is bit zero. Never lower an interface that was already up.
		flags=$(cat "/sys/class/net/$dev/flags") || continue
		if [ $((flags & 1)) -eq 0 ]; then
			raised=$dev
			ip link set dev "$dev" up || { raised=; continue; }
			sleep 2
		fi
		if "$iw" dev "$dev" scan >"$work/one-scan" 2>/dev/null; then
			cat "$work/one-scan" >>"$work/scans" || fail "Cannot store WiFi scan"
		fi
		restore_interface || fail "Cannot restore $dev"
	done
}

# Write the existing geoloc.php query format. Ignore incomplete scans and cap
# the payload at 30 access points, as in ffgt-geolocate/preparse.awk.
wifi_query() {
	awk '
		BEGIN { for (i = 1; i <= 255; i++) ord[sprintf("%c", i)] = i }
		function escape(s,    i,c,out) {
			for (i = 1; i <= length(s); i++) {
				c = substr(s, i, 1)
				if (c ~ /^[a-zA-Z0-9]$/) out = out c
				else out = out sprintf("%%%02X", ord[c])
			}
			return out
		}
		function emit() {
			if (bssid == "" || count >= 30) return
			printf "&wifi[]=mac:%s%%7Cssid:%s%%7Css:%s%%7Cchan:%s", bssid, escape(ssid), signal, channel
			if (offset != "") printf ",%s", offset
			count++
		}
		/^BSS[ \t]/ {
			emit()
			bssid = $2; sub(/\(.*/, "", bssid)
			if (split(bssid, octet, ":") != 6) bssid = ""
			for (i = 1; i <= 6; i++)
				if (octet[i] !~ /^[[:xdigit:]][[:xdigit:]]$/) bssid = ""
			gsub(/:/, "-", bssid)
			ssid = signal = channel = offset = ""
			next
		}
		/^[ \t]*SSID:/ { sub(/^[ \t]*SSID: ?/, ""); ssid = $0; next }
		$1 == "signal:" && $2 ~ /^-?[0-9]+([.][0-9]+)?$/ { signal = $2 }
		/DS Parameter set: channel|primary channel:/ { if ($NF ~ /^[0-9]+$/) channel = $NF }
		/secondary channel offset:/ {
			if ($NF == "secondary") offset = "none"
			else if ($NF == "above" || $NF == "below") offset = $NF
		}
		END { emit(); if (!count) exit 1 }
	' "$work/scans"
}

upload_scan() {
	local query family endpoint
	scan_wifi || return 1
	query=$(wifi_query) || { log "Scan contained no access points"; return 1; }
	for family in ipv4 ipv6; do
		endpoint="$scheme://setup.$family.4830.org/geoloc.php"
		if wget -q -T 20 -O /dev/null "$endpoint?node=$mac$query"; then
			server=$endpoint
			touch "$sent" || fail "Cannot record successful scan upload"
			sleep 5
			return 0
		fi
	done
	log "Scan upload failed on IPv4 and IPv6"
	return 1
}

# -P isolates our staged writes. Older OpenWrt UCI treats a commit with -P
# as a no-op; commit once using -p to read the completed private delta.
stage() { uci -P "$work/delta" "$@"; }
save_location() {
	local field value pending
	mkdir "$work/delta" || return 1
	if ! stage -q get "$location" >/dev/null; then
		stage add gluon-node-info location >/dev/null || return 1
	fi
	while read -r field value; do
		if [ -n "$value" ]; then
			stage set "$location.$field=$value" || return 1
		elif stage -q get "$location.$field" >/dev/null; then
			stage delete "$location.$field" || return 1
		fi
	done <"$work/fields"
	# A commit also sees the default delta directory. Leave pending edits alone.
	pending=$(uci changes gluon-node-info) || return 1
	[ -z "$pending" ] || { log "Pending UCI edits to gluon-node-info"; return 1; }
	uci -p "$work/delta" commit gluon-node-info
}

locate() {
	if [ -z "$server" ]; then upload_scan || return 1; fi
	if [ "$force" = 0 ] && stored_location_ok; then return 0; fi
	if ! wget -q -T 20 -O "$work/reply" "$server?list=me&node=$mac"; then
		log "Result download failed"
		return 1
	fi
	if ! parse_location <"$work/reply" >"$work/fields"; then
		log "Incomplete, invalid or placeholder coordinates"
		server=  # A fresh scan may produce a better fix.
		return 1
	fi
	# A user may have supplied coordinates while a scan or retry was pending.
	if [ "$force" = 0 ] && stored_location_ok; then return 0; fi
	save_location || fail "Could not commit location; discarding private UCI changes"
	cat "$work/fields" || log "Location committed; could not write the result to stdout"
	return 0
}

server=
attempt=1
while [ "$attempt" -le "$max_attempts" ]; do
	mac=$(uci -q get network.bat0.macaddr) || mac=
	if printf '%s\n' "$mac" | grep -Eq '^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$'; then
		locate && exit 0
	else
		log "No valid MAC address in network.bat0.macaddr"
	fi
	[ "$attempt" -lt "$max_attempts" ] || break
	log "Attempt $attempt failed; retrying in $retry_delay seconds"
	sleep "$retry_delay"
	attempt=$((attempt + 1))
done
fail "Geolocation failed after $max_attempts attempts"
