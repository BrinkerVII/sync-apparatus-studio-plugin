local connectionWindow = {}

function connectionWindow:Init(window, client)
	print("ConnectionWindow:: Init")
	self.Window = window
	
	client.Size = UDim2.new(1, 0, 1, 0)
	window.Titlebar.Frame.Size = UDim2.new(0, 300, 0, 230)
	window.Titlebar.Caption.Text = "Sync Apparatus Connect"

	client.Buttons.CancelButton.MouseButton1Click:Connect(function()
		self:Hide()
	end)
	
	client.Buttons.ConnectButton.MouseButton1Click:Connect(function()
		local connectionString = client.ConnectionStringInput.Text
		local instanceName = client.InstanceNameInput.Text
		
		self.References.Events.RequestConnection:Fire(connectionString, instanceName)
	end)
end

function connectionWindow:Hide()
	self.Window.Enabled = false
end

function connectionWindow:Show()
	self.Window.Enabled = true
end

function connectionWindow:SetReferences(references)
	self.References = references
	
	self.References.Events.SetConnectionWindowVisible.Event:Connect(function(b)
		assert(type(b) == "boolean", "SetConnectionWindowVisible expects a boolean")
		
		if b then
			self:Show()
		else
			self:Hide()
		end
	end)
end

return connectionWindow