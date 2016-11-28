local _class = require ("class") ("editor", _, "sington")

function _class:Init ()
	self.utility = require ("editor.utility")
	self.objmgr = require ("editor.objmgr")
	self.background = require ("editor.background")
	self.interface = require ("editor.interface")
	
	self:AddEvent ("clearTable", self.utility, self.utility.ClearTable)
	self:AddEvent ("copyTable", self.utility, self.utility.CopyTable)
	self:AddEvent ("setImage", self, self.SetImage)
	
	self.utility:Init (require ("cjson"))
	self.objmgr:Init (self.utility:OpenJson ("data.json"))
end

function _class:Update (dt)
	self.objmgr:Update (dt)
end

function _class:Draw ()
	self.background:Draw ()
	self.objmgr:Draw ()
end

function _class:SetImage (type, image, name)
	if (type == "texture") then
		self.objmgr:SetImage (image, name)
	elseif (type == "background") then
		self.background:SetImage (image, name)
	end
end

return _class.New ()