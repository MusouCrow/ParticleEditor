local _module = {}
local _outputPath = love.filesystem.getSourceBaseDirectory() .. "/" .. love.filesystem.getIdentity () .. "/"

function _module:Init (cjson)
	self.cjson = cjson
end

function _module:Open (path)
	local content = love.filesystem.read (path)
	
	return self.cjson.decode (content)
end

function _module:Save (path, data)
	local file = io.open (_outputPath .. path, "w+")
	file:write (self.cjson.encode (data))
	file:close ()
end

return _module