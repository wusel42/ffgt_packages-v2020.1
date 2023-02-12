return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-geo-location'
	local site_i18n = i18n 'gluon-site'

	local site = require 'gluon.site'

	local osm
	pcall(function() osm = require 'gluon.config-mode.geo-location-osm' end)

	local location = uci:get_first("gluon-node-info", "location")

	local show_altitude = site.config_mode.geo_location.show_altitude(false)

	local text = pkg_i18n.translate(
			"No coordinates set; please add them or try the WiFi-based " ..
			"geolocation, which will upload the WiFi networks (SSID, " ..
			"BSSID, strenght, channel) to our server, which in turn will " ..
			"use third party services (Google, OpenStreetMap, ...) to map " ..
			that to a location. We *need* a proper location to assign this " ..
			node to a Freifunk network (\"hood\", \"community\", ...)."
	)
	if osm then
		text = text .. '\n' .. osm.help(i18n)
	end
	if show_altitude then
		text = text .. '\n ' .. pkg_i18n.translate(
			'Specifying the altitude is optional; it should only be filled in if an accurate ' ..
			'value is known.'
		)
	end

	local s = form:section(Section, nil, text)

	local o

	local own_latitude = uci:get("gluon-node-info", location, "latitude")
	local own_longitude = uci:get("gluon-node-info", location, "longitude")

	local share_location = s:option(Flag, "share_location", pkg_i18n.translate("Advertise node position"))
	share_location.default = uci:get_bool("gluon-node-info", location, "share_location")
	function share_location:write(data)
		uci:set("gluon-node-info", location, "share_location", data)
	end

	local map
	if osm then
		map = s:option(osm.MapValue, "map", osm.options())
	end

	o = s:option(Value, "latitude", pkg_i18n.translate("Latitude"), pkg_i18n.translatef("e.g. %s", "53.873621"))
	o.default = own_latitude
	o.datatype = "float"
	function o:write(data)
		uci:set("gluon-node-info", location, "latitude", data)
	end
	if osm then
		map.lat = o
	end

	o = s:option(Value, "longitude", pkg_i18n.translate("Longitude"), pkg_i18n.translatef("e.g. %s", "10.689901"))
	o.default = own_longitude
	o.datatype = "float"
	function o:write(data)
		uci:set("gluon-node-info", location, "longitude", data)
	end
	if osm then
		map.lon = o
	end

	if show_altitude then
		o = s:option(Value, "altitude",
			site_i18n._translate("gluon-config-mode:altitude-label") or pkg_i18n.translate("Altitude"),
			pkg_i18n.translatef("e.g. %s", "11.51")
		)
		o.default = uci:get("gluon-node-info", location, "altitude")
		o.datatype = "float"
		o.optional = true
		function o:write(data)
			uci:set("gluon-node-info", location, "altitude", data)
		end
	end

	function s:write()
		uci:save("gluon-node-info")
	end
end
