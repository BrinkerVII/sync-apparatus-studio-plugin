local stringx = {}

function stringx:Split(inputstr, sep)
	sep = (sep == nil and "%s" or sep)
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

return stringx