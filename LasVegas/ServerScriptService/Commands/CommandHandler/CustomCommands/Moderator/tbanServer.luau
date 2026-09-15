local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, player, banLength, banReason)
	if context.Executor ~= player then
		if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
			local duration = math.floor(banLength);
			if duration >= 1 then
				local profile = ProfileManager.Profiles[player];
				if profile then
					profile.Data.Moderations.IsBanned = true;
					profile.Data.Moderations.CurrentBanReason = banReason;
					profile.Data.Moderations.CurrentModeratorWhoBanned = context.Executor.UserId;
					profile.Data.Moderations.TimeWhenUnbanned = os.time() + (duration * 86400);
					table.insert(profile.Data.Moderations.PriorBans, {Moderator = context.Executor.UserId, Reason = banReason, ActionTime = os.time(), BanType = "TEMP"});

					if duration == 1 then
						player:Kick("You have been temporarily banned for "..duration.." day for: "..banReason..".");
						return "Temporarily banned "..player.Name.." for "..duration.." day for: "..banReason..".";
					end
					
					player:Kick("You have been temporarily banned for "..duration.." days for: "..banReason..".");
					return "Temporarily banned "..player.Name.." for "..duration.." days for: "..banReason..".";
				end
				return "Unable to tban, no data profile found for "..player.Name.." in the profile manager."
			end
			return "Unable to tban, ban length must be 1 day or more."
		end
		return "Unable to tban, you don't have permission to run this command on "..player.Name.."."
	end
	return "Unable to tban, you cannot run this command on yourself."
end