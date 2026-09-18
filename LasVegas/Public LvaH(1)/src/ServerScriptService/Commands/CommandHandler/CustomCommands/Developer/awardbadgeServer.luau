local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);

return function (context, player, badgeID)
	if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
		if CommonFunctions:CheckBadgeOwnership(player.UserId, badgeID) == false then
			local returnMessage = CommonFunctions:AwardBadge(player, badgeID, false);
			if typeof(returnMessage) == "boolean" then
				return "Awarded badge "..badgeID.." to "..player.Name.."."
			end
			return "Unable to award badge, "..returnMessage
		end
		return "Unable to award badge, "..player.Name.." already owns that badge."
	end
	return "Unable to award badge, you don't have permission to run this command on "..player.Name.."."
end