return function(form, uci)
	local pkg_i18n = i18n 'ffgt-geolocate'
	-- 'gluon-config-mode-contact-info'
	local site_i18n = i18n 'gluon-site'
	local site = require 'gluon.site'
	local util = require 'gluon.util'

	local owner = uci:get_first("gluon-node-info", "owner")
	local contact = uci:get("gluon-node-info", owner, "contact")
    local valid_contact = false

    if contact then
	    local text = pkg_i18n.translate("The email address of this node's operator looks valid and is recorded as: ")
	    text = text .. string.format('<a href="mailto:%s">%s</a>.<br><div></div></br>', contact, contact)
	    text = text .. pkg_i18n.translate('To change it, go to Advanced settings/Contact.')
	    form:section(Section, nil, text)
	else
        local cmdstr='touch /tmp/return2wizard.hack 2>/dev/null'
        util.exec(cmdstr)
        local text = '<script> window.location.href = "/cgi-bin/config/admin/contact";</script>'
        text = text .. pkg_i18n.translate('CONTACT NOT SET. Please go to %s.')
        text = "<CENTER><STRONG>" .. string.format(text, '<a href="/cgi-bin/config/admin/contact">Contact</a>') .. "</STRONG></CENTER>"
        form:section(Section, nil, text)
    end

	return {'gluon-node-info'}
end
