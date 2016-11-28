local _class = require ("class") ("background", "editor", "sington")

function _class:Init ()
	--image
	self.name = "..."
	self.color = {100, 100, 100, 255}
	self.origin = {x = 0, y = 0}
	self.width = 0
	self.height = 0
end

function _class:Draw ()
	love.graphics.clear (self.color)
	
	if (self.image) then
		love.graphics.draw (self.image, love.graphics.getWidth () * 0.5, love.graphics.getHeight () * 0.5, 0, 1, 1, self.origin.x, self.origin.y)
	end
end

function _class:SetImage (image, name)
	self.image = image
	self.name = name
	self.origin.x = self.image:getWidth () * 0.5
	self.origin.y = self.image:getHeight () * 0.5
end

function _class:GetColor ()
	return self.color
end

function _class:GetName ()
	return self.name
end

return _class.New ()