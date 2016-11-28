local _class = require ("class") ("utility", "editor", "sington")
local _outputPath = love.filesystem.getSourceBaseDirectory() .. "/" .. love.filesystem.getIdentity () .. "/"

function _class:Init (cjson)
	self.cjson = cjson
end

function _class:OpenJson (path)
	local content = love.filesystem.read (path)
	
	return self.cjson.decode (content)
end

function _class:SaveJson (path, data)
	local file = io.open (_outputPath .. path, "w+")
	file:write (self.cjson.encode (data))
	file:close ()
end

function _class:CutString (str, key)
	local list = {}
	local keyLen = #key
	local pos = 1
	local at = string.find (str, key)
	
	while at do
		list [#list + 1] = string.sub (str, pos, at - 1)
		pos = at + keyLen
		at = string.find (str, key, pos)
	end
	
	list [#list + 1] = string.sub (str, pos)
	
	return list
end

function _class:CopyTable (tab)
	local newTab = {}
	
	for k, v in pairs (tab) do
		if (type (v) ~= "table") then
			newTab [k] = v
		else
			newTab [k] = self:CopyTable (v)
		end
	end
	
	return newTab
end

function _class:ClearTable (tab)
	for k in pairs (tab) do
		tab [k] = nil
	end
end

return _class.New ()