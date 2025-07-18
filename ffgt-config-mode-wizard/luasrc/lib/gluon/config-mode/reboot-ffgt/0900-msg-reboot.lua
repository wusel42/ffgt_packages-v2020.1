local site_i18n = i18n 'gluon-site'

local site = require 'gluon.site'
local sysconfig = require 'gluon.sysconfig'
local pretty_hostname = require 'pretty_hostname'
local json = require 'jsonc'
local util = require 'gluon.util'
local uci = require("simple-uci").cursor()

local hostname = pretty_hostname.get(uci)
local contact = uci:get_first('gluon-node-info', 'owner', 'contact')
local domain_code = uci:get('gluon', 'core', 'domain')
local domain = assert(json.load('/lib/gluon/domains/' .. domain_code .. '.json'))
local mesh_name = domain.domain_names[domain_code] or 'n/a'
local community_name = domain.community_name or mesh_name
local community_mail = domain.community_contact or 'n/a'
local community_url = domain.community_website or 'n/a'

local msg = site_i18n._translate('gluon-config-mode:reboot')
if not msg then return end

renderer.render_string(msg, {
	hostname = hostname,
	site = site,
	sysconfig = sysconfig,
	contact = contact,
	community_name = community_name,
	community_mail = community_mail,
	community_url = community_url
})
