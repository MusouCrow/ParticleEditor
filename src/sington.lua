local _class = require ("src.class") ("sington")

function _class:Ctor ()
	self.event = {}
end

function _class:AddEvent (name, user, func)
	self.event [name] = {user = user, func = func}
end
--[[
function _class:InheritEvent (name, tail)
	if (tail) then
		local count = string.find (name, "_")
		local main = string.sub (name, 1, count - 1)
		local tail = string.sub (name, count)
		
		self.event [main .. "_" .. self.parent:GetType () .. tail] = self.parent.event [name]
	else
		self.event [name] = self.parent.event [name]
	end
end
]]--

function _class:InheritEvent (pname, name)
	name = name or pname
	self.event [name] = self.parent.event [pname]
end

function _class:AdoptEvent (name, child, adoptName)
	self.event [name] = child.event [adoptName]
end

return _class