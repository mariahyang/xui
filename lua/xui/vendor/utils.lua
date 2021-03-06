--[[
/*
 * HTML5 GUI Framework for FreeSWITCH - XUI
 * Copyright (C) 2015-2016, Seven Du <dujinfang@x-y-t.cn>
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is XUI - GUI for FreeSWITCH
 *
 * The Initial Developer of the Original Code is
 * Seven Du <dujinfang@x-y-t.cn>
 * Portions created by the Initial Developer are Copyright (C)
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * Seven Du <dujinfang@x-y-t.cn>
 *
 *
 */
]]

utils = {}

function utils.isModuleAvailable(name)
	if package.loaded[name] then
		return true
	else
		for _, searcher in ipairs(package.searchers or package.loaders) do
			local loader = searcher(name)
			if type(loader) == 'function' then
				package.preload[name] = loader
				return true
			end
		end
		return false
	end
end

function init_json_func()
	if utils.isModuleAvailable("cjson") then
		local json = require("cjson")
		utils.json_encode = json.encode
		utils.json_decode = json.decode
	else
		local json = require("JSON")
		utils.json_encode = function(...) return json.encode(json, ...) end
		utils.json_decode = function(...) return json.decode(json, ...) end
	end
end

init_json_func()

function strjoin(list, delimiter, quote)
	d = ""
	string = ""

	if not delimiter then delimiter = "," end

	for k,v in pairs(list) do
		if quote then v = "'" .. v .. "'" end

		string = string .. d .. v
		d = delimiter
	end
	return string
end

-- Split text into a list consisting of the strings in text,
-- separated by strings matching delimiter (which may be a pattern).
-- example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")
function strsplit(delimiter, text)
  local list = {}
  local pos = 1
  if strfind("", delimiter, 1) then -- this would result in endless loops
    error("delimiter matches empty string!")
  end
  while 1 do
    local first, last = strfind(text, delimiter, pos)
    if first then -- found?
      tinsert(list, strsub(text, pos, first-1))
      pos = last+1
    else
      tinsert(list, strsub(text, pos))
      break
    end
  end
  return list
end

utils.apply_dnc = function(number, dnc)
	if not dnc then return end

	if dnc:sub(1,1) == '/' then -- regexp
		local api=freeswitch.API()
		return api:execute("regex", "m:/" .. number .. dnc)
	end

	if dnc:sub(1,1) == 'r' then
		local n = tonumber(dnc:sub(2,2))
		local r = dnc:sub(3)
		return r .. number:sub(n + 1)
	end

	if dnc:sub(1,1) == 'R' then
		local n = tonumber(dnc:sub(2,2))
		local r = dnc:sub(3)
		if number:len() < n then
			return r
		else
			return number:sub(1, number:len() - n) .. r
		end
	end

	dnc:gsub("([+-][^+-]+)", function(prefix)
		-- print(prefix)
		if prefix:sub(1,1) == '-' then
			prefix = prefix:sub(2)
			local pos = 2
			local s, e = string.find(number, prefix)
			if (s == 1) then
				pos = 1 + e
			end
			number = number:sub(pos)
		elseif prefix:sub(1,1) == '+' then
			number = prefix:sub(2) .. number
		end
	end)
	return number
end

function check_dir_exit(dir)
	-- body
	local file, err = io.open(dir, "r")
	
	if err then
		os.execute("mkdir -p " .. dir)
	end
end

utils.absname = function(filename, dir)
	if not dir then dir = config.upload_path end

	check_dir_exit(dir)

	return dir .. "/" .. filename
end

utils.tmpname = function(prefix, ext)
	if not prefix then prefix = '' end

	local api = freeswitch.API()
	local uuid = api:execute("create_uuid")
	filename = prefix .. os.date("%Y%m%d%H%M%S") .. "-" .. uuid
	if ext then
		filename = filename .. "." .. ext
	end
	return utils.absname(filename)
end

-- print table
utils.print_r = function(t)
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

return utils
