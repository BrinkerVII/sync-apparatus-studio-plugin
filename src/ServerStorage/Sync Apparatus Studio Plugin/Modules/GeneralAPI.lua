local generalAPI = {}

local connectionManager = require(script.Parent.ConnectionManager)

function generalAPI:GetProjects()
	local projectList = {}
	
	local success, err = pcall(function()
		projectList = connectionManager:GetAsync("project")
	end)
	
	if not success then
		warn("Failed to fetch project list")
		warn(debug.traceback())
	end
	
	return projectList
end

function generalAPI:ProjectExists(projectName)
	assert(type(projectName) == "string", "projectName must be a string")
	print("Checking if project exists")
	
	for _, v in pairs(self:GetProjects()) do
		print(v, projectName, v == projectName)
		if v == projectName then
			return true
		end
	end
	
	return false
end

function generalAPI:CreateProject(projectName)
	local body = {
		name = projectName,
		clientToken = true
	}
	
	local success, err = pcall(function()
		connectionManager:PostAsync("project", body)
	end)
	
	if not success then
		warn("Failed to create project")
		warn(debug.traceback())
		return false
	end
	
	return true
end

function generalAPI:GetChanges(projectName)
	assert(type(projectName) == "string", "projectName must be a string")
	
	local endpoint = ("changes/$clientToken/%s"):format(projectName)
	
	local changes;
	local success, err = pcall(function()
		changes = connectionManager:GetAsync(endpoint)
	end)
	
	if not success then
		warn("Failed to fetch changes")
		warn(debug.traceback())
		return {}
	end
	
	if not changes then
		warn("Did not get any changes")
		return {}
	end
	
	return changes
end

return generalAPI