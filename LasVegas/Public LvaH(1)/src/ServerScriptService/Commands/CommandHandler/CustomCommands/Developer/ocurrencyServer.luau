local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local Permissions = require(ReplicatedStorage.Modules.Permissions);
local ProfileStore = ProfileManager:GetProfileStore();

return function (context, playerName, currency, amount)
	local playerID = CommonFunctions:GetPlayerIDFromPlayerName(playerName);
	if playerID then
		if not CommonFunctions:GetPlayerInGameWithPlayerID(playerID) then
			local result = Permissions:CanExecutorActOnPlayer(context.Executor, playerID);
			if result == "failedBoth" then
				return "Unable to adjust currency, failed to get rank data for yourself and "..playerName.."."
			elseif result == "failedExecutor" then
				return "Unable to adjust currency, failed to get rank data for yourself."
			elseif result == "failedPlayer" then
				return "Unable to adjust currency, failed to get rank data for "..playerName.."."
			elseif result then
				if currency == "Cash" or currency == "Tokens" then
					local legitAmount = math.floor(amount);

					ProfileStore:GlobalUpdateProfileAsync(
						tostring(playerID),
						function(globalUpdates)
							globalUpdates:AddActiveUpdate(
								{
									PlayerID = playerID,
									UpdateType = "currency",
									Currency = currency,
									Amount = amount
								}
							)
						end
					)

					return "Adjusted the "..currency.." of "..playerName.." by "..legitAmount..". It will take about a minute after they're detected in game for the game to process your command."
				end
				return "Unable to adjust currency, you didn't provide a valid currency type."
			end
			return "Unable to adjust currency, you don't have permission to run this command on "..playerName.."."
		end
		return "Unable to adjust currency, you can only use offline commands on players not in your current server."
	end
	return "Unable to adjust currency, couldn't fetch UserID for username "..playerName.."."
end