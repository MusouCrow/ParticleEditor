local _class = require ("src.class") ("object", "src.editor.objmgr")
local _canvas = love.graphics.newCanvas ()

local function _CheckInterval (data)
	if (data [2] < data [1]) then
		data [2] = data [1]
	end
end

local function _CheckDoubleInterval (data)
	for n=1, #data.max do
		if (data.max [n] < data.min [n]) then
			data.max [n] = data.min [n]
		end
	end
end

local function _CopyTable (tab)
	local newTab = {}
	
	for k, v in pairs (tab) do
		if (type (v) ~= "table") then
			newTab [k] = v
		else
			newTab [k] = _CopyTable (v)
		end
	end
	
	return newTab
end

local function _SetData (data)
	local newData = _CopyTable (data)
	
	newData.playingSpeed = newData.playingSpeed or 1
	
	for n=1, #newData.quads do
		local newQuad
		
		if (type (newData.quads [n]) == "userdata") then
			local x, y, w, h = newData.quads [n]:getViewport ()
			local sw, sh = newData.quads [n]:getTextureDimensions ()
			
			newQuad = love.graphics.newQuad (x, y, w, h, sw, sh)
		else
			newQuad = love.graphics.newQuad (unpack (newData.quads [n]))
		end
		
		newData.quads [n] = newQuad
	end
	
	return newData
end

local function _UpdateMany (self)
	_CheckInterval (self.data.particleLifetime)
	_CheckInterval (self.data.speed)
	_CheckInterval (self.data.radialAcceleration)
	_CheckInterval (self.data.tangentialAcceleration)
	_CheckInterval (self.data.linearDamping)
	_CheckInterval (self.data.spin.interval)
	_CheckInterval (self.data.rotation.interval)
	_CheckDoubleInterval (self.data.linearAcceleration)
	
	if (self.setting.keepScale) then
		self.data.drawing.scale [1] = self.data.drawing.scale [2]
	end
	
	self.ps:setEmissionRate (self.data.emissionRate)
	self.ps:setAreaSpread (self.data.areaSpread.distribution, unpack (self.data.areaSpread.distance))
	self.ps:setInsertMode (self.data.insertMode)
	self.ps:setOffset (unpack (self.data.offset))
	self.ps:setDirection (self.data.direction)
	self.ps:setSpread (self.data.spread)
	self.ps:setSpeed (unpack (self.data.speed))
	self.ps:setParticleLifetime (unpack (self.data.particleLifetime))
	self.ps:setRadialAcceleration (unpack (self.data.radialAcceleration))
	self.ps:setTangentialAcceleration (unpack (self.data.tangentialAcceleration))
	self.ps:setLinearDamping (unpack (self.data.linearDamping))
	self.ps:setLinearAcceleration (self.data.linearAcceleration.min [1], self.data.linearAcceleration.min [2], self.data.linearAcceleration.max [1], self.data.linearAcceleration.max [2])
	self.ps:setSpin (unpack (self.data.spin.interval))
	self.ps:setSpinVariation (self.data.spin.variation)
	self.ps:setRotation (unpack (self.data.rotation.interval))
	self.ps:setRelativeRotation (self.data.rotation.enable)
	self.ps:setPosition (unpack (self.data.drawing.position))
end

local function _UpdateBufferSize (self)
	self.ps:setBufferSize (self.data.bufferSize)
end

local function _UpdateEmitterLifetime (self)
	self.ps:setEmitterLifetime (self.data.emitterLifetime)
end

local function _UpdateMember (self, type)
	if (#self.data [type] > 0) then
		if (type == "colors") then
			self.ps:setColors (unpack (self.data.colors))
		elseif (type == "sizes") then
			self.ps:setSizes (unpack (self.data.sizes))
		elseif (type == "quads") then
			self.ps:setQuads (unpack (self.data.quads))
		end
	end
end

function _class:Ctor (name, data)
	self.ps = love.graphics.newParticleSystem (_canvas, 1)
	self.name = name
	self.data = _SetData (data)
	self.setting = {
		keepScale = false,
		drawOrigin = true
	}
	
	self.id = 0
	self.isPaused = false
	self.texture = {name = "...", width = 0, height = 0}
	
	self.data.drawing.position [1] = love.graphics.getWidth () * 0.5
	self.data.drawing.position [2] = love.graphics.getHeight () * 0.5
	
	_UpdateMany (self)
	_UpdateBufferSize (self)
	_UpdateEmitterLifetime (self)
	_UpdateMember (self, "colors")
	_UpdateMember (self, "sizes")
	_UpdateMember (self, "quads")
end

function _class:Update (dt)
	if (not self.isPaused) then
		self.ps:update (dt * self.data.playingSpeed)
	end
end

function _class:Draw ()
	local drawing = self.data.drawing
	love.graphics.setBlendMode (drawing.blendmode.normal, drawing.blendmode.alpha)
	love.graphics.setColor (drawing.color)
	love.graphics.draw (self.ps, 0, 0, drawing.orientation, drawing.scale [1], drawing.scale [2], drawing.origin [1], drawing.origin [2], drawing.shearing [1], drawing.shearing [2])
	
	if (self.setting.drawOrigin) then
		love.graphics.setBlendMode ("alpha")
		love.graphics.setColor (255, 255, 255, 255)
		love.graphics.circle ("line" , drawing.position [1] + drawing.origin [1], drawing.position [2] + drawing.origin [2], 5, 10)
	end
end

function _class:Clone ()
	local obj = _class.New (self.name .. "-", self.data)
	
	if (self.texture.image) then
		obj:SetImage (self.texture.image, self.texture.name)
	end
	
	return obj
end

function _class:ReturnToData ()
	local newData = _CopyTable (self.data)
	
	for n=1, #newData.quads do
		local x, y, w, h = newData.quads [n]:getViewport ()
		local sw, sh = newData.quads [n]:getTextureDimensions ()
		
		newData.quads [n] = {x, y, w, h, sw ,sh}
	end
	
	return newData
end

function _class:SetImage (image, name)
	self.texture.name = name
	self.texture.width = image:getWidth ()
	self.texture.height = image:getHeight ()
	self.texture.image = image
	self.ps:setTexture (image)
	
	for n=1, #self.data.quads do
		local sw, sh = self.data.quads [n]:getTextureDimensions ()
		
		if (sw ~= self.texture.width or sh == self.texture.height) then
			local x, y, w, h = self.data.quads [n]:getViewport ()
			self.data.quads [n] = love.graphics.newQuad (x, y, w, h, self.texture.width, self.texture.height)
		end
	end
end

function _class:GetCount ()
	return self.ps:getCount ()
end

function _class:OnEvent (type, ...)
	if (type == "updateMany") then
		_UpdateMany (self)
	elseif (type == "updateBufferSize") then
		_UpdateBufferSize (self)
	elseif (type == "updateEmitterLifetime") then
		_UpdateEmitterLifetime (self)
	elseif (type == "updateMember") then
		_UpdateMember (self, ...)
	elseif (type == "removeMember") then
		local param = {...} --dataName, id
		table.remove (self.data [param [1]], param [2])
	elseif (type == "addMember") then
		local param = {...} --dataName
		local listData = self.data [param [1]]
		
		if (param [1] == "colors") then
			listData [#listData + 1] = {255, 255, 255, 255}
		elseif (param [1] == "sizes") then
			listData [#listData + 1] = 1
		elseif (param [1] == "quads") then
			if (self.texture) then
				listData [#listData + 1] = love.graphics.newQuad (0, 0, self.texture.width, self.texture.height, self.texture.width, self.texture.height)
			else
				listData [#listData + 1] = love.graphics.newQuad (0, 0, 0, 0, 0, 0)
			end
		end
	elseif (type == "setQuad") then
		local param = {...} --quad, x, y, w, h
		local quad = param [1]
		local x = param [2]
		local y = param [3]
		local w = param [4]
		local h = param [5]
		local tw = self.texture.width
		local th = self.texture.height
		
		if (x > tw) then
			x = tw
		end
		
		if (x + w > tw) then
			w = tw - x
		end
		
		if (y > th) then
			y = th
		end
		
		if (y + h > th) then
			h = th - y
		end
		
		quad:setViewport (x, y, w, h)
	elseif (type == "reset") then
		if (not self.ps:isActive ()) then
			self.ps:start ()
		else
			self.ps:reset ()
		end
	elseif (type == "pause_resume") then
		self.isPaused = not self.isPaused
	elseif (type == "isPaused") then
		return self.isPaused
	elseif (type == "hasImage") then
		return self.texture.image ~= nil
	elseif (type == "getData") then
		return self.data
	elseif (type == "getSetting") then
		return self.setting
	elseif (type == "getTextureName") then
		return self.texture.name
	elseif (type == "getName") then
		return self.name
	elseif (type == "setName") then
		self.name = ...
		_class:RunEvent ("changeNameMember", self.id, self.name)
	elseif (type == "setPosition") then
		local param = {...} --x, y
		
		self.data.drawing.position [1] = param [1]
		self.data.drawing.position [2] = param [2]
	elseif (type == "centerOffset") then
		self.data.offset [1] = self.texture.width * 0.5
		self.data.offset [2] = self.texture.height * 0.5
	end
end

return _class