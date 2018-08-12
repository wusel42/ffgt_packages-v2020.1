--[[
Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

package 'ffgt-geolocate'

local util = require 'gluon.util'
local site = require 'gluon.site'
local uci = require("simple-uci").cursor()


local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

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

local function action_contact(http, renderer)
    -- Determine state
    local step = tonumber(http:getenv("REQUEST_METHOD") == "POST" and http:formvalue("step")) or 1
    local owner = uci:get_first("gluon-node-info", "owner")
    local contact = uci:get("gluon-node-info", owner, "contact")
    local valid_contact = false

    -- Step 1: Display form
    if step == 1 then
        renderer.render_layout('admin/contact', { contact, }, 'ffgt-geolocate')
    -- Step 2: Validate
    elseif step >=1 then
        contact=http:formvalue("contact")

       if contact then contact=trim(contact) else contact="{empty}" end
        valid_contact, error_message = validemail(contact)
        -- if not error_message then error_message="" end
        if not (valid_contact == true) then
            renderer.render_layout('admin/contact', { contact, error_message, }, 'ffgt-geolocate')
        else
            uci:set("gluon-node-info", owner, "contact", contact)
            uci:commit('gluon-node-info')
            renderer.render_layout('admin/contact_done', { contact, } , 'ffgt-geolocate')
        end
    end
end

local contact = entry({"admin", "contact"}, call(action_contact), _("Contact"), 3)
