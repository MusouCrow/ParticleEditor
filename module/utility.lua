local _module = {}
local _outputPath = love.filesystem.getSourceBaseDirectory() .. "/" .. love.filesystem.getIdentity () .. "/"

function _module:Init (cjson)
	self.cjson = cjson
end

function _module:OpenJson (path)
	local content = love.filesystem.read (path)
	
	return self.cjson.decode (content)
end

function _module:SaveJson (path, data)
	local file = io.open (_outputPath .. path, "w+")
	file:write (self.cjson.encode (data))
	file:close ()
end

function _module:CutString (str, key)
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

function _module:CopyTable (tab)
	local newTab = {}
	
	for k, v in pairs(tab) do
		if (type (v) ~= "table") then
			newTab [k] = v
		else
			newTab [k] = self:CopyTable (v)
		end
	end
	
	return newTab
end

function _module:ClearTable (tab)
	for k in pairs (tab) do
		tab [k] = nil
	end
end

return _module