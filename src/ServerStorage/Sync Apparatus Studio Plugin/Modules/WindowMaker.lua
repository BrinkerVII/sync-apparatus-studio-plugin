local BOOLEAN_HANDLES_ENABLED = false

local coreGui = game:GetService("CoreGui")
local windowMaker = {
	Windows = {},
	SaveState = {},
}

function windowMaker:MakeWindow(clientName)
	if not self.References then
		error("References not set")
	end
	
	local client = self.References.Resources:FindFirstChild(clientName)
	if not client then
		error(("Client not found: '%s'"):format(clientName))
	end
	
	local window = self.References.Resources.Window:Clone()
	local newClient = client:Clone()
	newClient.Parent = window:WaitForChild("Titlebar"):WaitForChild("Frame"):WaitForChild("ClientArea")
	
	if BOOLEAN_HANDLES_ENABLED then
		local handle = Instance.new("BoolValue")
		handle.Name = clientName
		handle.Parent = game:GetService("Lighting")
		
		handle.Changed:Connect(function()
			if handle.Value then
				window.Parent = game:GetService("StarterGui")
			else
				window.Parent = game:GetService("CoreGui")
			end
		end)
	end
	
	window.Name = ("WindowMaker '%s'"):format(clientName)
	if coreGui:FindFirstChild(window.Name) then
		repeat
			coreGui:FindFirstChild(window.Name):Destroy()
		until not coreGui:FindFirstChild(window.Name)
	end
	
	window.Parent = coreGui
	
	local clientModules = newClient:FindFirstChild("Modules")
	if clientModules then
		local init = clientModules:FindFirstChild("Init")
		if init:IsA("ModuleScript") then
			local loadedInit = require(init)
			if typeof(loadedInit) == "table" then
				local initInit = loadedInit.Init
				if type(initInit) == "function" then
					initInit(loadedInit, window, newClient)
				end
				
				local setReferences = loadedInit.SetReferences
				if type(setReferences) == "function" then
					setReferences(loadedInit, self.References)
				end
			end
		end
	end
	
	table.insert(self.Windows, window)
	
	return window
end

function windowMaker:SetReferences(references)
	self.References = references
	
	self.References.Events.SetPluginEnabled.Event:Connect(function(b)
		if b then
			for _, window in pairs(self.Windows) do
				if type(self.SaveState[window]) ~= "nil" then
					window.Enabled = self.SaveState[window]
				end
			end
		else
			for _, window in pairs(self.Windows) do
				self.SaveState[window] = window.Enabled
				window.Enabled = false
			end
		end
	end)
end

return windowMaker