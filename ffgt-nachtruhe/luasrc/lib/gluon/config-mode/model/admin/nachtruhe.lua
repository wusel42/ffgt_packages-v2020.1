local uci = require('simple-uci').cursor()

pkg_i18n = i18n 'ffgt-nachtruhe'

if not uci:get('ap-timer', 'settings') then
	uci:section('ap-timer', 'ap-timer', 'settings')
	uci:save('ap-timer')
end

if not uci:get('ap-timer', 'all') then
	uci:section('ap-timer', 'day', 'all')
	uci:save('ap-timer')
end

local f = Form(pkg_i18n.translate('Nachtruhe'), pkg_i18n.translate(
	"You can enable 'Nachtruhe' (disable AP between 22:00 and 06:00) here"))

local s = f:section(Section)

enabled = s:option(Flag, 'enabled', pkg_i18n.translate('Enabled'))
enabled.default = uci:get_bool('ap-timer', 'settings', 'nachtruhe')
enabled.optional = false
function enabled:write(data)
	uci:set('ap-timer', 'settings', 'enabled', data)
	uci:set('ap-timer', 'nachtruhe', 'enabled', data)
    uci:set('ap-timer', 'settings', 'nachtruhe', data)
	if (data == true) then
        uci:set('ap-timer', 'settings', 'type', 'day')
        uci:set_list('ap-timer', 'all', 'on', '06:00')
       	uci:set_list('ap-timer', 'all', 'off', '22:00')
    else
        uci:delete('ap-timer', 'all', 'on')
       	uci:delete('ap-timer', 'all', 'off')
    end
    -- uci:commit('ap-timer')
end

function f:write()
--    local nachtruhe=uci:get_bool('ap-timer', 'settings', 'nachtruhe')
--    if (nachtruhe) then
--        uci:set('ap-timer', 'settings', 'type', 'day')
--        uci:set_list('ap-timer', 'all', 'on', '06:00')
--       	uci:set_list('ap-timer', 'all', 'off', '22:00')
--        uci:save('ap-timer')
--    end
    uci:commit('ap-timer')
end

return f
