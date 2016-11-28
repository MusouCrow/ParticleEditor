local _class = require ("class") ("object", "editor.objmgr")
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

local function _SetData (data)
	local newData = _class:RunEvent ("copyTable")
	
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
end

function _class:Ctor (name, data)
	self.ps = love.graphics.newParticleSystem (_canvas, 1)
	self.name = name
	self.data = _SetData (data)
	self.id = 0
	self.isPaused = false
	self.texture = {name = "", w = 0, h = 0}
	
	self.drawing.position [1] = love.graphics.getWidth () * 0.5
	self.drawing.position [2] = love.graphics.getHeight () * 0.5
end

function _class:Update (dt)
	if (not self.isPaused) then
		self.ps:update (dt)
	end
end

function _class:Draw ()
	local drawing = self.data.drawing
	love.graphics.setBlendMode (drawing.blendmode.normal, drawing.blendmode.alpha)
	love.graphics.setColor (drawing.color)
	love.graphics.draw (self.ps, drawing.position [1], drawing.position [2], drawing.orientation, drawing.scale [1], drawing.scale [2], drawing.origin [1], drawing.origin [2], drawing.shearing [1], drawing.shearing [2])
end

function _class:Clone ()
	local obj = _class.New (self.name .. "-", self.data)
	
	if (self.texture.image) then
		obj:SetImage (self.texture.image, self.texture.name)
	end
	
	return obj
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

function _class:RunEvent (type, ...)
	if (type == "update") then
		_CheckInterval (self.data.particleLifetime)
		_CheckInterval (self.data.speed)
		_CheckInterval (self.data.radialAcceleration)
		_CheckInterval (self.data.tangentialAcceleration)
		_CheckInterval (self.data.linearDamping)
		_CheckInterval (self.data.spin.interval)
		_CheckInterval (self.data.rotation.interval)
		_CheckDoubleInterval (self.data.linearAcceleration)
		
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
	elseif (type == "updateBufferSize") then
		self.ps:setBufferSize (self.data.bufferSize)
	elseif (type == "updateMember") then
		local param = {...} --dataName
		
		if (param [1] == "colors") then
			self.ps:setColors (unpack (self.data.colors))
		elseif (param [1] == "sizes") then
			self.ps:setSizes (unpack (self.data.sizes))
		elseif (param [1] == "quads") then
			self.ps:setQuads (unpack (self.data.quads))
		end
	elseif (type == "removeMember") then
		local param = {...} --dataName, id
		table.remove (self.data [param [1]], param [2])
		self:SetEvent (param [1])
	elseif (type == "addMember") then
		local param = {...} --dataName
		local listData = self.data [param [1]]
		
		if (type == "colors") then
			listData [#listData + 1] = {255, 255, 255, 255}
		elseif (type == "sizes") then
			listData [#listData + 1] = 1
		elseif (type == "quads") then
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
		self.ps:reset ()
	elseif (type == "pause") then
		self.isPaused = true
	elseif (type == "resume") then
		self.isPaused = false
	elseif (type == "hasImage") then
		return not self.texture.image
	end
end

return _class