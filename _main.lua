local _interface = require ("module.interface")
local _utility = require ("module.utility")
local _data = require ("module.data")
local _display = require ("module.display")

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

function love.load ()
	_utility:Init (require ("cjson"))
	_data:Init (_utility)
	_display:Init (_data)
	
	local text = _utility:OpenJson ("text/en.json")
	_HandleText (text)
	
	_interface:Init (require ("imgui"), text, _data)
end

function love.update (dt)
	_data:Update ()
	_display:Update (dt)
	_interface:Update ()
end

function love.draw ()
	_display:Draw ()
	_interface:Draw ()
end

function love.quit ()
	_interface:Quit ()
end

function love.textinput (t)
	_interface:TextInput (t)
end

function love.keypressed (key)
    _interface:KeyPressed (key)
end

function love.keyreleased (key)
    _interface:KeyReleased (key)
end

function love.mousemoved (x, y)
    _interface:MouseMoved (x, y)
end

function love.mousepressed (x, y, button)
    _interface:MousePressed (button)
end

function love.mousereleased (x, y, button)
    _interface:MouseReleased (button)
end

function love.wheelmoved (x, y)
    _interface:WheelMoved (y)
end

function love.filedropped (file)
	_interface:Filedropped (file)
end