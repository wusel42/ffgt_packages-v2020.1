package 'gluon-web-private-wifi'
local util = require 'gluon.util'
local has_wifi = string.gsub(util.exec("/usr/sbin/iw list | /usr/bin/wc -l"), "\n", "")
if (tonumber(has_wifi) > 0) then
 entry({"admin", "privatewifi"}, model("admin/privatewifi"), _("Private WLAN"), 30)
end