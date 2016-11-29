local _class = require ("src.class") ("objmgr", "src.editor", "src.sington")

local function _ClearTable (tab)
	for k in pairs (tab) do
		tab [k] = nil
	end
end

function _class:Init (templateData)
	--self.selectedObject
	self.templateData = templateData
	self.objectClass = require ("src.editor.objmgr.object")
	self.objectList = {}
	self.nameList = {}
	self.createCount = 0

	self:AddEvent ("changeNameMember", self, self.ChangeNameMember)
end

function _class:Update (dt)
	for n=1, #self.objectList do
		self.objectList [n]:Update (dt)
	end
end

function _class:Draw ()
	for n=1, #self.objectList do
		self.objectList [n]:Draw ()
	end
	
	love.graphics.setColor (255, 255, 255, 255)
	love.graphics.setBlendMode ("alpha")
end

function _class:SetSelection (id)
	if (id) then
		self.selectedObject = self.objectList [id]
	else
		self.selectedObject = nil
	end
end

function _class:ChangeNameMember (id, name)
	self.nameList [id] = name
end

function _class:RefreshList ()
	_ClearTable (self.nameList)
	
	for n=1, #self.objectList do
		self.nameList [n] = self.objectList [n].name
		self.objectList [n].id = n
	end
end

function _class:CreateObject (data, name)
	data = data or self.templateData
	
	if (name == nil) then
		self.createCount = self.createCount + 1
		name = tostring (self.createCount)
	end
	
	local obj = self.objectClass.New (name, data)
	self.objectList [#self.objectList + 1] = obj
	self.selectedObject = obj
	
	self:RefreshList ()
end

function _class:CloneObject (object)
	object = object or self.selectedObject
	
	local cloneObj = object:Clone ()
	self.objectList [#self.objectList + 1] = cloneObj
	self.selectedObject = cloneObj
	
	self:RefreshList ()
end

function _class:RemoveObject (object)
	object = object or self.selectedObject
	local changeSelection = self.selectedObject == object
	
	local id = object.id
	table.remove (self.objectList, id)
	
	if (changeSelection) then
		if (self.objectList [id]) then
			self:SetSelection (id)
		elseif (#self.objectList > 0) then
			self:SetSelection (#self.objectList)
		else
			self:SetSelection ()
		end
	end
	
	self:RefreshList ()
end

function _class:OrderObject (direction, object)
	object = object or self.selectedObject
	local changeSelection = self.selectedObject == object
	local id = object.id
	local pass = (direction < 0 and id > -direction) or (direction > 0 and id <= #self.objectList - direction)
	
	if (pass) then
		local tmp = object
		self.objectList [id] = self.objectList [id + direction]
		self.objectList [id + direction] = tmp
		
		if (changeSelection) then
			self:SetSelection (id + direction)
		end
		
		self:RefreshList ()
	end
end

function _class:SaveObject (object)
	object = object or self.selectedObject
	local path = "output/" .. object.name .. ".json"
	_class:RunEvent ("saveJson", path, object:ReturnToData ())
	
	return path
end

function _class:SetImage (image, name, object)
	object = object or self.selectedObject
	object:SetImage (image, name)
end

function _class:RunSelectedObjectEvent (...)
	if (self.selectedObject) then
		return self.selectedObject:OnEvent (...)
	end
end

function _class:GetListAbout ()
	local id = 0
	
	if (self.selectedObject) then
		id = self.selectedObject.id
	end
	
	return id, self.nameList
end

function _class:GetLiveCount ()
	local count = 0
	
	for n=1, #self.objectList do
		count = count + self.objectList [n]:GetCount ()
	end
	
	return count
end

return _class.New ()