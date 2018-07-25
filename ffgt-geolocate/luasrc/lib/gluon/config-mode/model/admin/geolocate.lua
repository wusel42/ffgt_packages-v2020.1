local uci = require("simple-uci").cursor()
local util = require 'gluon.util'
local fs = require 'nixio.fs'
local nixio = require 'nixio'

local f = Form(translate("Geolocation"))
  local location = uci:get_first("gluon-node-info", "location")
  local lat = uci:get_first("gluon-node-info", 'location', "latitude")
  local lon = uci:get_first("gluon-node-info", 'location', "longitude")
  local unlocode = uci:get_first("gluon-node-info", "location", "locode")

  if not lat then lat=0 end
  if not lon then lon=0 end
  if (lat == 0) and (lon == 0) then
    local text = translate(
      'No coordinates set; please add them or try the WiFi-based geolocation, ' ..
      'which will upload the WiFi networks (SSID, BSSID, strenght, channel) ' ..
   	  'to our server, which in turn will use third party services (Google, ' ..
      'OpenStreetMap, ...) to map that to a location. We _need_ a proper ' ..
      'location to assign this node to a Freifunk network ("hood", "community", ...).'
	)

    local s = f:section(Section, nil, text)
  elseif (lat == "51") and (lon == "9") then
    local text = translate(
      'Looks like geolocation failed. Please add the coordinates this node ' ..
      'will be located at below, feel free to utilize our map.'
	)

    local s = f:section(Section, nil, text)
  elseif not unlocode then
    local text = translate(
      'We could not map the coordinated to a location code. That is odd; ' ..
      'does this node have Internet connectivity? '
	)

    local s = f:section(Section, nil, text)
  else
    local addr = uci:get_first("gluon-node-info", 'location', "addr") or "FEHLER_ADDR"
    local city = uci:get_first("gluon-node-info", 'location', "city") or "FEHLER_ORT"
    local zip = uci:get_first("gluon-node-info", 'location', "zip") or "00000"
    local mystr = string.format("<b>Adresse:</b> %s, %s %s<br></br><b>Koordinaten:</b> %f %f<br></br><b>Community:</b> %s", addr, zip, city, lat, lon, unlocode)
    local text = translate(
     'Located the future position of this node as follows, please verify:<br></br>'
    )
    text = text .. ' ' .. mystr

    local s = f:section(Section, nil, text)
  end

  local text = translate(
    'There should be our map in an iframe; feel free to scroll around and use ' ..
    'the location picker to find the desired coordinates.'
  )
  local s = f:section(Section, nil, text)

  local try_autolocate = s:option(Flag, "geolocate", translate("Try net-based location"))
  try_autolocate = false
  function try_autolocate:write(data)
	if data then
      os.execute('/lib/gluon/ffgt-geolocate/rgeo.sh')
      renderer.render_layout('admin/geolocate', nil, 'gluon-web-admin')
    end
  end

  text = '<p><iframe src="http://map.4830.org/geomap.html" width="100%%" height="700">Karte/Map</iframe></p>'
  local s = f:section(Section, nil, text)

  local o = s:option(Value, "latitude", translate("Latitude"), translatef("e.g. %s", "53.873621"))
  o.default = uci:get("gluon-node-info", location, "latitude")
  o.datatype = "float"
  function o:write(data)
	uci:set("gluon-node-info", location, "latitude", data)
  end

  o = s:option(Value, "longitude", translate("Longitude"), translatef("e.g. %s", "10.689901"))
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
