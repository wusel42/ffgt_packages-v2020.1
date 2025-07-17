local uci = require("simple-uci").cursor()
local site_i18n = i18n 'gluon-site'
local ffgt_i18n = i18n 'ffgt-config-mode-wizard'
local f = Form(translate("Mesh"))
local s
local o
local text
local text2
local json = require 'jsonc'
local site = require 'gluon.site'
local util = require 'gluon.util'

local selected_domain = uci:get('gluon', 'core', 'domain')
local configured = uci:get_first('gluon-setup-mode','setup_mode', 'configured') == '1' or
		(selected_domain ~= site.default_domain())

local function hide_domain_code(domain, code)
	if configured and code == selected_domain then
		return false
	elseif type(domain.hide_domain) == 'table' then
		return util.contains(domain.hide_domain, code)
	else
		return domain.hide_domain
	end
end

local function get_domain_list()
	local list = {}
	for _, domain_path in ipairs(util.glob('/lib/gluon/domains/*.json')) do
		local domain_code = domain_path:match('([^/]+)%.json$')
		local domain = assert(json.load(domain_path))

		if not hide_domain_code(domain, domain_code) then
			table.insert(list, {
				domain_code = domain_code,
				domain_name = domain.domain_names[domain_code],
			})
		end
	end

	table.sort(list, function(a, b) return a.domain_name < b.domain_name end)
	return list
end

text = ffgt_i18n.translate('Mesh-select') .. "<br>&nbsp;<br>" .. "<strong>" .. ffgt_i18n.translate('Mesh-select-warning') .. "</strong><br>"
s = f:section(Section, nil, text)
o = s:option(ListValue, 'domain', ffgt_i18n.translate('Mesh'))

if configured then
	o.default = selected_domain
end

for _, domain in ipairs(get_domain_list()) do
	o:value(domain.domain_code, domain.domain_name)
end

function o:write(data)
    local cmdstr = string.format('/sbin/uci set gluon-node-info.@location[0].locode=%s', data)

	uci:set('gluon', 'core', 'domain', data)
	uci:save('gluon')
	os.execute(cmdstr)
end

function f:write()
	uci:commit("gluon")
	uci:commit("gluon-node-info")
end

return f
