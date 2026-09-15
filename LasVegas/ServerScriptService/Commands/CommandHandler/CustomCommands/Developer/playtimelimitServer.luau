local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

return function (context, player, amount)
	if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
		local profile = ProfileManager.Profiles[player];
		if profile then
			local legitAmount = math.floor(amount);
			profile.Data.MinutesOnline = math.clamp(profile.Data.MinutesOnline + legitAmount, 0, ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes"));
			player:SetAttribute("MinutesOnline", profile.Data.MinutesOnline);
			if profile.Data.MinutesOnline >= ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes") then
				player:Kick("You reached the playtime limit of "..ReplicatedStorage:GetAttribute("PlaytimeLimitInMinutes").." accumulative minutes. Take a break of "..ReplicatedStorage:GetAttribute("BreaktimeLengthInMinutes").." minutes or more to fully reset your playtime cooldown.");
			end
			
			return "Adjusted the playtime limit of "..player.Name.." by "..legitAmount.." minutes."
		end
		return "Unable to adjust playtime limit, no data profile found for "..player.Name.." in the profile manager."
	end
	return "Unable to adjust playtime limit, you don't have permission to run this command on "..player.Name.."."
end