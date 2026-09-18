local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Module = ReplicatedStorage.PlayersListPlus
local PlayersListPlus = require(Module)
local GetPermissions = require(Module.Modules.GetPermissions)
local Remote = Module.RemoteEvent

local events = {
	["Kick"] = function(Player, PlayerToKick)
		local hasPermission = GetPermissions.HasPlayerPermission(Player, "Kick")
		
		if not hasPermission then
			return
		end
		
		PlayerToKick:Kick()
	end,
}

function module.init()
	Remote.OnServerEvent:Connect(function(plr, action, ...)
		local event = events[action]

		if event then
			event(plr, ...)
		end
	end)
end

return module
