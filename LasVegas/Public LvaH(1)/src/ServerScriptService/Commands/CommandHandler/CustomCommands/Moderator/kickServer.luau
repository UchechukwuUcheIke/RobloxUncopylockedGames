local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, player, kickReason)
	if context.Executor ~= player then
		if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
			local profile = ProfileManager.Profiles[player];
			if profile then
				table.insert(profile.Data.Moderations.PriorKicks, {Moderator = context.Executor.UserId, Reason = kickReason, ActionTime = os.time()});
				player:Kick("You have been kicked from this server for "..kickReason..".");
				return "Kicked "..player.Name.." for"..kickReason.."."
			end
			return "Unable to kick, no data profile found for "..player.Name.." in the profile manager."
		end
		return "Unable to kick, you don't have permission to run this command on "..player.Name.."."
	end
	return "Unable to kick, you cannot run this command on yourself."
end