local toolbar = {}

local coreGui = game:GetService("CoreGui")

function toolbar:Show()
	
end

-- ## Button Functions ## --
function toolbar:ButtonFunction_PushSelection()
	self.References.Events.PushSelection:Fire()
end

function toolbar:ButtonFunction_Disconnect()
	self.References.Events.RequestDisconnect:Fire()
	self.References.Events.SetConnectionWindowVisible:Fire(true)
end

function toolbar:ButtonFunction_ShowConnectionWindow()
	if self.References.Functions.IsConnected:Invoke() then
		warn("Already connected!")
		return
	end
	
	self.References.Events.SetConnectionWindowVisible:Fire(true)
end

function toolbar:ButtonFunction_ShowProjectWindow()
	self.References.Events.SetProjectWindowVisible:Fire(true)
end

function toolbar:SetTooltipTo(button)
	if not button then
		self.ToolTip.Parent = nil
		return
	end
	
	local stringValue = button:FindFirstChild("ToolTip")
	if not stringValue then return; end
	
	if not stringValue:IsA("StringValue") then
		return warn(stringValue:GetFullName() .. " is not a StringValue")
	end
	
	self.ToolTip.Size = UDim2.new(0, 200, 0, button.AbsoluteSize.Y)
	self.ToolTip.Position = UDim2.new(1, 15, 0, 0)
	self.ToolTip.Text = stringValue.Value
	self.ToolTip.Parent = button
end

function toolbar:SetReferences(references)
	self.References = references
	self.Interface = self.References.Resources.Toolbar:Clone()
	
	if coreGui:FindFirstChild(self.Interface.Name) then
		repeat
			coreGui:FindFirstChild(self.Interface.Name):Destroy()
		until not coreGui:FindFirstChild(self.Interface.Name)
	end
	
	self.Interface.Parent = coreGui
	
	self.ToolTip = Instance.new("TextLabel")
	self.ToolTip.BackgroundColor3 = self.Interface.Frame.BackgroundColor3
	self.ToolTip.TextColor3 = Color3.new(1, 1, 1)
	self.ToolTip.Name = "ToolTipLabel"
	
	for _, button in pairs(self.Interface.Frame:GetChildren()) do
		if button:IsA("ImageButton") then
			button.MouseEnter:Connect(function()
				self:SetTooltipTo(button)
			end)
			
			button.MouseLeave:Connect(function()
				self:SetTooltipTo(nil)
			end)
			
			button.MouseButton1Click:Connect(function()
				local targetFunction = self["ButtonFunction_" .. button.Name]
				if type(targetFunction) == "function" then
					targetFunction(self)
				end
			end)
		end
	end
	
	self.References.Events.SetPluginEnabled.Event:Connect(function(b)
		self.Interface.Enabled = b
	end)
end

return toolbar