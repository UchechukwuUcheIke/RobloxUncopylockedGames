local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);

local function displayName(ID)
	local modName = CommonFunctions:GetPlayerNameFromPlayerID(ID);
	if modName then
		return modName;
	end
	return ID;
end

return function (context, player)
	local profile = ProfileManager.Profiles[player];
	if profile then
		context:Reply("----- Moderation history for "..player.Name.." -----");

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
		return "End of moderation history for "..player.Name.."."
	end
	return "Unable to show moderation history, no data profile found for "..player.Name.." in the profile manager."
end