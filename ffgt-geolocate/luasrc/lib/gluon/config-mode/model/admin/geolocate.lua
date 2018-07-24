local uci = require("simple-uci").cursor()
local util = require 'gluon.util'

local f = Form(translate("Geolocation"))

local text = translate(
  'There should be our map in an iframe; feel free to scroll around and use ' ..
  'the location picker to find the desired coordinates.'
)
text = text .. '<p><iframe src="http://map.4830.org/geomap.html" width="100%%" height="700">Karte/Map</iframe></p>'

local s = f:section(Section, nil, text)
local o = s:option(Value, "latitude", pkg_i18n.translate("Latitude"), translatef("e.g. %s", "53.873621"))
o.default = uci:get("gluon-node-info", location, "latitude")
o.datatype = "float"
function o:write(data)
	uci:set("gluon-node-info", location, "latitude", data)
end

o = s:option(Value, "longitude", pkg_i18n.translate("Longitude"), translatef("e.g. %s", "10.689901"))
o.default = uci:get("gluon-node-info", location, "longitude")
o.datatype = "float"
function o:write(data)
	uci:set("gluon-node-info", location, "longitude", data)
end

function f:write()
--	util.foreach_radio(uci, function(radio, index)
--		local radio_name = radio['.name']
--		local name   = "wan_" .. radio_name
--
--		if enabled.data then
--			local macaddr = util.get_wlan_mac(uci, radio, index, 4)
--
--			uci:section('wireless', "wifi-iface", name, {
--				device     = radio_name,
--				network    = "wan",
--				mode       = 'ap',
--				encryption = 'psk2',
--				ssid       = ssid.data,
--				key        = key.data,
--				macaddr    = macaddr,
--				disabled   = false,
--			})
--		else
--			uci:set('wireless', name, "disabled", true)
--		end
--	end)

--	uci:commit('gluon-node-info')
end

return f
