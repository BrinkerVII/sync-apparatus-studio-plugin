local plugin = PluginManager():CreatePlugin()

local pluginState = {
	Enabled = false
}

function pluginState:FireEvent()
	self.References.Events.SetPluginEnabled:Fire(self.Enabled)
end

function pluginState:SetReferences(references)
	self.References = references
	
	self.Toolbar = plugin:CreateToolbar("Sync Apparatus")
	
	self.Toolbar:CreateButton("Toggle", "Toggle Sync-Apparatus", "rbxassetid://886593929").Click:Connect(function()
		self.Enabled = not self.Enabled
		
		if self.References then
			self:FireEvent()
		end
	end)
	
	self:FireEvent()
end

return pluginState