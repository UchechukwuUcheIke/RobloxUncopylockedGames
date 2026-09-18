local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local ProfileStore = ProfileManager:GetProfileStore();

local function displayName(ID)
	local modName = CommonFunctions:GetPlayerNameFromPlayerID(ID);
	if modName then
		return modName;
	end
	return ID;
end

return function (context, playerName)
	local playerID = CommonFunctions:GetPlayerIDFromPlayerName(playerName);
	if playerID then
		if not CommonFunctions:GetPlayerInGameWithPlayerID(playerID) then
			local profile = ProfileStore:ViewProfileAsync(tostring(playerID));
			if profile then
				context:Reply("----- Moderation history for "..playerName.." -----");

				context:Reply(" ");
				context:Reply("- Kick Logs -");
				context:Reply("_______________________________");
				for _, log in pairs(profile.Data.Moderations.PriorKicks) do	
					context:Reply("Moderator: "..displayName(log.Moderator));
					context:Reply("Reason: "..log.Reason);
					context:Reply("Time: "..CommonFunctions:GetDateFromTime(log.ActionTime));
					context:Reply("_______________________________");
				end

				context:Reply(" ");
				context:Reply("- Ban Logs -");
				context:Reply("_______________________________");
				for _, log in pairs(profile.Data.Moderations.PriorBans) do
					context:Reply("Moderator: "..displayName(log.Moderator));
					context:Reply("Reason: "..log.Reason);
					context:Reply("Time: "..CommonFunctions:GetDateFromTime(log.ActionTime));
					context:Reply("BanType: "..log.BanType);
					context:Reply("_______________________________");
				end

				context:Reply(" ");
				context:Reply("- Unban Logs -");
				context:Reply("_______________________________");
				for _, log in pairs(profile.Data.Moderations.PriorUnbans) do
					context:Reply("Moderator: "..displayName(log.Moderator));
					context:Reply("Reason: "..log.Reason);
					context:Reply("Time: "..CommonFunctions:GetDateFromTime(log.ActionTime));
					context:Reply("_______________________________");
				end

				context:Reply(" ");
				return "End of moderation history for "..playerName.."."
			end
			return "Unable to show moderation history, no data profile found for "..playerName.." in the profile manager."
		end
		return "Unable to show moderation history, you can only use offline commands on players not in your current server."
	end
	return "Unable to show moderation history, couldn't fetch UserID for username "..playerName.."."
end