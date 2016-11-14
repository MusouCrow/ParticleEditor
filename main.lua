local _imgui = require ("imgui")
local _maxCount = 2147483647

local function _HoveredTooltip (text)
	if (_imgui.IsItemHovered ()) then
		_imgui.SetTooltip (text)
	end
end

function love.load ()
	love.graphics.setBackgroundColor (100, 100, 100, 255)
end

function love.update (dt)
	_imgui.NewFrame ()
end

function love.draw ()
	local count = 0
	local count2 = {0, 0}
	local combo = 1
	local check = false
	local list = {"a", "b"}
	
	_imgui.SetNextWindowPos (love.graphics.getWidth () - 340, 0)
	_imgui.SetNextWindowSize (340, love.graphics.getHeight ())
	_imgui.Begin ("Inspector", true, {"NoResize", "NoMove"})
		if (_imgui.CollapsingHeader ("Necessity")) then
			_imgui.Text ("Texture")
			_HoveredTooltip ("Sets the texture (Image or Canvas) to be used for the particles.")
			_imgui.Button ("Open a photo file")
			_imgui.SameLine ()
			_imgui.Text ("Texture's path")
			_imgui.Spacing ()
			
			_imgui.Text ("Buffer Size")
			_HoveredTooltip ("Sets the size of the buffer (the max allowed amount of particles in the system).")
			_imgui.DragInt ("size", count, 1, 0, _maxCount)
			_HoveredTooltip ("The buffer size.")
			_imgui.Spacing ()
			
			_imgui.Text ("Emission Lifetime")
			_HoveredTooltip ("Sets how long the particle system should emit particles (if -1 then it emits particles forever).")
			_imgui.DragFloat ("life", count, 0.1, -1, _maxCount)
			_HoveredTooltip ("The lifetime of the emitter (in seconds).")
			_imgui.Spacing ()
			
			_imgui.Text ("Emission Rate")
			_HoveredTooltip ("Sets the amount of particles emitted per second.")
			_imgui.DragFloat ("rate", count, 0.1, 0, _maxCount)
			_HoveredTooltip ("The amount of particles per second.")
			_imgui.Spacing ()
		end
		
		if (_imgui.CollapsingHeader ("Outward")) then
			_imgui.Text ("Area Spread")
			_HoveredTooltip ("Sets area-based spawn parameters for the particles. Newly created particles will spawn in an area around the emitter based on the parameters to this function.")
			_imgui.Combo ("distribution", combo, "uniform\0normal\0ellipse\0none\0")
			_HoveredTooltip ("The type of distribution for new particles.")
			_imgui.DragFloat2 ("dx, dy", count, count)
			_HoveredTooltip ("The maximum spawn distance from the emitter along the x(y)-axis for uniform distribution, or the standard deviation along the x(y)-axis for normal distribution.")
			_imgui.Spacing ()
			
			_imgui.Text ("Insert Mode")
			_HoveredTooltip ("Sets the mode to use when the ParticleSystem adds new particles.")
			_imgui.Combo ("mode", combo, "top\0bottom\0random\0")
			_HoveredTooltip ("The mode to use when the ParticleSystem adds new particles.")
			_imgui.Spacing ()
			
			_imgui.Text ("Offset")
			_HoveredTooltip ("Set the offset position which the particle sprite is rotated around.\nIf this function is not used, the particles rotate around their center.")
			_imgui.DragInt2 ("x, y", count, count)
			_HoveredTooltip ("The x(y) coordinate of the rotation offset.")
			_imgui.Spacing ()
			
			_imgui.Text ("Direction")
			_HoveredTooltip ("Sets the direction the particles will be emitted in.")
			_imgui.DragFloat ("direction", count)
			_HoveredTooltip ("The direction of the particles (in radians).")
			_imgui.Spacing ()
			
			_imgui.Text ("Spread")
			_HoveredTooltip ("Sets the amount of spread for the system.")
			_imgui.DragFloat ("spread", count)
			_HoveredTooltip ("The amount of spread (radians).")
			_imgui.Spacing ()
			
			if (_imgui.TreeNode ("Quads")) then
				_HoveredTooltip ("Sets a series of Quads to use for the particle sprites.\nParticles will choose a Quad from the list based on the particle's current lifetime,\nallowing for the use of animated sprite sheets with ParticleSystems.")
				_imgui.SameLine ()
				_imgui.SmallButton ("Add")
				
				for n=1, 2 do
					if (_imgui.TreeNode (n)) then
						_imgui.SameLine ()
						_imgui.SmallButton ("Remove")
						
						_imgui.DragInt3 ("x, w, sw", count, count, count, 1, 0, _maxCount)
						_HoveredTooltip ("x: The top-left position in the Image along the x-axis.\nw: The width of the Quad in the Image. (Must be greater than 0.)\nsw: The reference width, the width of the Image. (Must be greater than 0.)")
						_imgui.DragInt3 ("y, h, sy", count, count, count, 1, 0, _maxCount)
						_HoveredTooltip ("y: The top-left position in the Image along the y-axis.\nh: The height of the Quad in the Image. (Must be greater than 0.)\nsh: The reference height, the height of the Image. (Must be greater than 0.)")
						_imgui.TreePop ()
					end
				end
				
				_imgui.TreePop ()
			end
			_imgui.Spacing ()
		end
		
		if (_imgui.CollapsingHeader ("Motion")) then
			_imgui.Text ("Speed")
			_HoveredTooltip ("Sets the speed of the particles.")
			_imgui.DragFloat2 ("min, max", count, count)
			_HoveredTooltip ("The minimum(maximum) linear speed of the particles.")
			_imgui.Spacing ()
			
			_imgui.Text ("Particle Lifetime")
			_HoveredTooltip ("Sets the lifetime of the particles.")
			_imgui.DragFloat2 ("min, max", count, count)
			_HoveredTooltip ("The minimum(maximum) life of the particles (in seconds).")
			_imgui.Spacing ()
			
			_imgui.Text ("Radial Acceleration")
			_HoveredTooltip ("Set the radial acceleration (away from the emitter).")
			_imgui.DragFloat2 ("min, max", count, count)
			_HoveredTooltip ("The minimum(maximum) acceleration.")
			_imgui.Spacing ()
			
			_imgui.Text ("Tangential Acceleration")
			_HoveredTooltip ("Sets the tangential acceleration (acceleration perpendicular to the particle's direction).")
			_imgui.DragFloat2 ("min, max", count, count)
			_HoveredTooltip ("The minimum(maximum) acceleration.")
			_imgui.Spacing ()
			
			_imgui.Text ("Linear Damping")
			_HoveredTooltip ("Sets the amount of linear damping (constant deceleration) for particles.")
			_imgui.DragFloat2 ("min, max", count, count)
			_HoveredTooltip ("The minimum(maximum) amount of linear damping applied to particles.")
			_imgui.Spacing ()
			
			_imgui.Text ("Linear Acceleration")
			_HoveredTooltip ("Sets the linear acceleration (acceleration along the x and y axes) for particles.\nEvery particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax.")
			_imgui.DragFloat2 ("xmin, ymin", count, count)
			_HoveredTooltip ("The minimum acceleration along the x(y) axis.")
			_imgui.DragFloat2 ("xmax, ymax", count, count)
			_HoveredTooltip ("The maximum acceleration along the x(y) axis.")
			_imgui.Spacing ()
			
			_imgui.Text ("Spin")
			_HoveredTooltip ("Sets the spin of the sprite.")
			_imgui.DragFloat2 ("min, max", count, count)
			_HoveredTooltip ("The minimum(maximum) spin (radians per second).")
			_imgui.DragFloat ("variation", count, 0.1, 0, 1)
			_HoveredTooltip ("The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).")
			_imgui.Spacing ()
			
			_imgui.Text ("Rotation")
			_HoveredTooltip ("Sets the rotation of the image upon particle creation (in radians).")
			_imgui.SameLine ()
			_imgui.Checkbox ("enable", check)
			_HoveredTooltip ("True to enable relative particle rotation, false to disable it.")
			_imgui.DragFloat2 ("min, max", count, count)
			_HoveredTooltip ("The minimum(maximum) initial angle (radians).")
			_imgui.Spacing ()
			
			if (_imgui.TreeNode ("Colors")) then
				_HoveredTooltip ("Sets a series of colors to apply to the particle sprite.\nThe particle system will interpolate between each color evenly over the particle's lifetime.")
				_imgui.SameLine ()
				_imgui.SmallButton ("Add")
				
				for n=1, 2 do
					_imgui.ColorEdit4 ("", 1, 0, 0, 1)
					_imgui.SameLine ()
					_imgui.SmallButton ("Remove")
				end
				
				_imgui.TreePop ()
			end
			_imgui.Spacing ()
			
			if (_imgui.TreeNode ("Sizes")) then
				_HoveredTooltip ("Sets a series of sizes by which to scale a particle sprite. 1.0 is normal size.\nThe particle system will interpolate between each size evenly over the particle's lifetime.")
				_imgui.SameLine ()
				_imgui.SmallButton ("Add")
				
				for n=1, 2 do
					_imgui.DragFloat ("", count)
					_imgui.SameLine ()
					_imgui.SmallButton ("Remove")
				end
				_imgui.Separator ()
				
				_imgui.DragFloat ("variation", count, 0.1, 0, 1)
				_imgui.TreePop ()
			end
			_imgui.Spacing ()
		end
	_imgui.End ()
	
	_imgui.SetNextWindowPos (0, 0)
	_imgui.SetNextWindowSize (340, love.graphics.getHeight ())
	_imgui.Begin ("Synthesis", true, {"NoResize", "NoMove"})
		if (_imgui.CollapsingHeader ("Hierarchy")) then
			_imgui.Text ("Operation")
			_imgui.Separator ()
				_imgui.Text ("Addition")
				_imgui.Button ("New")
				_imgui.SameLine ()
				_imgui.Button ("Open")
				_imgui.SameLine ()
				_imgui.Button ("Clone")
				_imgui.Spacing ()
				
				_imgui.Text ("Animation")
				_imgui.Button ("Reset")
				_imgui.SameLine ()
				_imgui.Button ("Pause")
				_imgui.Spacing ()
				
				_imgui.Text ("Order")
				_imgui.Button ("Up")
				_imgui.SameLine ()
				_imgui.Button ("Down")
				_imgui.Spacing ()
				
				_imgui.Text ("Other")
				_imgui.Button ("Save")
				_imgui.SameLine ()
				_imgui.Button ("Remove")
				_imgui.Spacing ()
			_imgui.Separator ()
			
			_imgui.Text ("List")
			_imgui.PushItemWidth (327)
			_imgui.ListBox ("", count, list, #list, #list)
			_imgui.Spacing ()
		end
		
		if (_imgui.CollapsingHeader ("Opinions")) then
			_imgui.Text ("Background Image")
			_imgui.Button ("Open a photo file")
			_imgui.SameLine ()
			_imgui.Text ("Background Image's path")
			_imgui.Spacing ()
			
			_imgui.Text ("Debugger Switch")
			_imgui.Checkbox ("Show FPS", check)
			_imgui.Checkbox ("Show tips", check)
			_imgui.Spacing ()
		end
		
		if (_imgui.CollapsingHeader ("Help")) then
			_imgui.Text ("About Editor")
			_imgui.TextWrapped ("  This is a editor of particle for LÖVE. It be entrusted on the Coding.net. (https://git.coding.net/musoucrow/ParticleEditor.git)")
			_imgui.TextWrapped ("  It is licensed under the MIT License, see LICENSE for more information.")
			_imgui.Separator ()
			
			_imgui.Text ("How to use?")
			_imgui.TextWrapped ("  In ParticleEditor, you can make some Particle File to give your project to use.")
			_imgui.TextWrapped ("  The Particle File's format is JSON, so you need to use the library of CJSON in your project.(Already be included in the lib folder)")
			_imgui.TextWrapped ("  You can use the specially function in the make.lua to load Particle File and then to create Particle System object.")
			_imgui.TextWrapped ("  The Particle File doesn't have Texture data, so you need to prepare yourself.")
			_imgui.TextWrapped ("  Lastly, you need to see the README.md to learn more.")
			_imgui.Spacing ()
		end
	_imgui.End ()
	
	--imgui.ShowTestWindow(true)
	
	_imgui.Render ()
end

function love.quit ()
	_imgui.ShutDown ()
end

function love.textinput (t)
	_imgui.TextInput (t)
end

function love.keypressed(key)
    _imgui.KeyPressed (key)
end

function love.keyreleased(key)
    _imgui.KeyReleased (key)
end

function love.mousemoved(x, y)
    _imgui.MouseMoved (x, y)
end

function love.mousepressed(x, y, button)
    _imgui.MousePressed (button)
end

function love.mousereleased(x, y, button)
    _imgui.MouseReleased (button)
end

function love.wheelmoved(x, y)
    _imgui.WheelMoved (y)
end
