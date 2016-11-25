local _module = {}

function _module:Init (data)
	self.data = data
end

function _module:Update (dt)
	local data = self.data:GetSelection ()
	
	if (data) then
		local psi = data.psi
		
		--psi:setEmitterLifetime (data.emissionLifetime)
		
		if (self.data.msg.bufferSize) then
			psi:setBufferSize (data.bufferSize)
		end
		
		psi:setEmissionRate (data.emissionRate)
		psi:setAreaSpread (data.areaSpread.distribution, unpack (data.areaSpread.distance))
		psi:setInsertMode (data.insertMode)
		psi:setOffset (unpack (data.offset))
		psi:setDirection (data.direction)
		psi:setSpread (data.spread)
		psi:setSpeed (unpack (data.speed))
		psi:setParticleLifetime (unpack (data.particleLifetime))
		psi:setRadialAcceleration (unpack (data.radialAcceleration))
		psi:setTangentialAcceleration (unpack (data.tangentialAcceleration))
		psi:setLinearDamping (unpack (data.linearDamping))
		psi:setLinearAcceleration (data.linearAcceleration.min [1], data.linearAcceleration.min [2], data.linearAcceleration.max [1], data.linearAcceleration.max [2])
		psi:setSpin (unpack (data.spin.interval))
		psi:setSpinVariation (data.spin.variation)
		psi:setRotation (unpack (data.rotation.interval))
		psi:setRelativeRotation (data.rotation.enable)
		
		if (self.data.msg.quads) then
			psi:setQuads (unpack (data.quads))
		end
		
		if (self.data.msg.colors) then
			psi:setColors (unpack (data.colors))
		end
		
		if (self.data.msg.sizes) then
			psi:setSizes (unpack (data.sizes))
		end
	end
	
	for n=1, #self.data.list do
		self.data.list [n].psi:update (dt)
	end
end

function _module:Draw ()
	local background = self.data.background
	
	love.graphics.clear (background.color)
	
	if (background.image) then
		love.graphics.draw (background.image, love.graphics.getWidth () * 0.5, love.graphics.getHeight () * 0.5, 0, 1, 1, background.width * 0.5, background.height * 0.5)
	end
	
	for n=1, #self.data.list do
		local drawing = self.data.list [n].drawing
		love.graphics.setBlendMode (drawing.blendmode.normal, drawing.blendmode.alpha)
		love.graphics.setColor (drawing.color)
		love.graphics.draw (self.data.list [n].psi, drawing.position [1], drawing.position [2], drawing.orientation, drawing.scale [1], drawing.scale [2], drawing.origin [1], drawing.origin [2], drawing.shearing [1], drawing.shearing [2])
	end
	
	love.graphics.setColor (255, 255, 255, 255)
	love.graphics.setBlendMode ("alpha")
end

return _module