
return function(form, uci)
	local site_i18n = i18n 'gluon-site'

	local fs = require 'nixio.fs'
	local json = require 'jsonc'
	local site = require 'gluon.site'
	local util = require 'gluon.util'

	local selected_domain = uci:get('gluon', 'core', 'domain')
    local locode = uci:get_first("gluon-node-info", "location", "locode")
  	local configured = uci:get_first('gluon-setup-mode','setup_mode', 'configured') == '1' or (selected_domain ~= site.default_domain())

    -- Selections happens via locode, configuration via domain ...
    if (selected_domain ~= locode) then
        uci:set('gluon', 'core', 'domain', locode)
        os.execute('gluon-reconfigure')
    end

    local text = site_i18n.translate('Based on the coordinates configured, this node will be part of:')
    local communityname = string.gsub(util.exec(string.format("/lib/gluon/ffgt-geolocate/get_domain_name.sh %s", locode)),"\n", "")
    text = text .. " <strong>" .. communityname .. "</strong>."
	local s = form:section(Section, nil, text)

	return {'gluon', reconfigure}
end
