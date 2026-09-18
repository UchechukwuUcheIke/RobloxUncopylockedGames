local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Template = require(ServerStorage.Modules.ProfileService.PlayerData.Template);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, player)
	if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
		local profile = ProfileManager.Profiles[player];
		if profile then
			profile.Data.Moderations = Template.Moderations;
			return "Wiped moderation history for "..player.Name.."."
		end
		return "Unable to wipe moderation history, no data profile found for "..player.Name.." in the profile manager."
	end
	return "Unable to wipe moderation history, you don't have permission to run this command on "..player.Name.."."
end