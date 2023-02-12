local util = require "gluon.util"
local uci = require("simple-uci").cursor()

local f = Form(translate("Welcome!"))
f.submit = translate('Save')
f.reset = false

local s = f:section(Section)
s.template = "wizard/welcome"
s.package = "gluon-config-mode-core"

for _, entry in ipairs(util.glob('/lib/gluon/config-mode/geoloc-4830/*')) do
	local section = assert(loadfile(entry))
	setfenv(section, getfenv())
	section()(f, uci)
end

function f:write()
	local fcntl = require 'posix.fcntl'
	local unistd = require 'posix.unistd'

	uci:set("gluon-setup-mode", uci:get_first("gluon-setup-mode", "setup_mode"), "configured", true)
	uci:save("gluon-setup-mode")

	os.execute('exec gluon-reconfigure >/dev/null')
    os.execute('date >/tmp/geolocate.done')
end

return f
