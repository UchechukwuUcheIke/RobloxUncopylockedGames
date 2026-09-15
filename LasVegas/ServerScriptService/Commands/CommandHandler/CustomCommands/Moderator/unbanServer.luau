local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileService = require(ServerStorage.Modules.ProfileService);
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local DataTemplate = require(ServerStorage.Modules.ProfileService.PlayerData.Template);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local Permissions = require(ReplicatedStorage.Modules.Permissions);
local ProfileStore = ProfileManager:GetProfileStore();

return function (context, playerName, unbanReason)
	local playerID = CommonFunctions:GetPlayerIDFromPlayerName(playerName);
	if playerID then
		if context.Executor.UserId ~= playerID then
			local result = Permissions:CanExecutorActOnPlayer(context.Executor, playerID);
			if result == "failedBoth" then
				return "Unable to unban, failed to get rank data for yourself and "..playerName.."."
			elseif result == "failedExecutor" then
				return "Unable to unban, failed to get rank data for yourself."
			elseif result == "failedPlayer" then
				return "Unable to unban, failed to get rank data for "..playerName.."."
			elseif result then
				local profile = ProfileStore:ViewProfileAsync(tostring(playerID));
				if profile then
					if profile.Data.Moderations.IsBanned then
						ProfileStore:GlobalUpdateProfileAsync(
							tostring(playerID),
							function(globalUpdates)
								globalUpdates:AddActiveUpdate(
									{
										ModeratorID = context.Executor.UserId,
										UpdateType = "unban",
										UnbanReason = unbanReason,
										UnbanTime = os.time()
									}
								)
							end
						)
						return "Unbanned "..playerName.." for: "..unbanReason.."."
					end
					return "Unable to unban, "..playerName.." is not banned."
				end
				return "Unable to unban, no data profile found for "..playerName.." in the profile manager."
			end
			return "Unable to unban, you don't have permission to run this command on "..playerName.."."
		end
		return "Unable to unban, you cannot run this command on yourself."
	end
	return "Unable to unban, couldn't fetch UserID for username "..playerName.."."
end