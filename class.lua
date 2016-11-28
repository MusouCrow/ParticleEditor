local _classMap = {}
 
local function _GetType (self)
	return self._type
end

local function _TypeOf (self, type)
	return self:GetType () == type
end

local function _RunEvent (self, name, ...)
	local event = self.parent.event [name]

	return event.func (event.user, ...)
end

local function _GetEvent (self, name)
	return self.parent.event [name]
end

local function _NullFunc ()
	
end

local function _NewFunc (self, name)
	self [name] = _NullFunc
end

local function _AddInterface (self, name, func)
	self.interface [name] = func
	self [name] = func
end

local function _RunInterface (self, name, ...)
	self.superInterface [name] (...)
end

return function (_type, parent, super)
	local muchSuper = false
	local instance = {}
	instance.Ctor = false
	instance.RunEvent = _RunEvent
	instance.GetEvent = _GetEvent
	instance.NewFunc = _NewFunc
	instance.AddInterface = _AddInterface
	instance.RunInterface = _RunInterface
	instance.superInterface = {}
	instance.interface = {}
	
	if (parent) then
		parent = require (parent)
		instance.parent = parent
	end
	
	if (super) then
		if (type (super) == "table") then
			for n=1, #super do
				super [n] = require (super [n])
				
				for k, v in pairs (super [n].interface) do
					instance.superInterface [k] = v
				end
			end
			
			muchSuper = true
		else
			super = require (super)
			instance.superInterface = super.interface
		end
		
		for k, v in pairs (instance.superInterface) do
			instance.interface [k] = v
		end
		
		instance.super = super
	end
	
	instance.New = function (...) 
		local obj = {}
		obj._type = _type
		obj.GetType = _GetType
		obj.TypeOf = _TypeOf
		
		if (parent) then
			obj.parent = parent
		end
		
		setmetatable (obj, {__index = _classMap [instance]})
		
		do
			local Create
			Create = function (c, ...)
				if (c.super) then
					if (#c.super == 0) then
						Create (c.super, ...)
					else
						for n=1, #c.super do
							Create (c.super [n], ...)
						end
					end
				end
				
				if (c.Ctor) then
					c.Ctor (obj, ...)
				end
			end
			
			Create (instance, ...)
		end
		
		return obj
	end
	
	local vtbl = {}
	_classMap [instance] = vtbl
	
	setmetatable (instance, {__newindex =
		function (t, k, v)
			vtbl [k] = v
		end
	})
 
	if (super) then
		if (muchSuper) then
			setmetatable (vtbl, {__index =
				function (t, k)
					local ret
					
					for n=1, #super do
						if (_classMap [super [n]] [k]) then
							ret = _classMap [super [n]] [k]
							vtbl [k] = ret
							
							return ret
						end
					end
					
					return ret
				end
			})
		else
			setmetatable (vtbl, {__index =
				function (t, k)
					local ret = _classMap [super][k]
					vtbl [k] = ret
					
					return ret
				end
			})
		end
	end

	return instance
end