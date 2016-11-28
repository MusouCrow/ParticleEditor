local _class = require ("class") ("background", "editor", "sington")

function _class:Ctor ()
	--image
	self.name = "..."
	self.color = {100, 100, 100, 255}
	self.position = {x = love.graphics.getWidth () * 0.5, y = love.graphics.getHeight () * 0.5}
	self.origin = {x = 0, y = 0}
	self.width = 0
	self.height = 0
end

function _class:Draw ()
	love.graphics.clear (self.color)
	
	if (self.image) then
		love.graphics.draw (self.image, self.position.x, self.position.y, 0, 1, 1, self.origin.x, self.origin.y)
	end
end

function _class:SetImage (image, name)
	self.image = image
	self.name = name
end

return _class.New ()