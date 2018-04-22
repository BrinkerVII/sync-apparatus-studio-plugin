local scriptCollector = {}

local selection = game:GetService("Selection")
local coreGui = game:GetService("CoreGui")

function scriptCollector:CollectAll()
	return self:CollectFrom(game)
end

function scriptCollector:CollectFrom(instance)
	assert(typeof(instance) == "Instance", "Instance must be of type Instance")
	
	local scripts = {}
	
	if instance:IsA("LuaSourceContainer") then
		table.insert(scripts, instance)
	end
	
	for _, v in pairs(instance:GetDescendants()) do
		local include = false
		
		pcall(function()
			include = v:IsA("LuaSourceContainer") and not v:IsDescendantOf(coreGui)
		end)
		
		if include then
			table.insert(scripts, v)
		end
	end
	
	return scripts
end

function scriptCollector:CollectFromSelection()
	local scripts = {}
	
	for _, v in pairs(selection:Get()) do
		for _, y in pairs(self:CollectFrom(v)) do
			table.insert(scripts, y)
		end
	end
	
	return scripts
end

return scriptCollector