local _module = {}
local _maxCount = 2147483647

function _module:Init (imgui, text, data)
	self.imgui = imgui
	self.text = text
	self.data = data
	self.widgetID = 0
	self.combo = {
		areaSpread = {uniform = 1, normal = 2, ellipse = 3, none = 4},
		insertMode = {top = 1, bottom = 2, random = 3},
		normalMode = {alpha = 1, replace = 2, screen = 3, add = 4, subtract = 5, multiply = 6, lighten = 7, darken = 8},
		alphaMode = {alphamultiply = 1, premultiplied = 2}
	}
	
	local font = love.graphics.getFont ()
	
	self.acceptFile = {
		open = false,
		type = "texture",
		image = {
			width = font:getWidth (self.text.acceptFile.image) * 0.5,
			height = font:getHeight (self.text.acceptFile.image) * 0.5
		}
	}
end

function _module:Update ()
	self.imgui.NewFrame ()
end

function _module:HoveredTooltip (text)
	if (self.imgui.IsItemHovered ()) then
		self.imgui.SetTooltip (text)
	end
end

function _module:PushID ()
	self.widgetID = self.widgetID + 1
	self.imgui.PushID (self.widgetID)
end

function _module:Title (text)
	if (type (text) ~= "table") then
		self.imgui.Text (text)
	else
		self.imgui.Text (text.title)
		
		if (text.tip) then
			self:HoveredTooltip (text.tip)
		end
	end
end

function _module:Drag (name, text, data, key, ...)
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

function _module:Combo (text, beadroll, data, key)
	self:PushID ()
	local _, value = self.imgui.Combo (text.title, beadroll [data [key]], text.itemsString)
	data [key] = text.items [value]
	
	if (text.tip) then
		self:HoveredTooltip (text.tip)
	end
end

function _module:Tree (text)
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

function _module:ColorEdit4 (color)
	self:PushID ()
	local ret = {self.imgui.ColorEdit4 ("", color [1] / 255, color [2] / 255, color [3] / 255, color [4] / 255)}
	
	for n=2, #ret do
		color [n - 1] = ret [n] * 255
	end
	
	return ret [1]
end

function _module:Button (text, isSmall)
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

function _module:MemberTree (text, type)
	if (self:Tree (text)) then
		local activity = false
		local list = self.data:GetSelection () [type]
		local canRemove = #list > 1
		
		if (#list < 8) then
			self.imgui.SameLine ()
			if (self:Button (self.text.button.add, true)) then
				self.data:AddDataMember (type)
				activity = true
			end
		end
		
		for n=1, #list do
			local ret = false
			
			if (type == "colors") then
				ret = self:ColorEdit4 (list [n])
			elseif (type == "sizes") then
				self:PushID ()
				ret, list [n] = self.imgui.DragFloat ("", list [n], 0.1, 0, _maxCount)
			elseif (type == "quads") then
				self:PushID ()
				local x, y, w, h = list [n]:getViewport ()
				ret, x, y, w, h = self.imgui.DragInt4 ("", x, y, w, h, 1, 0, _maxCount)
				self:HoveredTooltip (self.text.inspector.outward.quads.member.tip)
				
				if (ret) then
					self.data:SetQuad (list [n], x, y, w, h)
				end
			end
			
			if (ret) then
				activity = true
			end
			
			if (canRemove) then
				self.imgui.SameLine ()
				if (self:Button (self.text.button.remove, true)) then
					self.data:RemoveDataMember (type, n)
				end
			end
		end
		
		self.data.msg [type] = activity
		self.imgui.TreePop ()
		self.imgui.Spacing ()
	end
end

function _module:Draw ()
	if (self.acceptFile.open) then
		local w, h = love.graphics.getWidth (), love.graphics.getHeight ()
		
		love.graphics.setColor (0, 0, 0, 127)
		love.graphics.rectangle ("fill", 0, 0, w, h)
		love.graphics.setColor (255, 255, 255, 255)
		love.graphics.print (self.text.acceptFile.image, w * 0.5 - self.acceptFile.image.width, h * 0.5 - self.acceptFile.image.height)
	else
		self:DrawWidget ()
	end
end

function _module:DrawWidget ()
	local inspector = self.text.inspector
	local synthesis = self.text.synthesis
	local button = self.text.button
	local data = self.data:GetSelection ()
	
	if (data) then
		self.imgui.SetNextWindowPos (love.graphics.getWidth () - 340, 0)
		self.imgui.SetNextWindowSize (340, love.graphics.getHeight ())		
		self.imgui.Begin (inspector.title, true, {"NoResize", "NoMove"})
			local necessity = inspector.necessity
			if (self.imgui.CollapsingHeader (necessity.title)) then
				self:Title (necessity.texture)
					if (self:Button (button.image)) then
						self.acceptFile.open = true
						self.acceptFile.type = "texture"
					end
					self.imgui.SameLine ()
					if (data.texture) then
						self.imgui.Text (data.texture.name)
					else
						self.imgui.Text ("...")
					end
				self.imgui.Spacing ()
				
				self:Title (necessity.bufferSize)
					self.data.msg.bufferSize = self:Drag ("Int", necessity.bufferSize.size, data, "bufferSize", 1, 1, _maxCount)
				self.imgui.Spacing ()
				
				self:Title (necessity.emissionRate)
					self:Drag ("Float", necessity.emissionRate.rate, data, "emissionRate", 0.1, 0, _maxCount)
				self.imgui.Spacing ()
				
				self:Title (necessity.particleLifetime)
					self:Drag ("Float2", necessity.particleLifetime.min_max, data.particleLifetime, nil, 0.1, 0, _maxCount)
					self.data:CheckInterval (data.particleLifetime)
				self.imgui.Spacing ()
			end
			
			if (data.texture) then
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
					
					self:MemberTree (outward.quads, "quads")
				end
				
				local motion = inspector.motion
				if (self.imgui.CollapsingHeader (motion.title)) then
					self:Title (motion.speed)
						self:Drag ("Float2", motion.speed.min_max, data.speed)
						self.data:CheckInterval (data.speed)
					self.imgui.Spacing ()
					
					self:Title (motion.radialAcceleration)
						self:Drag ("Float2", motion.radialAcceleration.min_max, data.radialAcceleration)
						self.data:CheckInterval (data.radialAcceleration)
					self.imgui.Spacing ()
					
					self:Title (motion.tangentialAcceleration)
						self:Drag ("Float2", motion.tangentialAcceleration.min_max, data.tangentialAcceleration)
						self.data:CheckInterval (data.tangentialAcceleration)
					self.imgui.Spacing ()
					
					self:Title (motion.linearDamping)
						self:Drag ("Float2", motion.linearDamping.min_max, data.linearDamping)
						self.data:CheckInterval (data.linearDamping)
					self.imgui.Spacing ()
					
					self:Title (motion.linearAcceleration)
						self:Drag ("Float2", motion.linearAcceleration.min, data.linearAcceleration.min)
						self:Drag ("Float2", motion.linearAcceleration.max, data.linearAcceleration.max)
						self.data:CheckDoubleInterval (data.linearAcceleration)
					self.imgui.Spacing ()
					
					self:Title (motion.spin)
						self:Drag ("Float2", motion.spin.min_max, data.spin.interval)
						self.data:CheckInterval (data.spin.interval)
						self:Drag ("Float", motion.spin.variation, data.spin, "variation", 0.1, 0, 1)
					self.imgui.Spacing ()
					
					self:Title (motion.rotation)
						self.imgui.SameLine ()
						_, data.rotation.enable = self.imgui.Checkbox (motion.rotation.enable.title, data.rotation.enable)
						self:HoveredTooltip (motion.rotation.enable.tip)
						self:Drag ("Float2", motion.rotation.min_max, data.rotation.interval)
						self.data:CheckInterval (data.rotation.interval)
					self.imgui.Spacing ()
					
					self:MemberTree (motion.colors, "colors")
					self:MemberTree (motion.sizes, "sizes")
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
						self.data:New ()
					end
					self.imgui.SameLine ()
					self:Button (hierarchy.operation.addition.open)
					if (data) then
						self.imgui.SameLine ()
						if (self:Button (hierarchy.operation.addition.clone)) then
							self.data:Clone ()
						end
					end
				self.imgui.Spacing ()
				
				if (data) then
					self:Title (hierarchy.operation.animation)
						if (self:Button (hierarchy.operation.animation.reset)) then
							self.data:RunPsiEvent ("reset")
						end
						self.imgui.SameLine ()
						if (data.isPaused) then
							if (self:Button (hierarchy.operation.animation.resume)) then
								data.isPaused = false
							end
						else
							if (self:Button (hierarchy.operation.animation.pause)) then
								data.isPaused = true
							end
						end
					self.imgui.Spacing ()
					
					self:Title (hierarchy.operation.order)
						if (self:Button (hierarchy.operation.order.up)) then
							self.data:OrderUp ()
						end
						self.imgui.SameLine ()
						if (self:Button (hierarchy.operation.order.down)) then
							self.data:OrderDown ()
						end
					self.imgui.Spacing ()
					
					self:Title (hierarchy.operation.other)
						self:Button (hierarchy.operation.other.save)
						self.imgui.SameLine ()
						if (self:Button (hierarchy.operation.other.remove)) then
							self.data:Remove ()
						end
					self.imgui.Spacing ()
				end
			self.imgui.Separator ()
			
			local listCount = #self.data.nameList
			if (listCount > 0) then
				self:Title (hierarchy.list)
					self.imgui.PushItemWidth (327)
					_, self.data.selectionID = self.imgui.ListBox ("", self.data.selectionID, self.data.nameList, listCount, listCount)
				self.imgui.Spacing ()
			end
		end
		
		local opinions = synthesis.opinions
		if (self.imgui.CollapsingHeader (opinions.title)) then
			self:Title (opinions.backgroundImage)
				if (self:Button (button.image)) then
					self.acceptFile.open = true
					self.acceptFile.type = "background"
				end
				
				self.imgui.SameLine ()
				self.imgui.Text (self.data.background.fileName)
			self.imgui.Spacing ()
			
			self:Title (opinions.backgroundColor)
				self:ColorEdit4 (self.data.background.color)
			self.imgui.Spacing ()
			
			self:Title (opinions.display)
				self.imgui.Text (opinions.display.fps.title .. love.timer.getFPS ())
				self:HoveredTooltip (opinions.display.fps.tip)
				self.imgui.Text (opinions.display.liveCount.title .. data.psi:getCount ())
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

function _module:Quit ()
	self.imgui.ShutDown ()
end

function _module:TextInput (text)
	self.imgui.TextInput (text)
end

function _module:Filedropped (file)
	if (self.acceptFile.open and file) then
		self.data:SetImage (file, self.acceptFile.type)
		self.acceptFile.open = false
	end
end

function _module:KeyPressed (key)
	if (self.acceptFile.open and key == "escape") then
		self.acceptFile.open = false
	end
	
	self.imgui.KeyPressed (key)
end

function _module:KeyReleased (key)
	self.imgui.KeyReleased (key)
end

function _module:MouseMoved (x, y)
	self.imgui.MouseMoved (x, y)
end

function _module:MousePressed (button)
	self.imgui.MousePressed (button)
end

function _module:MouseReleased (button)
	self.imgui.MouseReleased (button)
end

function _module:WheelMoved (y)
	self.imgui.WheelMoved (y)
end

return _module