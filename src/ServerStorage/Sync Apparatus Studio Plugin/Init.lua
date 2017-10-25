local PRINT_ENABLED = true
local realPrint = print
function print(...)
	if PRINT_ENABLED then
		realPrint("Sync-Apparatus plugin:: ", ...)
	end
end

print("Stage = Setup references")
local references = {
	Resources = script.Parent:WaitForChild("Resources"),
	Modules = script.Parent:WaitForChild("Modules"),
	Events = script.Parent:WaitForChild("Events"),
	Functions = script.Parent:WaitForChild("Functions")
}

print("Stage = Require WindowMaker")
local windowMaker = require(references.Modules.WindowMaker)
windowMaker:SetReferences(references)

print("Stage = Require Pilot")
local pilot = require(references.Modules.Pilot)
pilot:SetReferences(references)

print("Stage = Require ConnectionManager")
local connectionManager = require(references.Modules.ConnectionManager)
connectionManager:SetReferences(references)

print("Stage = Require Toolbar")
local toolbar = require(references.Modules.ToolbarScript)
toolbar:SetReferences(references)

print("Stage = Require PushyModule")
local pushyModule = require(references.Modules.PushyModule)
pushyModule:SetReferences(references)

print("Stage = MakeWindow")
windowMaker:MakeWindow("ConnectionWindow")
windowMaker:MakeWindow("ProjectWindow")

print("Stage = Require PluginState")
local pluginState = require(references.Modules.PluginState)
pluginState:SetReferences(references)

print("Stage = Complete")