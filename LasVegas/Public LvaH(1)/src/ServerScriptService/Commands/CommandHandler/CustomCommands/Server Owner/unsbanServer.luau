local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ServerScriptService = game:GetService("ServerScriptService");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);

return function (context, playerName, banReason)
	local playerID = CommonFunctions:GetPlayerIDFromPlayerName(playerName);
	if playerID then
		if context.Executor.UserId ~= playerID then
			if Permissions:CanExecutorActOnPlayer(context.Executor, playerID) then
				if game.PrivateServerOwnerId ~= 0 then
					ServerScriptService.Player.PlayerManager.ServerBan:Fire(playerID, false);
					return "Server unbanned "..playerName.."."
				end
				return "Unable to unsban, you can only server unban players in private servers."
			end
			return "Unable to unsban, you don't have permission to run this command on "..playerName.."."
		end
		return "Unable to unsban, you cannot run this command on yourself."
	end
	return "Unable to unsban, couldn't fetch UserID for username "..playerName.."."
end