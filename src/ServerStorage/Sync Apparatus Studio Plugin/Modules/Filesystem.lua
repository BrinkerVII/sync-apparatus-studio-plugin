local filesystem = {}

local PATH_SEPERATOR = "/"
local SOURCE_EXTENSION = ".lua"

local stringx = require(script.Parent.StringX)

function filesystem:InstanceToPath(instance)
	assert(typeof(instance) == "Instance", "Instance must be a ROBLOX instance")
	local pathComponents = {}
	
	while instance and instance ~= game do
		table.insert(pathComponents, instance.Name)
		instance = instance.Parent
	end
	
	local path = PATH_SEPERATOR
	for i = #pathComponents, 1, -1 do
		path = path .. pathComponents[i]
		
		if i > 1 then
			path = path .. PATH_SEPERATOR
		end
	end
	
	if instance:IsA("LuaSourceContainer") then
		path = path .. SOURCE_EXTENSION
	end
	
	return path
end

function filesystem:PathToInstance(path)
	assert(type(path) == "string", "Path must be a string")
	
	local splitPath = stringx:Split(path, "/")
	
	local instance = game
	for _, segment in pairs(splitPath) do
		local newInstance = instance:FindFirstChild(segment)
		if not newInstance then
			return false
		end
		
		instance = newInstance
	end
	
	return instance
end

function filesystem:Exists(path)
	assert(type(path) == "string", "Path must be a string")
	
	local instance = self:PathToInstance(path)
	if instance then return true; end
	
	return false
end

function filesystem:MkDirs(path)
	assert(type(path) == "string", "Path must be a string")
	
	local splitPath = stringx:Split(path, "/")
	local instance = game
	
	for _, segment in pairs(splitPath) do
		local newInstance = instance:FindFirstChild(segment)
		if not newInstance then
			newInstance = Instance.new("Folder")
			newInstance.Name = segment
			newInstance.Parent = instance
		end
		
		if not instance then
			error("Something happened...")
		end
		
		instance = newInstance
	end
	
	return instance
end

function filesystem:Touch(path)
	assert(type(path) == "string", "Path must be a string")
	
	local pathMatch = path:match("(.*)%.lua")
	if type(pathMatch) == "string" then
		if pathMatch == "" then
			return error("Path contained an empty filename", 2)
		end
		
		path = pathMatch
	end
	
	local instance = self:PathToInstance(path)
	if instance then
		if instance:IsA("LuaSourceContainer") then
			return instance
		end
	end
	
	local folder = self:MkDirs(path)
	if not folder then
		return error("Filesystem:: Failed to resolve path")
	end
	
	local file = Instance.new("ModuleScript")
	file.Name = folder.Name
	file.Parent = folder.Parent
	
	folder:Destroy()
	
	return file
end

return filesystem