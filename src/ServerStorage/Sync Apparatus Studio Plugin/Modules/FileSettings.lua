local fileSettings = {}

local FOLDER_NAME = "Sync Apparatus Settings"

local TYPE_REF = {
	string = "StringValue",
	Instance = "ObjectValue",
	number = "NumberValue",
	["nil"] = "ObjectValue"
}

function fileSettings:GetSettingsFolder()
	local folder = game:FindFirstChild(FOLDER_NAME)
	if not folder then
		folder = Instance.new("Configuration")
		folder.Name = FOLDER_NAME
		folder.Parent = game
	end
	
	return folder
end

function fileSettings:Get(key, default)
	local folder = self:GetSettingsFolder()
	local value = folder:FindFirstChild(key)
	local vvalue = default
	
	if value then
		vvalue = value.Value
	else
		value = Instance.new(TYPE_REF[typeof(default)])
		value.Name = key
		value.Value = vvalue
		value.Parent = folder
	end
	
	return vvalue
end

function fileSettings:Set(key, value)
	self:Get(key, value)
	
	local folder = self:GetSettingsFolder()
	local v = folder:FindFirstChild(key)
	if v then
		v.Value = value
	end
end

function fileSettings:HasKey(key)
	local folder = self:GetSettingsFolder()
	return folder:FindFirstChild(key) ~= nil
end

function fileSettings:GetProjectName()
	return self:Get("ProjectName", "testproject")
end

return fileSettings