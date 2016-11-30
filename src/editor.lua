local _class = require ("src.class") ("editor", _, "src.sington")
local _outputPath = love.filesystem.getSourceBaseDirectory() .. "/" .. love.filesystem.getIdentity () .. "/"

function _class:Init ()
	local os = love.system.getOS ()
	
	if (os == "OS X") then
		package.cpath = package.cpath .. ";" .. _outputPath .. "lib/mac/?.so"
	elseif (os == "Windows") then
		package.cpath = package.cpath .. ";" .. _outputPath .. "lib/win32/?.dll"
	elseif (os == "Linux") then
		package.cpath = package.cpath .. ";" .. _outputPath .. "lib/ubt64/?.so"
	end
	
	self.cjson = require ("cjson")
	
	self.objmgr = require ("src.editor.objmgr")
	self.background = require ("src.editor.background")
	self.interface = require ("src.editor.interface")
	
	self:AddEvent ("makeJson", self, self.MakeJson)
	self:AddEvent ("saveJson", self, self.SaveJson)
	self:AddEvent ("setImage", self, self.SetImage)
	self:AddEvent ("objmgr_runSelectedObjectEvent", self.objmgr, self.objmgr.RunSelectedObjectEvent)
	self:AddEvent ("objmgr_createObject", self.objmgr, self.objmgr.CreateObject)
	self:AddEvent ("objmgr_cloneObject", self.objmgr, self.objmgr.CloneObject)
	self:AddEvent ("objmgr_orderObject", self.objmgr, self.objmgr.OrderObject)
	self:AddEvent ("objmgr_removeObject", self.objmgr, self.objmgr.RemoveObject)
	self:AddEvent ("objmgr_saveObject", self.objmgr, self.objmgr.SaveObject)
	self:AddEvent ("objmgr_getListAbout", self.objmgr, self.objmgr.GetListAbout)
	self:AddEvent ("objmgr_setSelection", self.objmgr, self.objmgr.SetSelection)
	self:AddEvent ("objmgr_getLiveCount", self.objmgr, self.objmgr.GetLiveCount)
	self:AddEvent ("background_getColor", self.background, self.background.GetColor)
	self:AddEvent ("background_getName", self.background, self.background.GetName)
	
	self.objmgr:Init (self:OpenJson ("data.json"))
	self.background:Init ()
	self.interface:Init (require ("imgui"), self:OpenJson ("text/en.json"))
end

function _class:Update (dt)
	self.objmgr:Update (dt)
	self.interface:Update ()
end

function _class:Draw ()
	self.background:Draw ()
	self.objmgr:Draw ()
	self.interface:Draw ()
end

function _class:SetImage (type, image, name)
	if (type == "texture") then
		self.objmgr:SetImage (image, name)
	elseif (type == "background") then
		self.background:SetImage (image, name)
	end
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

function _class:MakeJson (content)
	return self.cjson.decode (content)
end

function _class:Quit ()
	self.interface:Quit ()
end

function _class:Filedropped (file)
	self.interface:Filedropped (file)
end

function _class:TextInput (text)
	self.interface:TextInput (text)
end

function _class:KeyPressed (key)
	self.interface:KeyPressed (key)
end

function _class:KeyReleased (key)
	self.interface:KeyReleased (key)
end

function _class:MouseMoved (x, y)
	self.interface:MouseMoved (x, y)
end

function _class:MousePressed (x, y, button)
	self.interface:MousePressed (x, y, button)
end

function _class:MouseReleased (button)
	self.interface:MouseReleased (button)
end

function _class:WheelMoved (y)
	self.interface:WheelMoved (y)
end

return _class.New ()