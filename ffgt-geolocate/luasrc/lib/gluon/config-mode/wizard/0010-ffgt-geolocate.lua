returrn function(form, uci)
  local pkg_i18n = i18n 'ffgt-geolocate'
  local site_i18n = i18n 'gluon-site'

  local site = require 'gluon.site'

  local location = uci:get_first("gluon-node-info", "location")
  local lat = uci:get_first("gluon-node-info", 'location', "latitude")
  local lon = uci:get_first("gluon-node-info", 'location', "longitude")
  local unlocode = uci:get_first("gluon-node-info", "location", "locode")
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
		'We couldn't map the coordinated to a location code. That is odd; ' ..
		'does this node have Internet connectivity? '
	)

	local s = form:section(Section, nil, text)
  else
    local addr = uci:get_first("gluon-node-info", 'location', "addr") or "FEHLER_ADDR"
    local city = uci:get_first("gluon-node-info", 'location', "city") or "FEHLER_ORT"
    local zip = uci:get_first("gluon-node-info", 'location', "zip") or "00000"
    local mystr = string.format("<b>Adresse:</b> %s, %s %s<br></br><b>Koordinaten:</b> %f %f<br></br><b>Community:</b> %s", addr, zip, city, lat, lon, community)
    local text = pkg_i18n.translate(
		'Located the future position of this node as follows, please verify:<br></br>'
	)
    text = text .. ' ' .. mystr

	local s = form:section(Section, nil, text)
  end

  return {'gluon-node-info'}
end
