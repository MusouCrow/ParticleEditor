local _module = {}
local _canvas = love.graphics.newCanvas ()

local function _RefreshNameList (self)
	self.utility:ClearTable (self.nameList)
	
	for n=1, #self.list do
		self.nameList [n] = self.list [n].name
	end
end

function _module:Init (utility)
	self.utility = utility
	self.list = {}
	self.nameList = {}
	self.selectionID = 0
	self.newCount = 0
	self.temple = self.utility:OpenJson ("data.json")
	self.background = {
		fileName = "...",
		color = {100, 100, 100, 255}
	}
	
	self.removeDataMember = {
		type = "",
		list = {
			colors = {},
			sizes = {},
			quads = {}
		}
	}
	
	self.msg = {
		bufferSize = false,
		colors = false,
		sizes = false,
		quads = false
	}
	
	--self:New ()
	--self.selectionID = 1
end

function _module:Update ()
	if (self.removeDataMember.type ~= "") then
		local type = self.removeDataMember.type
		local member = self:GetSelection () [type]
		local list = self.removeDataMember.list [type]
		
		for n=#list, 1, -1 do
			table.remove (member, list [n])
		end
		
		self.utility:ClearTable (list)
		self.msg [type] = true
		self.removeDataMember.type = ""
	end
end

function _module:GetSelection ()
	return self.list [self.selectionID]
end

function _module:New ()
	local new = self.utility:CopyTable (self.temple)
	self.newCount = self.newCount + 1
	
	new.psi = love.graphics.newParticleSystem (_canvas, 1)
	new.name = "Psi" .. self.newCount
	new.drawing.position [1] = love.graphics.getWidth () * 0.5
	new.drawing.position [2] = love.graphics.getHeight () * 0.5
	new.isPaused = false
	
	self.list [#self.list + 1] = new
	_RefreshNameList (self)
	self.selectionID = #self.list
end

function _module:Clone ()
	local clone = self.utility:CopyTable (self.list [self.selectionID])
	clone.name = clone.name .. " -Clone"
	self.list [#self.list + 1] = clone
	
	_RefreshNameList (self)
	self.selectionID = #self.list
end

function _module:Remove ()
	table.remove (self.list, self.selectionID)
	_RefreshNameList (self)
	
	if (self.selectionID > #self.list or self.selectionID < #self.list) then
		self.selectionID = #self.list
	end
end

function _module:OrderUp ()
	if (self.selectionID > 1) then
		local selection = self.list [self.selectionID]
		self.list [self.selectionID] = self.list [self.selectionID - 1]
		self.list [self.selectionID - 1] = selection
		self.selectionID = self.selectionID - 1
		_RefreshNameList (self)
	end
end

function _module:OrderDown ()
	if (self.selectionID < #self.list) then
		local selection = self.list [self.selectionID]
		self.list [self.selectionID] = self.list [self.selectionID + 1]
		self.list [self.selectionID + 1] = selection
		self.selectionID = self.selectionID + 1
		_RefreshNameList (self)
	end
end

function _module:Save ()
	
end

function _module:Open ()
	
end

function _module:SetImage (file, type)
	local contents = file:read ()
	local fileName = file:getFilename ()
	local fileData = love.filesystem.newFileData (contents, fileName)
	local imageData = love.image.newImageData (fileData)
	local image = love.graphics.newImage (imageData)
	local strList = self.utility:CutString (fileName, "/")
	local name = strList [#strList]
	
	if (type == "texture") then
		local data = self:GetSelection ()
		data.psi:setTexture (image)
		data.texture = {
			name = name,
			width = image:getWidth (),
			height = image:getHeight ()
		}
		
		for n=1, #data.quads do
			local x, y, w, h = data.quads [n]:getViewport ()
			data.quads [n] = love.graphics.newQuad (x, y, w, h, data.texture.width, data.texture.height)
		end
	elseif (type == "background") then
		self.background.image = image
		self.background.width = image:getWidth ()
		self.background.height = image:getHeight ()
		self.background.fileName = name
	end
end

function _module:AddDataMember (type)
	local data = self:GetSelection ()
	local list = data [type]
	
	if (type == "colors") then
		list [#list + 1] = {255, 255, 255, 255}
	elseif (type == "sizes") then
		list [#list + 1] = 1
	elseif (type == "quads") then
		if (data.texture) then
			list [#list + 1] = love.graphics.newQuad (0, 0, data.texture.width, data.texture.height, data.texture.width, data.texture.height)
		else
			list [#list + 1] = love.graphics.newQuad (0, 0, 0, 0, 0, 0)
		end
	end
end

function _module:RemoveDataMember (type, id)
	table.insert (self.removeDataMember.list [type], id)
	self.removeDataMember.type = type
end

function _module:SetQuad (quad, x, y, w, h)
	local data = self:GetSelection ()
	local width = data.texture.width
	local height = data.texture.height
	
	if (x > width) then
		x = width
	end
	
	if (x + w > width) then
		w = width - x
	end
	
	if (y > height) then
		y = height
	end
	
	if (y + h > height) then
		h = height - y
	end
	
	quad:setViewport (x, y, w, h)
end

function _module:CheckInterval (data)
	if (data [2] < data [1]) then
		data [2] = data [1]
	end
end

function _module:CheckDoubleInterval (data)
	for n=1, #data.max do
		if (data.max [n] < data.min [n]) then
			data.max [n] = data.min [n]
		end
	end
end

function _module:RunPsiEvent (name, ...)
	local psi = self:GetSelection ().psi
	
	return psi [name] (psi, ...)
end

return _module