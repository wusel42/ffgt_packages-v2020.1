package 'gluon-web-wifi-config'
local util = require 'gluon.util'
local has_wifi = string.gsub(util.exec("/usr/sbin/iw list | /usr/bin/wc -l), "\n", "")
if (has_wifi > 0) then
 entry({"admin", "wifi-config"}, model("admin/wifi-config"), _("WLAN"), 20)
end
