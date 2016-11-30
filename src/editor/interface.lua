local _class = require ("src.class") ("interface", "src.editor", "src.sington")
local _maxCount = 2147483647

local function _RunObjectEvent (...)
	return _class:RunEvent ("objmgr_runSelectedObjectEvent", ...)
end

local function _HandleText (text)
	for k, v in pairs (text) do
		if (type (v) == "table") then
			if (k == "tip") then
				local tip = ""
				
				for n=1, #v do
					tip = tip .. v[n] .. "\n"
				end
				
				text.tip = tip
			elseif (k == "items") then
				local itemsString = ""
				
				for n=1, #v do
					itemsString = itemsString .. v[n] .. "\0"
				end
				
				text.itemsString = itemsString
			else
				_HandleText (v)
			end
		end
	end
end

local function _CutString (str, key)
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

function _class:Init (imgui, text)
	self.text = text
	_HandleText (self.text)
	
	self.imgui = imgui
	self.widgetID = 0
	self.combo = {
		areaSpread = {uniform = 1, normal = 2, ellipse = 3, none = 4},
		insertMode = {top = 1, bottom = 2, random = 3},
		normalMode = {alpha = 1, replace = 2, screen = 3, add = 4, subtract = 5, multiply = 6, lighten = 7, darken = 8},
		alphaMode = {alphamultiply = 1, premultiplied = 2}
	}
	
	self.messageBox = {
		open = false,
		text = "",
		type = "",
		width = 0,
		height = 0,
		font = love.graphics.getFont ()
	}
	
	self.keepScale = false
	
	for k, v in pairs (self.imgui) do
		print (k, v)
	end
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
		love.graphics.print (self.messageBox.text, math.ceil (w * 0.5 - self.messageBox.width), math.ceil (h * 0.5 - self.messageBox.height))
	else
		self:DrawWidget ()
	end
end

function _class:DrawWidget ()
	local inspector = self.text.inspector
	local synthesis = self.text.synthesis
	local button = self.text.button
	local data = _RunObjectEvent ("getData")
	local setting = _RunObjectEvent ("getSetting")
	local hasTexture = _RunObjectEvent ("hasImage")
	
	if (data) then
		self.imgui.SetNextWindowPos (love.graphics.getWidth () - 340, 0)
		self.imgui.SetNextWindowSize (340, love.graphics.getHeight ())		
		self.imgui.Begin (inspector.title, true, {"NoResize", "NoMove"})
			local necessity = inspector.necessity
			if (self.imgui.CollapsingHeader (necessity.title)) then
				self:Title (necessity.texture)
					if (self:Button (button.image)) then
						self:MessageBox ("texture")
					end
					self.imgui.SameLine ()
					self.imgui.Text (_RunObjectEvent ("getTextureName"))
				self.imgui.Spacing ()
				
				self:Title (necessity.bufferSize)
					if (self:Drag ("Int", necessity.bufferSize.size, data, "bufferSize", 1, 1, _maxCount)) then
						_RunObjectEvent ("updateBufferSize")
					end
				self.imgui.Spacing ()
				
				self:Title (necessity.emissionRate)
					self:Drag ("Float", necessity.emissionRate.rate, data, "emissionRate", 0.1, 0, _maxCount)
				self.imgui.Spacing ()
				
				self:Title (necessity.emissionLifetime)
					if (self:Drag ("Float", necessity.emissionLifetime.life, data, "emitterLifetime", 0.1, -1, _maxCount)) then
						_RunObjectEvent ("updateEmitterLifetime")
					end
				self.imgui.Spacing ()
				
				self:Title (necessity.particleLifetime)
					self:Drag ("Float2", necessity.particleLifetime.min_max, data.particleLifetime, nil, 0.1, 0, _maxCount)
				self.imgui.Spacing ()
			end
			
			if (hasTexture) then
				local outward = inspector.outward
				if (self.imgui.CollapsingHeader (outward.title)) then
					self:Title (outward.areaSpread)
						self:Combo (outward.areaSpread.distribution, self.combo.areaSpread, data.areaSpread, "distribution")
						self:Drag ("Float2", outward.areaSpread.dx_dy, data.areaSpread.distance, nil, 0.1, 0, _maxCount)
					self.imgui.Spacing ()
					
					self:Title (outward.insertMode)
						self:Combo (outward.insertMode.mode, self.combo.insertMode, data, "insertMode")
					self.imgui.Spacing ()
					
					self:Title (outward.offset)
						self:Drag ("Int2", outward.offset.x_y, data.offset)
					self.imgui.Spacing ()
					
					self:Title (outward.direction)
						self:Drag ("Float", outward.direction.direction, data, "direction")
					self.imgui.Spacing ()
					
					self:Title (outward.spread)
						self:Drag ("Float", outward.spread.spread, data, "spread")
					self.imgui.Spacing ()
					
					self:MemberTree (outward.quads, data, "quads")
				end
				
				local motion = inspector.motion
				if (self.imgui.CollapsingHeader (motion.title)) then
					self:Title (motion.speed)
						self:Drag ("Float2", motion.speed.min_max, data.speed)
					self.imgui.Spacing ()
					
					self:Title (motion.radialAcceleration)
						self:Drag ("Float2", motion.radialAcceleration.min_max, data.radialAcceleration)
					self.imgui.Spacing ()
					
					self:Title (motion.tangentialAcceleration)
						self:Drag ("Float2", motion.tangentialAcceleration.min_max, data.tangentialAcceleration)
					self.imgui.Spacing ()
					
					self:Title (motion.linearDamping)
						self:Drag ("Float2", motion.linearDamping.min_max, data.linearDamping)
					self.imgui.Spacing ()
					
					self:Title (motion.linearAcceleration)
						self:Drag ("Float2", motion.linearAcceleration.min, data.linearAcceleration.min)
						self:Drag ("Float2", motion.linearAcceleration.max, data.linearAcceleration.max)
					self.imgui.Spacing ()
					
					self:Title (motion.spin)
						self:Drag ("Float2", motion.spin.min_max, data.spin.interval)
						self:Drag ("Float", motion.spin.variation, data.spin, "variation", 0.1, 0, 1)
					self.imgui.Spacing ()
					
					self:Title (motion.rotation)
						self.imgui.SameLine ()
						self:CheckBox (motion.rotation.enable, data.rotation, "enable")
						self:Drag ("Float2", motion.rotation.min_max, data.rotation.interval)
					self.imgui.Spacing ()
					
					self:MemberTree (motion.colors, data, "colors")
					self:MemberTree (motion.sizes, data, "sizes")
				end
				
				local drawing = inspector.drawing
				if (self.imgui.CollapsingHeader (drawing.title)) then
					self:Title (drawing.position)
						self:Drag ("Int2", drawing.position.param, data.drawing.position)
					self.imgui.Spacing ()
					
					self:Title (drawing.orientation)
						self:Drag ("Float", drawing.orientation.param, data.drawing, "orientation")
					self.imgui.Spacing ()
					
					self:Title (drawing.scale)
						self.imgui.SameLine ()
						self:CheckBox (drawing.scale.keep, setting, "keepScale")
						self:Drag ("Float2", drawing.scale.param, data.drawing.scale)
					self.imgui.Spacing ()
					
					self:Title (drawing.origin)
						self:Drag ("Int2", drawing.origin.param, data.drawing.origin)
					self.imgui.Spacing ()
					
					self:Title (drawing.shearing)
						self:Drag ("Float2", drawing.shearing.param, data.drawing.shearing)
					self.imgui.Spacing ()
					
					self:Title (drawing.color)
						self:ColorEdit4 (data.drawing.color)
					self.imgui.Spacing ()
					
					self:Title (drawing.blendmode)
						self:Combo (drawing.blendmode.normalMode, self.combo.normalMode, data.drawing.blendmode, "normal")
						self:Combo (drawing.blendmode.alphaMode, self.combo.alphaMode, data.drawing.blendmode, "alpha")
					self.imgui.Spacing ()
				end
			end
		_RunObjectEvent ("updateMany")
		self.imgui.End ()
	end
	
	self.imgui.SetNextWindowPos (0, 0)
	self.imgui.SetNextWindowSize (340, love.graphics.getHeight ())
	self.imgui.Begin (synthesis.title, true, {"NoResize", "NoMove"})
		local hierarchy = synthesis.hierarchy
		if (self.imgui.CollapsingHeader (hierarchy.title)) then
			self:Title (hierarchy.operation)
			self.imgui.Separator ()
				self:Title (hierarchy.operation.addition)
					if (self:Button (hierarchy.operation.addition.new)) then
						_class:RunEvent ("objmgr_createObject")
					end
					self.imgui.SameLine ()
					if (self:Button (hierarchy.operation.addition.open)) then
						self:MessageBox ("open")
					end
					if (data) then
						self.imgui.SameLine ()
						if (self:Button (hierarchy.operation.addition.clone)) then
							_class:RunEvent ("objmgr_cloneObject")
						end
					end
				self.imgui.Spacing ()
				
				if (data) then
					self:Title (hierarchy.operation.animation)
						if (self:Button (hierarchy.operation.animation.reset)) then
							_RunObjectEvent ("reset")
						end
						self.imgui.SameLine ()
						
						if (_RunObjectEvent ("isPaused")) then
							if (self:Button (hierarchy.operation.animation.resume)) then
								_RunObjectEvent ("pause_resume")
							end
						else
							if (self:Button (hierarchy.operation.animation.pause)) then
								_RunObjectEvent ("pause_resume")
							end
						end
					self.imgui.Spacing ()
					
					self:Title (hierarchy.operation.order)
						if (self:Button (hierarchy.operation.order.up)) then
							_class:RunEvent ("objmgr_orderObject", -1)
						end
						self.imgui.SameLine ()
						if (self:Button (hierarchy.operation.order.down)) then
							_class:RunEvent ("objmgr_orderObject", 1)
						end
					self.imgui.Spacing ()
					
					local hasRemoved = false
					self:Title (hierarchy.operation.other)
						if (self:Button (hierarchy.operation.other.save)) then
							local path = _class:RunEvent ("objmgr_saveObject")
							self:MessageBox ("save", path)
						end
						self.imgui.SameLine ()
						if (self:Button (hierarchy.operation.other.remove)) then
							_class:RunEvent ("objmgr_removeObject")
							hasRemoved = true
						end
					self.imgui.Spacing ()
					
					self:Title (hierarchy.operation.rename)
						if (not hasRemoved) then
							local pass
							local name = _RunObjectEvent ("getName")
							pass, name = self.imgui.InputText (hierarchy.operation.rename.input.title, name, #name + 1)
							if (pass) then
								_RunObjectEvent ("setName", name)
							end
						end
					self.imgui.Spacing ()
				end
			self.imgui.Separator ()
			
			local id, nameList = _class:RunEvent ("objmgr_getListAbout")
			local listCount = #nameList
			
			if (listCount > 0) then
				self:Title (hierarchy.list)
					self.imgui.PushItemWidth (327)
					local _, selectionID = self.imgui.ListBox ("", id, nameList, listCount, listCount)
					_class:RunEvent ("objmgr_setSelection", selectionID)
				self.imgui.Spacing ()
			end
		end
		
		local opinions = synthesis.opinions
		if (self.imgui.CollapsingHeader (opinions.title)) then
			self:Title (opinions.backgroundImage)
				if (self:Button (button.image)) then
					self:MessageBox ("background")
				end
				
				self.imgui.SameLine ()
				self.imgui.Text (_class:RunEvent ("background_getName"))
			self.imgui.Spacing ()
			
			self:Title (opinions.backgroundColor)
				self:ColorEdit4 (_class:RunEvent ("background_getColor"))
			self.imgui.Spacing ()
			
			self:Title (opinions.display)
				self.imgui.Text (opinions.display.fps.title .. love.timer.getFPS ())
				self:HoveredTooltip (opinions.display.fps.tip)
				self.imgui.Text (opinions.display.liveCount.title .. _class:RunEvent ("objmgr_getLiveCount"))
				self:HoveredTooltip (opinions.display.liveCount.tip)
			self.imgui.Spacing ()
		end
		
		local help = synthesis.help
		if (self.imgui.CollapsingHeader (help.title)) then
			self:Title (help.about)
				for n=1, #help.about.text do
					self.imgui.TextWrapped (help.about.text[n])
				end
			self.imgui.Separator ()
			
			self:Title (help.keyboard)
				for n=1, #help.keyboard.list do
					self.imgui.Spacing ()
					self.imgui.Text (help.keyboard.list[n].title)
					self.imgui.Text (help.keyboard.list[n].text)
				end
			self.imgui.Separator ()
			
			self:Title (help.use)
				for n=1, #help.use.text do
					self.imgui.TextWrapped (help.use.text[n])
				end
			self.imgui.Spacing ()
		end
	self.imgui.End ()
	
	self.imgui.Render ()
	self.widgetID = 0
end

function _class:MessageBox (type, ...)
	self.messageBox.type = type
	self.messageBox.open = true
	
	if (type == "texture" or type == "background") then
		self.messageBox.text = self.text.messageBox.image
	elseif (type == "save") then
		self.messageBox.text = string.format (self.text.messageBox.save, ...)
	elseif (type == "open") then
		self.messageBox.text = self.text.messageBox.open
	end
	
	self.messageBox.text = self.messageBox.text .. self.text.messageBox.closeTips
	self.messageBox.width = self.messageBox.font:getWidth (self.messageBox.text) * 0.5
	self.messageBox.height = self.messageBox.font:getHeight (self.messageBox.text) * 0.5
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

function _class:PopID ()
	self.imgui.PopID ()
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
	
	self:PopID ()
	
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
	self:PopID ()
	
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
	
	self:PopID ()
	
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

function _class:CheckBox (text, data, key)
	self:PushID ()
	local title = ""
	local isTab = type (text) == "table"
	
	if (isTab) then
		title = text.title
	else
		title = text
	end

	_, data [key] = self.imgui.Checkbox (title, data [key])
	
	if (isTab) then
		self:HoveredTooltip (text.tip)
	end

	self:PopID ()
end

function _class:MemberTree (text, data, type)
	if (self:Tree (text)) then
		local activity = false
		local listData = data [type]
		local canRemove = #listData > 1
		local removeID = 0
		
		if (#listData < 8) then
			self.imgui.SameLine ()
			if (self:Button (self.text.button.add, true)) then
				_RunObjectEvent ("addMember", type)
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
				self:PopID ()
			elseif (type == "quads") then
				self:PushID ()
				local x, y, w, h = listData [n]:getViewport ()
				ret, x, y, w, h = self.imgui.DragInt4 ("", x, y, w, h, 1, 0, _maxCount)
				self:HoveredTooltip (self.text.inspector.outward.quads.member.tip)
				self:PopID ()
				
				if (ret) then
					_RunObjectEvent ("setQuad", listData [n], x, y, w, h)
				end
			end
			
			if (ret) then
				activity = true
			end
			
			if (canRemove) then
				self.imgui.SameLine ()
				if (self:Button (self.text.button.remove, true)) then
					activity = true
					removeID = n
				end
			end
		end
		
		if (removeID > 0) then
			_RunObjectEvent ("removeMember", type, removeID)
		end
		
		if (activity) then
			_RunObjectEvent ("updateMember", type)
		end
		
		self.imgui.TreePop ()
		self.imgui.Spacing ()
	end
end

function _class:Filedropped (file)
	if (self.messageBox.open and file) then
		local content = file:read ()
		local fileName = file:getFilename ()
		local strList = _CutString (fileName, "/")
		local name = strList [#strList]
		
		if (self.messageBox.type == "texture" or self.messageBox.type == "background") then
			local fileData = love.filesystem.newFileData (content, fileName)
			local imageData = love.image.newImageData (fileData)
			local image = love.graphics.newImage (imageData)
			
			_class:RunEvent ("setImage", self.messageBox.type, image, name)
			self.messageBox.open = false
		elseif (self.messageBox.type == "open") then
			local data = _class:RunEvent ("makeJson", content)
			local name = _CutString (name, ".json") [1]
			
			_class:RunEvent ("objmgr_createObject", data, name)
			self.messageBox.open = false
		end
	end
end

function _class:Quit ()
	self.imgui.ShutDown ()
end

function _class:TextInput (text)
	self.imgui.TextInput (text)
end

function _class:KeyPressed (key)
	if (key == "space") then
		_RunObjectEvent ("pause_resume")
	elseif (key == "return") then
		_RunObjectEvent ("reset")
	elseif (key == "up") then
		_class:RunEvent ("objmgr_orderObject", -1)
	elseif (key == "down") then
		_class:RunEvent ("objmgr_orderObject", 1)
	end
	
	self.imgui.KeyPressed (key)
end

function _class:KeyReleased (key)
	self.imgui.KeyReleased (key)
end

function _class:MouseMoved (x, y)
	self.imgui.MouseMoved (x, y)
end

function _class:MousePressed (x, y, button)
	if (self.messageBox.open and button == 1) then
		self.messageBox.open = false
	else
		if (button == 2) then
			_RunObjectEvent ("setPosition", x, y)
		end
	end
	
	self.imgui.MousePressed (button)
end

function _class:MouseReleased (button)
	self.imgui.MouseReleased (button)
end

function _class:WheelMoved (y)
	self.imgui.WheelMoved (y)
end

return _class.New ()