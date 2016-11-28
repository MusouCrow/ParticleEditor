local _class = require ("class") ("interface", "editor", "sington")
local _maxCount = 2147483647

function _class:Init (text)
	self.text = text
	self.imgui = require ("imgui")
	self.widgetID = 0
	self.combo = {
		areaSpread = {uniform = 1, normal = 2, ellipse = 3, none = 4},
		insertMode = {top = 1, bottom = 2, random = 3},
		normalMode = {alpha = 1, replace = 2, screen = 3, add = 4, subtract = 5, multiply = 6, lighten = 7, darken = 8},
		alphaMode = {alphamultiply = 1, premultiplied = 2}
	}
	
	local font = love.graphics.getFont ()
	
	self.messageBox = {
		open = false,
		text = "",
		type = ""
	}
	
	self.acceptFile = {
		open = false,
		type = "texture",
		image = {
			width = font:getWidth (self.text.acceptFile.image) * 0.5,
			height = font:getHeight (self.text.acceptFile.image) * 0.5
		}
	}
end

function _class:Update ()
	self.imgui.NewFrame ()
end

function _class:Draw ()
	if (self.messageBox.open) then
		local w, h = love.graphics.getWidth (), love.graphics.getHeight ()
		
		love.graphics.setColor (0, 0, 0, 127)
		love.graphics.rectangle ("fill", 0, 0, w, h)
		love.graphics.setColor (255, 255, 255, 255)
		love.graphics.print (self.messageBox.text, w * 0.5 - self.messageBox.width, h * 0.5 - self.messageBox.height)
	else
		self:DrawWidget ()
	end
end

function _class:DrawWidget ()
	
end

function _class:HoveredTooltip (text)
	if (self.imgui.IsItemHovered ()) then
		self.imgui.SetTooltip (text)
	end
end

function _class:PushID ()
	self.widgetID = self.widgetID + 1
	self.imgui.PushID (self.widgetID)
end

function _class:Title (text)
	if (type (text) ~= "table") then
		self.imgui.Text (text)
	else
		self.imgui.Text (text.title)
		
		if (text.tip) then
			self:HoveredTooltip (text.tip)
		end
	end
end

function _class:Drag (name, text, data, key, ...)
	self:PushID ()
	
	local title, isDragging
	local isTab = type (text) == "table"
	
	if (isTab) then
		title = text.title
	else
		title = text
	end
	
	if (key) then
		isDragging, data [key] = self.imgui ["Drag" .. name] (title, data [key], ...)
	else
		local ret = {self.imgui ["Drag" .. name] (title, data [1], data [2], ...)}
		isDragging = ret [1]
		
		for n=2, #ret do
			data [n - 1] = ret [n]
		end
	end
	
	if (isTab) then
		if (text.tip) then
			self:HoveredTooltip (text.tip)
		end 
	end
	
	return isDragging
end

function _class:Combo (text, beadroll, data, key)
	self:PushID ()
	local _, value = self.imgui.Combo (text.title, beadroll [data [key]], text.itemsString)
	data [key] = text.items [value]
	
	if (text.tip) then
		self:HoveredTooltip (text.tip)
	end
end

function _class:Tree (text)
	if (type (text) ~= "table") then
		return self.imgui.TreeNode (text)
	else
		if (self.imgui.TreeNode (text.title)) then
			self:HoveredTooltip (text.tip)
			
			return true
		end
	end
	
	return false
end

function _class:ColorEdit4 (color)
	self:PushID ()
	local ret = {self.imgui.ColorEdit4 ("", color [1] / 255, color [2] / 255, color [3] / 255, color [4] / 255)}
	
	for n=2, #ret do
		color [n - 1] = ret [n] * 255
	end
	
	return ret [1]
end

function _class:Button (text, isSmall)
	local func
	
	if (isSmall) then
		func = self.imgui.SmallButton
	else
		func = self.imgui.Button
	end
	
	if (type (text) ~= "table") then
		return func (text)
	else
		local click = func (text.title)
		self:HoveredTooltip (text.tip)
		
		return click
	end
	
	return false
end

function _class:MemberTree (text, object, type)
	if (self:Tree (text)) then
		local activity = false
		local listData = object [type]
		local canRemove = #listData > 1
		
		if (#listData < 8) then
			self.imgui.SameLine ()
			if (self:Button (self.text.button.add, true)) then
				object:RunEvent ("addMember", type)
				activity = true
			end
		end
		
		for n=1, #listData do
			local ret = false
			
			if (type == "colors") then
				ret = self:ColorEdit4 (listData [n])
			elseif (type == "sizes") then
				self:PushID ()
				ret, listData [n] = self.imgui.DragFloat ("", listData [n], 0.1, 0, _maxCount)
			elseif (type == "quads") then
				self:PushID ()
				local x, y, w, h = listData [n]:getViewport ()
				ret, x, y, w, h = self.imgui.DragInt4 ("", x, y, w, h, 1, 0, _maxCount)
				self:HoveredTooltip (self.text.inspector.outward.quads.member.tip)
				
				if (ret) then
					object:RunEvent ("setQuad", listData [n], x, y, w, h)
				end
			end
			
			if (ret) then
				activity = true
			end
			
			if (canRemove) then
				self.imgui.SameLine ()
				if (self:Button (self.text.button.remove, true)) then
					object:RunEvent ("removeMember", type, n)
				end
			end
		end
		
		if (activity) then
			object:RunEvent ("updateMember", type)
		end
		
		self.imgui.TreePop ()
		self.imgui.Spacing ()
	end
end

function _class:Filedropped (file)
	if (self.messageBox.open and (self.messageBox.type == "texture" or self.messageBox.type == "background") and file) then
		local contents = file:read ()
		local fileName = file:getFilename ()
		local fileData = love.filesystem.newFileData (contents, fileName)
		local imageData = love.image.newImageData (fileData)
		local image = love.graphics.newImage (imageData)
		local strList = self.utility:CutString (fileName, "/")
		local name = strList [#strList]
		
		_class:RunEvent ("setImage", self.messageBox.type, image, name)
		self.messageBox.open = false
	end
end

function _class:KeyPressed (key)
	if (self.messageBox.open and key == "escape") then
		self.messageBox.open = false
	end
	
	self.imgui.KeyPressed (key)
end

function _class:Quit ()
	self.imgui.ShutDown ()
end

function _class:TextInput (text)
	self.imgui.TextInput (text)
end

function _class:KeyReleased (key)
	self.imgui.KeyReleased (key)
end

function _class:MouseMoved (x, y)
	self.imgui.MouseMoved (x, y)
end

function _class:MousePressed (button)
	self.imgui.MousePressed (button)
end

function _class:MouseReleased (button)
	self.imgui.MouseReleased (button)
end

function _class:WheelMoved (y)
	self.imgui.WheelMoved (y)
end

return _class.New ()