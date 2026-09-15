local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileService = require(ServerStorage.Modules.ProfileService);
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local DataTemplate = require(ServerStorage.Modules.ProfileService.PlayerData.Template);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local Permissions = require(ReplicatedStorage.Modules.Permissions);
local ProfileStore = ProfileManager:GetProfileStore();

return function (context, playerName, banReason)
	local playerID = CommonFunctions:GetPlayerIDFromPlayerName(playerName);
	if playerID then
		if not CommonFunctions:GetPlayerInGameWithPlayerID(playerID) then
			if context.Executor.UserId ~= playerID then
				local result = Permissions:CanExecutorActOnPlayer(context.Executor, playerID);
				if result == "failedBoth" then
					return "Unable to pban, failed to get rank data for yourself and "..playerName.."."
				elseif result == "failedExecutor" then
					return "Unable to pban, failed to get rank data for yourself."
				elseif result == "failedPlayer" then
					return "Unable to pban, failed to get rank data for "..playerName.."."
				elseif result then
					ProfileStore:GlobalUpdateProfileAsync(
						tostring(playerID),
						function(globalUpdates)
							globalUpdates:AddActiveUpdate(
								{
									PlayerID = playerID,
									ModeratorID = context.Executor.UserId,
									UpdateType = "pban",
									BanReason = banReason,
									BanTime = os.time()
								}
							)
						end
					)
					return "Permanently banned "..playerName.." for: "..banReason..". It will take about a minute after they're detected in game for the game to process your command."
				end
				return "Unable to pban, you don't have permission to run this command on "..playerName.."."
			end
			return "Unable to pban, you cannot run this command on yourself."
		end
		return "Unable to pban, you can only use offline commands on players not in your current server."
	end
	return "Unable to pban, couldn't fetch UserID for username "..playerName.."."
end