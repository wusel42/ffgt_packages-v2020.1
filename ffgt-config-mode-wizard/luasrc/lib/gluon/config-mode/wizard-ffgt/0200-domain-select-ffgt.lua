
return function(form, uci)
    local site_i18n = i18n 'gluon-site'
    local ffgt_i18n = i18n 'ffgt-config-mode-wizard'
    local json = require 'jsonc'
    local site = require 'gluon.site'
    local util = require 'gluon.util'

    local selected_domain = uci:get('gluon', 'core', 'domain')
    local locode = uci:get_first("gluon-node-info", "location", "locode")
    local configured = uci:get_first('gluon-setup-mode','setup_mode', 'configured') == '1' or (selected_domain ~= site.default_domain())

    if locode then
        -- Selections happens via locode, configuration via domain ...
        if (selected_domain ~= locode) then
            uci:set('gluon', 'core', 'domain', locode)
            os.execute('gluon-reconfigure >/dev/null')
        end
        local domain = assert(json.load('/lib/gluon/domains/' .. locode .. '.json'))
        local mesh_name = domain.domain_names[locode] or 'n/a'
        local community_name = domain.community_name or mesh_name
        local text = ffgt_i18n.translate('Based on the coordinates configured, this node will be part of')
        text = text .. " <strong>" .. mesh_name .. "</strong>"
        if community_name ~= mesh_name then
            text = text .. ", Community " .. community_name
        end
        text = text .. "."

        local s = form:section(Section, nil, text)
    end

    return {'gluon', reconfigure}
end
