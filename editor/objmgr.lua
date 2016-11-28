local _class = require ("class") ("objmgr", "editor", "sington")

function _class:Init (templateData)
	--self.selectedObject
	self.templateData = templateData
	self.objectClass = require ("editor.objmgr.object")
	self.objectList = {}
	self.nameList = {}
	self.createCount = 0
	
	self:InheritEvent ("copyTable")
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

function _class:RefreshList ()
	_class:RunEvent ("clearTable", self.nameList)
	
	for n=1, #self.objectList do
		self.nameList [n] = self.objectList [n].name
		self.objectList [n].id = n
	end
end

function _class:CreateNewObject (data)
	data = data or self.templateData
	self.createCount = self.createCount + 1
	
	local obj = self.objectClass.New (tostring (self.createCount), data)
	self.objectList [#self.objectList + 1] = obj
	self.selectedObject = obj
	
	self:RefreshList ()
end

function _class:CloneObject (object)
	object = object or self.selectedObject
	
	local cloneObj = object:Clone ()
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
			self.selectedObject = self.objectList [id]
		else
			self.selectedObject = nil
		end
	end
	
	self:RefreshList ()
end

function _class:OrderObject (object, direction)
	object = object or self.selectedObject
	local changeSelection = self.selectedObject == object
	local id = object.id
	local pass = (direction > 0 and id > direction) or (direction < 0 and id <= #self.objectList + direction)
	
	if (pass) then
		local tmp = object
		self.objectList [id] = self.objectList [id + direction]
		self.objectList [id + direction] = tmp
		
		if (changeSelection) then
			self.selectedObject = self.objectList [id + direction]
		end
		
		self:RefreshList ()
	end
end

function _class:SetImage (image, name, object)
	object = object or self.selectedObject
	object:SetImage (image, name)
end

return _class.New ()