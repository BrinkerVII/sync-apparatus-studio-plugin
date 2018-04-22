print("Pilot:: Start Init")

local pilot = {
	Alive = false
}

local DEFAULT_WAIT_TIME = 1 / 1

print("Pilot:: Require FileSettings")
local fileSettings = require(script.Parent.FileSettings)
print("Pilot:: Require GeneralAPI")
local generalAPI = require(script.Parent.GeneralAPI)
print("Pilot:: Require ConnectionManager")
local pullyModule = require(script.Parent.PullyModule)

print("Pilot:: Define Functions")
function pilot:Start(waitTime)
	if self.Alive then
		return warn("Attempted to start an already running pilot")
	end
	self.Alive = true
	
	local realWaitTime = waitTime or DEFAULT_WAIT_TIME
	local loopError = false
	spawn(function()
		repeat
			local success, err = pcall(function()
				local projectName = fileSettings:GetProjectName()
			
				local changes = generalAPI:GetChanges(projectName)
				print(("Pilot:: Got %d pending changes"):format(#changes))
				
				pullyModule:PullChanges(changes)
				wait(realWaitTime)
			end)
			
			loopError = not success
		until not self.Alive or loopError
		
		if loopError then
			error(debug.traceback())
		end
	end)
end

function pilot:Stop()
	if not self.Alive then
		return warn("Attmempted to stop a dead pilot")
	end
	
	self.Alive = false
end

function pilot:SetReferences(references)
	self.References = references
	
	self.References.Events.StartPilot.Event:Connect(function()
		self:Start()
	end)
	
	self.References.Events.StopPilot.Event:Connect(function()
		self:Stop()
	end)
	
	self.References.Functions.PilotIsAlive.OnInvoke = (function()
		return self.Alive
	end)
end

print("Pilot:: End Init")
return pilot