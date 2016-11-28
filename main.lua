local _editor = require ("editor")

function love.load ()
	_editor:Init ()
end

function love.update (dt)
	_editor:Update (dt)
end

function love.draw ()
	_editor:Draw ()
end