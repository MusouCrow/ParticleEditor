local _editor = require ("src.editor")

function love.load ()
	_editor:Init ()
end

function love.update (dt)
	_editor:Update (dt)
end

function love.draw ()
	_editor:Draw ()
end

function love.quit ()
	_editor:Quit ()
end

function love.textinput (t)
	_editor:TextInput (t)
end

function love.keypressed (key)
    _editor:KeyPressed (key)
end

function love.keyreleased (key)
    _editor:KeyReleased (key)
end

function love.mousemoved (x, y)
    _editor:MouseMoved (x, y)
end

function love.mousepressed (x, y, button)
    _editor:MousePressed (x, y, button)
end

function love.mousereleased (x, y, button)
    _editor:MouseReleased (button)
end

function love.wheelmoved (x, y)
    _editor:WheelMoved (y)
end

function love.filedropped (file)
	_editor:Filedropped (file)
end