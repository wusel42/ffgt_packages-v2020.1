-- FIXME, code duplicated in /home/wusel/4830.org/ffgt_packages-v2018.1/ffgt-geolocate/luasrc/lib/gluon/config-mode/controller/admin/contact.lua
-- https://gist.github.com/james2doyle/67846afd05335822c149
local function validemail(str)
  if str == nil then return nil end
  if (type(str) ~= 'string') then
    error("Expected string")
    return nil
  end
  local lastAt = str:find("[^%@]+$")
  local localPart = str:sub(1, (lastAt - 2)) -- Returns the substring before '@' symbol
  local domainPart = str:sub(lastAt, #str) -- Returns the substring after '@' symbol
  -- we werent able to split the email properly
  if localPart == nil then
    return nil, "Local name is invalid"
  end

  if domainPart == nil then
    return nil, "Domain is invalid"
  end
  -- local part is maxed at 64 characters
  if #localPart > 64 then
    return nil, "Local name must be less than 64 characters"
  end
  -- domains are maxed at 253 characters
  if #domainPart > 253 then
    return nil, "Domain must be less than 253 characters"
  end
  -- somthing is wrong
  if lastAt >= 65 then
    return nil, "Invalid @ symbol usage"
  end
  -- quotes are only allowed at the beginning of a the local name
  local quotes = localPart:find("[\"]")
  if type(quotes) == 'number' and quotes > 1 then
    return nil, "Invalid usage of quotes"
  end
  -- no @ symbols allowed outside quotes
  if localPart:find("%@+") and quotes == nil then
    return nil, "Invalid @ symbol usage in local part"
  end
  -- no dot found in domain name
  if not domainPart:find("%.") then
    return nil, "No TLD found in domain"
  end
  -- only 1 period in succession allowed
  if domainPart:find("%.%.") then
    return nil, "Too many periods in domain"
  end
  if localPart:find("%.%.") then
    return nil, "Too many periods in local part"
  end
  -- just a general match
  if not str:match('[%w]*[%p]*%@+[%w]*[%.]?[%w]*') then
    return nil, "Email pattern test failed"
  end
  -- all our tests passed, so we are ok
  return true
end


return function(form, uci)
	local pkg_i18n = i18n 'ffgt-geolocate'
	-- 'gluon-config-mode-contact-info'
	local site_i18n = i18n 'gluon-site'
	local site = require 'gluon.site'
	local util = require 'gluon.util'

	local owner = uci:get_first("gluon-node-info", "owner")
	local contact = uci:get("gluon-node-info", owner, "contact")
    local valid_contact = validemail(contact)

    if valid_contact then
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
