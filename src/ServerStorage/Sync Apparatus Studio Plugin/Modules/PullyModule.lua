local pullyModule = {}
print("PullyModule:: Start Init")

print("PullyModule:: Require ConnectionManager")
local connectionManager = require(script.Parent.ConnectionManager)
print("PullyModule:: Require Filesystem")
local fs = require(script.Parent.Filesystem)

print("PullyModule:: Define Functions")
function pullyModule:PullChanges(changes)
	assert(type(changes) == "table", "Changes must be of type table")
	
	for _, change in pairs(changes) do
		local endpoint = "post-office/$clientToken/" .. change.uuid;
		
		local response;
		local success, err = pcall(function()
			response = connectionManager:GetAsync(endpoint)
		end)
		
		if success and response then
			self:ProcessResponse(response, change.uuid)
		else
			warn("Failed to retrieve change")
			if err then
				warn(err)
				warn(debug.traceback())
			else
				if not response then
					warn("Got no response")
				end
			end
		end
	end
end

function pullyModule:ProcessResponse(response, changeId)
	assert(type(changeId) == "string", "changeId must be of type string")	
	if not response.path then
		return warn("Invalid response")
	end
	
	local function deleteChange()
		self:DeleteChange(changeId)
	end
	
	if response.type == "add" or response.type == "update" then
		local file = fs:Touch(response.path)
		if file then
			deleteChange()
			file.Source = response.file
		else
			warn(("Did not get a file from the Filesystem module for path '%s'"):format(response.path))
		end
	elseif response.type == "delete" then			
		local file = fs:PathToInstance(response.path)
		if file then
			file:Destroy()
		else
			warn(("PullyModule:: Could not find instance for path '%s' while deleting"):format(response.path))
		end
		
		deleteChange()
	elseif response.type == "none" then
		warn(("PullyModule:: Daemon sent a NOP change (%s)"):format(response.path))
		deleteChange()
	end
end

function pullyModule:DeleteChange(changeId)
	assert(type(changeId) == "string", "ChangeId must be of type string")
	
	local endpoint = "post-office/$clientToken/" .. changeId
	
	local success, err = pcall(function()
		connectionManager:DeleteAsync(endpoint)
	end)
	
	if not success then
		warn("Failed to remove change from daemon")
		warn(err)
		warn(debug.traceback())
	end
end

print("PullyModule:: End Init")
return pullyModule