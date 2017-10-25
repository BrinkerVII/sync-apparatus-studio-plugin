local projectWindow = {}

local generalAPI;
local fileSettings;

function projectWindow:Init(window, client)
	self.Window = window
	self.Client = client
	
	window.Enabled = false
	window.Titlebar.Caption.Text = "Project Management"
	window.Titlebar.Frame.Size = UDim2.new(0, 300, 0, 320)
	
	local listItem = Instance.new("TextButton")
	listItem.BackgroundTransparency = 0
	listItem.BackgroundColor3 = window.Titlebar.Frame.BackgroundColor3
	listItem.BorderSizePixel = 0
	listItem.Size = UDim2.new(1, 0, 0, 25)
	listItem.TextColor3 = Color3.new(1, 1, 1)
	
	self.ListItemTemplate = listItem
	
	client.Buttons.Close.MouseButton1Click:Connect(function()
		self:Hide()
	end)
	
	client.Buttons.CreateProject.MouseButton1Click:Connect(function()
		local input = client.NewProject.ProjectNameInput.Text
		if not generalAPI:CreateProject(input) then
			warn("Failed to create project")
		else
			self:PopulateProjectList()
		end
	end)
	
	client.ProjectList.Buttons.UseProject.MouseButton1Click:Connect(function()
		 if type(self.SelectedProject) ~= "string" then
			warn("Nothing appropriate is selected")
			return
		end
		
		fileSettings:Set("ProjectName", self.SelectedProject)
		warn(("Set project to '%s'"):format(self.SelectedProject))
	end)
end

function projectWindow:Hide()
	self.SelectedProject = nil
	self.Window.Enabled = false
end

function projectWindow:Show()
	spawn(function()
		self:PopulateProjectList()
	end)
	self.Window.Enabled = true
end

function projectWindow:PopulateProjectList()
	if not self.References then return; end
	
	local container = self.Client.ProjectList.ListContainer
	
	for _, v in pairs(container:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
	
	if not self.References.Functions.IsConnected:Invoke() then
		warn("Could not list projects because client is not connected")
		return
	end
	
	local projects = generalAPI:GetProjects()
	local itemYSize = self.ListItemTemplate.Size.Y.Offset
	for i, project in pairs(projects) do
		local listItem = self.ListItemTemplate:Clone()
		listItem.Position = UDim2.new(0, 0, 0, itemYSize * (i - 1))
		listItem.Name, listItem.Text = project, project
		
		listItem.MouseButton1Click:Connect(function()
			self.SelectedProject = project
		end)
		
		listItem.Parent = container
	end
	
	container.CanvasSize = UDim2.new(1, 0, 0, #projects * itemYSize)
end

function projectWindow:SetReferences(references)
	self.References = references
	
	generalAPI = require(self.References.Modules.GeneralAPI)
	fileSettings = require(self.References.Modules.FileSettings)
	
	self.References.Events.SetProjectWindowVisible.Event:Connect(function(b)
		assert(type(b) == "boolean", "SetProjectWindowVisible expects a boolean")
		
		if b then
			self:Show()
		else
			self:Hide()
		end
	end)
end

return projectWindow