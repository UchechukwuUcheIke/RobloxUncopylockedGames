local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, player, banReason)
	if context.Executor ~= player then
		if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
			local profile = ProfileManager.Profiles[player];
			if profile then
				profile.Data.Moderations.IsBanned = true;
				profile.Data.Moderations.IsPermBanned = true;
				profile.Data.Moderations.CurrentBanReason = banReason;
				profile.Data.Moderations.CurrentModeratorWhoBanned = context.Executor.UserId;
				table.insert(profile.Data.Moderations.PriorBans, {Moderator = context.Executor.UserId, Reason = banReason, ActionTime = os.time(), BanType = "PERM"});
				player:Kick("You have been permanently banned for: "..banReason..".");
				return "Permanently banned "..player.Name.." for: "..banReason.."."
			end
			return "Unable to pban, no data profile found for "..player.Name.." in the profile manager."
		end
		return "Unable to pban, you don't have permission to run this command on "..player.Name.."."
	end
	return "Unable to pban, you cannot run this command on yourself."
end