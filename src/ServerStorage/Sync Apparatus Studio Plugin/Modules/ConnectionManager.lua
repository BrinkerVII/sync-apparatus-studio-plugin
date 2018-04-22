print("ConnectionManager:: Start Init")

local fileSettings = require(script.Parent.FileSettings)

local connectionManager = {
	Connected = false
}
local httpService = game:GetService("HttpService")

print("ConnectionManager:: Define Functions")
function connectionManager:Connect(connectionString, instanceName)
	assert(type(connectionString) == "string", "ConnectionString must be of type string")
	assert(type(instanceName) == "string", "InstanceName must be of type string")
	
	if self.References.Functions.PilotIsAlive:Invoke() then
		error("Could not connect, because the pilot is alive")
		return
	end
	
	local baseURL = "http://" .. connectionString
	if not self:Probe(baseURL) then
		return nil
	end
	
	local body = { name = instanceName }
	body = httpService:JSONEncode(body)
	
	local response = httpService:JSONDecode(httpService:PostAsync(baseURL.. "/announce", body))
	if response then
		if type(response.clientId) == "string" then
			self.BaseURL = baseURL
			self.ClientID = response.clientId
			
			print(("Sync apparatus client connected with ID '%s'"):format(self.ClientID))
			self.References.Events.SetConnectionWindowVisible:Fire(false)
			
			self.References.Events.StartPilot:Fire()
			self.Connected = true
			
			if not fileSettings:HasKey("ProjectName") then
				self.References.Events.SetProjectWindowVisible:Fire(true)
			end
		end
	end
end

function connectionManager:Probe(baseURL)
	local baseURLType = type(baseURL)
	assert(baseURLType == "nil" or baseURLType == "string", "baseURL must be of type nil or string")
	
	baseURL = baseURL or self.BaseURL
	
	local response;
	local success, err = pcall(function()
		response = httpService:GetAsync(baseURL .. "/hello")
	end)
	
	if not success or not response then
		if response then
			warn(response)
		end
		
		if tostring(err) == "Http requests are not enabled" then
			warn("HTTP requests are not enabled.\nMake sure HttpEnabled is set to 'true' in HttpService")
		else
			warn(err)
		end
		
		return false
	end
	
	success, err = pcall(function()
		response = httpService:JSONDecode(response)
	end)
	
	if not success then
		warn("Probe got a malformed response, are you sure you're connecting to Sync-Apparatus?")
		return false
	end
	
	local defaultString, serverName, serverTime;
	success, err = pcall(function()
		defaultString = response.defaultString
		serverName = response.serverName
		serverTime = response.serverTime
	end)
	
	if not success then
		warn("Did not get correct values back from the remote server, make sure Sync-Apparatus is up to date!")
		return false
	end
	
	if defaultString ~= "sync-apparatus-daemon" then
		warn("Did not get a correct default string from the remote server, make sure Sync-Apparatus is up to date!")
		warn(("Got defaultString '%s'"):format(tostring(defaultString)))
		return false
	end
	
	local conmsg = ("Probed Sync-Apparatus server '%s' with server time '%s'"):format(serverName, serverTime)
	print(conmsg)
	
	return true
end

function connectionManager:Disconnect()
	if type(self.ClientID) ~= "string" then
		return error("ConnectionManager:: Cannot disconnect because ClientID is not set properly")
	end
	
	local body = {
		clientToken = true
	}
	
	local success, err = pcall(function()
		self:DeleteAsync("client", body)
	end)
	
	if not success then
		warn("Failed to disconnect")
		warn(debug.traceback())
	else
		warn("Disconnected Sync-Apparatus Client")
		self.References.Events.StopPilot:Fire()
		self.Connected = false
	end
	
	return success
end

function connectionManager:PostAsync(endpoint, body, contentType, ...)
	assert(type(endpoint) == "string", "Endpoint must be of type string")
	if body then
		local bodyType = type(body)
		assert(bodyType == "string" or bodyType == "table" or bodyType == "nil", "Body must of of type table, string or nil")
	end
	if contentType then
		assert(typeof(contentType) == "EnumItem", "contentType must be of type EnumItem")
	end
	
	if not self.Connected then
		error("Cannot POST because client is disconnected", 2)
	end
	
	local url = self:FormatURL(endpoint)
	
	local putClientToken;
	putClientToken = function(t)
		if type(t) == "table" then
			for k, v in pairs(t) do
				if k == "clientToken" then
					t[k] = self.ClientID
				elseif type(v) == "table" then
					putClientToken(v)
				end
			end
		end
	end
	
	putClientToken(body)
	
	if body then
		body = httpService:JSONEncode(body)
	else
		body = "{}"
	end
	
	local receive = httpService:PostAsync(url, body, contentType or Enum.HttpContentType.ApplicationJson, ...)
	local json;
	pcall(function()
		json = httpService:JSONDecode(receive)
	end)
	
	return (json or receive)
end

function connectionManager:DeleteAsync(endpoint, body, contentType, compress, headers)
	assert(type(endpoint) == "string", "Endpoint must be a string")
	
	if not self.Connected then
		error("Cannot DELETE because client is disconnected", 2)
	end
	
	local realHeaders = {
		["X-HTTP-Method-Override"] = "DELETE"
	}
	
	if type(headers) == "table" then
		for k, v in pairs(headers) do
			realHeaders[k] = v
		end
	end
	
	self:PostAsync(endpoint, body, contentType, compress, realHeaders)
end

function connectionManager:GetAsync(endpoint, ...)
	assert(type(endpoint) == "string", "Endpoint must be of type string")
	
	if not self.Connected then
		error("Cannot GET because client is disconnected", 2)
	end
	
	local url = self:FormatURL(endpoint)
	
	local receive = httpService:GetAsync(url, ...)
	local json;
	pcall(function()
		json = httpService:JSONDecode(receive)
	end)
	
	return (json or receive)
end

function connectionManager:FormatURL(endpoint)
	if endpoint:find("%$clientToken") then
		endpoint = endpoint:gsub("%$clientToken", self.ClientID)
	end
	return ("%s/%s"):format(self.BaseURL, endpoint)
end

function connectionManager:SetReferences(references)
	self.References = references
	
	self.References.Events.RequestConnection.Event:Connect(function(...)
		self:Connect(...)
	end)
	
	self.References.Events.RequestDisconnect.Event:Connect(function()
		self:Disconnect()
	end)
	
	self.References.Functions.IsConnected.OnInvoke = (function()
		return self.Connected
	end)
end

print("ConnectionManager:: End Init")
return connectionManager