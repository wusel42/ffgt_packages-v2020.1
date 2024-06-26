tecff-autoupdater-wifi-fallback
==============================

If a node has no connection to the mesh, neither via wifi nor via
VPN, it is not possible to update this node via `autoupdater`.
The *wifi-fallback* provides a solution. It checks hourly whether the node is part of
a fully operative mesh. Else the node connects to a visible "Freifunknetz"
in client mode and tries to download an update by executing `autoupdater -f`.

This package needs a very basic /usr/sbin/wpa_supplicant at least. This can
be supplied by wpa-supplicant-dummy ...


/etc/config/autoupdater-wifi-fallback
-------------------------------------

**autoupdater-wifi-fallback.settings.enabled:**
- `0` disables the fallback mode
- `1` enables the fallback mode

### example
```
config autoupdater-wifi-fallback 'settings'
	option enabled '1'
```
