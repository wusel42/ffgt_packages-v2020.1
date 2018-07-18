return function(form, uci)
	local pkg_i18n = i18n 'ffgt-geolocate'
	local site_i18n = i18n 'gluon-site'

	local site = require 'gluon.site'

	local location = uci:get_first("gluon-node-info", "location")
    local lat = uci:get_first("gluon-node-info", 'location', "latitude")
    local lon = uci:get_first("gluon-node-info", 'location', "longitude")
    local unlocode = uci:get_first("gluon-node-info", "location", "locode")

	local function show_altitude()
		if site.config_mode.geo_location.show_altitude(true) then
			return true
		end

		return uci:get_bool("gluon-node-info", location, "altitude")
	end

    local text = pkg_i18n.translate(
		'To select which configuration your node should use, we need to know ' ..
		'where it will be located. We will use OpenStreetMap data to convert ' ..
		'the coordinates you enter below to a street address, which in turn ' ..
		'will result in a location code (locode). We strongly beliebe in ' ..
		'server-assisted setup, therefore we kindly request this information ' ..
		'from you and that your node is connected to the Internet during Setup.'
	)

	local s = form:section(Section, nil, text)

	local text = pkg_i18n.translate(
		'If you want the location of your node to ' ..
		'be displayed on the map, please tick the checkbox below.'
	)
	if show_altitude() then
		text = text .. ' ' .. site_i18n.translate("gluon-config-mode:altitude-help")
	end

	local s = form:section(Section, nil, text)

	local o

	local share_location = s:option(Flag, "location", pkg_i18n.translate("Show node on the map"))
	share_location.default = uci:get_bool("gluon-node-info", location, "share_location")
	function share_location:write(data)
		uci:set("gluon-node-info", location, "share_location", data)
	end

    if not lat then lat=0 end
    if not lon then lon=0 end
    if (lat == 0) and (lon == 0) then
        local text = pkg_i18n.translate(
		    'No coordinates set; please add them or try the WiFi-based geolocation, ' ..
    		'which will upload the WiFi networks (SSID, BSSID, strenght, channel) ' ..
	    	'to our server, which in turn will use third party services (Google, ' ..
		    'OpenStreetMap, ...) to map that to a location. We _need_ a proper ' ..
	    	'location to assign this node to a Freifunk network ("hood", "community", ...).'
	)

    	local s = form:section(Section, nil, text)
    elseif (lat == "51") and (lon == "9") then
        local text = pkg_i18n.translate(
		    'Looks like geolocation failed. Please add the coordinates this node ' ..
		    'will be located at below, feel free to utilize our map.'
	)

    	local s = form:section(Section, nil, text)
    elseif not unlocode then
        local text = pkg_i18n.translate(
		    'We could not map the coordinated to a location code. That is odd; ' ..
    		'does this node have Internet connectivity? '
	    )

	    local s = form:section(Section, nil, text)
    else
        local addr = uci:get_first("gluon-node-info", 'location', "addr") or "FEHLER_ADDR"
        local city = uci:get_first("gluon-node-info", 'location', "city") or "FEHLER_ORT"
        local zip = uci:get_first("gluon-node-info", 'location', "zip") or "00000"
        local mystr = string.format("<b>Adresse:</b> %s, %s %s<br></br><b>Koordinaten:</b> %f %f<br></br><b>Community:</b> %s", addr, zip, city, lat, lon, unlocode)
        local text = pkg_i18n.translate(
		    'Located the future position of this node as follows, please verify:<br></br>'
	    )
        text = text .. ' ' .. mystr

	    local s = form:section(Section, nil, text)
    end

    local text = pkg_i18n.translate(
	    'There should be our map in an iframe; feel free to scroll around and use ' ..
	    'the location picker to find the desired coordinates.'

    text = text .. <p><iframe src="http://map.4830.org/geomap.html" width="100%%" height="700">Karte/Map</iframe></p>'

    local s = form:section(Section, nil, text)

    local s = form:section(cbi.SimpleSection, nil, mystr)

	o = s:option(Value, "latitude", pkg_i18n.translate("Latitude"), pkg_i18n.translatef("e.g. %s", "53.873621"))
	o.default = uci:get("gluon-node-info", location, "latitude")
	-- o:depends(share_location, true)
	o.datatype = "float"
	function o:write(data)
		uci:set("gluon-node-info", location, "latitude", data)
	end

	o = s:option(Value, "longitude", pkg_i18n.translate("Longitude"), pkg_i18n.translatef("e.g. %s", "10.689901"))
	o.default = uci:get("gluon-node-info", location, "longitude")
	-- o:depends(share_location, true)
	o.datatype = "float"
	function o:write(data)
		uci:set("gluon-node-info", location, "longitude", data)
	end

	if show_altitude() then
		o = s:option(Value, "altitude", site_i18n.translate("gluon-config-mode:altitude-label"), pkg_i18n.translatef("e.g. %s", "11.51"))
		o.default = uci:get("gluon-node-info", location, "altitude")
		o:depends(share_location, true)
		o.datatype = "float"
		o.optional = true
		function o:write(data)
			uci:set("gluon-node-info", location, "altitude", data)
		end
	end

	return {'gluon-node-info'}
end
