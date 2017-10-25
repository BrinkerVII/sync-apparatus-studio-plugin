local pushyModule = {}

local connectionManager = require(script.Parent.ConnectionManager)
local scriptCollector = require(script.Parent.ScriptCollector)
local fileSettings = require(script.Parent.FileSettings)
local generalAPI = require(script.Parent.GeneralAPI)
local fs = require(script.Parent.Filesystem)

function pushyModule:SetReferences(references)
	self.References = references
	
	self.References.Events.PushSelection.Event:Connect(function()
		local scripts = scriptCollector:CollectFromSelection()
		local events = {}
		
		local projectName = fileSettings:GetProjectName()
		if not generalAPI:ProjectExists(projectName) then
			if not generalAPI:CreateProject(projectName) then
				return warn("Aborted pushing files because project creation failed")
			end
		end
		
		for _, v in pairs(scripts) do			
			local event = {
				type = "file-push",
				clientToken = true,
				data = {
					path = fs:InstanceToPath(v) .. ".lua",
					contents = v.Source,
					project = projectName,
					encoding = "plain"
				}
			}
			
			table.insert(events, event)
		end
		
		local success, err = pcall(function()
			connectionManager:PostAsync("event", events)
		end)
		
		if not success then
			print("Failed to push file::\n", err)
		end
	end)
end

return pushyModule