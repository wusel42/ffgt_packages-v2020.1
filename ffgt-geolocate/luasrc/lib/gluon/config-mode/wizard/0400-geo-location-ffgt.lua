return function(form, uci)
	local pkg_i18n = i18n 'ffgt-geolocate'
	local site_i18n = i18n 'gluon-site'

	local site = require 'gluon.site'

	local location = uci:get_first("gluon-node-info", "location")
    local lat = uci:get("gluon-node-info", location, "latitude")
    local lon = uci:get("gluon-node-info", location, "longitude")
    local unlocode = uci:get("gluon-node-info", location, "locode")

	local function show_altitude()
		if site.config_mode.geo_location.show_altitude(true) then
			return true
		end

		return uci:get_bool("gluon-node-info", location, "altitude")
	end

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
	share_location.default = uci:get_bool("gluon-node-info", location, "share_location") or true
	function share_location:write(data)
		uci:set("gluon-node-info", location, "share_location", data)
	end

    if not lat then lat=0 else lat=tonumber(lat) end
    if not lon then lon=0 else lon=tonumber(lon) end
    if ((lat == 0) and (lon == 0)) or ((lat == 51) and (lon == 9)) or (not unlocode) then
        local text = pkg_i18n.translate('LOCATION NOT SET. Please go to %s.')
	    text = string.format(text, '<a href="/cgi-bin/config/admin/geolocate">Geolocate</a>')
	    local s = form:section(Section, nil, text)
    else
        local addr = uci:get("gluon-node-info", location, "addr") or "FEHLER_ADDR"
        local city = uci:get("gluon-node-info", location, "city") or "FEHLER_ORT"
        local zip = uci:get("gluon-node-info", location, "zip") or "00000"
	    local selected_domain = uci:get('gluon', 'core', 'domain')
    	local communityname = string.gsub(util.exec(string.format("/lib/gluon/ffgt-geolocate/get_domain_name.sh %s", selected_domain)),"\n", "")

        local mystr = string.format("<b>Adresse:</b> %s, %s %s<br></br><b>Koordinaten:</b> %f %f<br></br><b>Community:</b> %s", addr, zip, city, lat, lon, communityname)
        local text = pkg_i18n.translate(
		    'Located the future position of this node as follows, please verify:'
	    )
        text = text .. '<div><br></br></div> ' .. mystr
		text = text .. '<div><br></br></div>' .. pkg_i18n.translate('To change, go to Advanced settings/Geolocation.')

	    local s = form:section(Section, nil, text)
    end
	return {'gluon-node-info'}
end
