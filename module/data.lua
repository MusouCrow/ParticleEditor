local _module = {}

local function _Copy (tab)
	local newTab = {}
	
	for k, v in pairs(tab) do
		if (type (v) ~= "table") then
			newTab [k] = v
		else
			newTab [k] = _Copy (v)
		end
	end
	
	return newTab
end

function _module:Init (file)
	self.file = file
	self.list = {}
	self.selectionID = 0
	self.temple = self.file:Open ("data.json")
	
	self:New ()
	self.selectionID = 1
end

function _module:GetSelection ()
	return self.list [self.selectionID]
end

function _module:New ()
	self.list [#self.list + 1] = _Copy (self.temple)
end

function _module:Clone ()
	self.list [#self.list + 1] = _Copy (self.list [self.selectionID])
end

function _module:Remove ()
	table.remove (self.list, self.selectionID)
end

function _module:OrderUp ()
	if (self.selectionID > 1) then
		local selection = self.list [self.selectionID]
		self.list [self.selectionID] = self.list [self.selectionID - 1]
		self.list [self.selectionID - 1] = selection
		self.selectionID = self.selectionID - 1
	end
end

function _module:OrderDown ()
	if (self.selectionID < #self.list) then
		local selection = self.list [self.selectionID]
		self.list [self.selectionID] = self.list [self.selectionID + 1]
		self.list [self.selectionID + 1] = selection
		self.selectionID = self.selectionID + 1
	end
end

function _module:Save ()
	
end

function _module:Open ()
	
end

return _module