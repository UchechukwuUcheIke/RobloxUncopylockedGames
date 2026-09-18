local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local Permissions = require(ReplicatedStorage.Modules.Permissions);

local function setRegenLevel(player, regenType, profile, level)
	if regenType == "Cash" then
		profile.Data.CashRegenLevel = level;
		player:SetAttribute("CashRegenLevel", profile.Data.CashRegenLevel);

		local cashGainedPerRegen = ReplicatedStorage:GetAttribute("BaseCashRegen");
		if profile.Data.OwnsGoldClub then
			cashGainedPerRegen *= 3;
		end
		local cashRegenBonus = 1 + (profile.Data.CashRegenLevel * 0.2);
		cashGainedPerRegen *= cashRegenBonus;
		player:SetAttribute("CashGainedPerRegen", math.floor(cashGainedPerRegen));
	end
end

return function (context, player, regenType, level)
	if Permissions:CanExecutorActOnPlayer(context.Executor, player) then
		if regenType == "Cash" then
			local profile = ProfileManager.Profiles[player];
			if profile then
				local legitAmount = math.floor(level);
				if legitAmount >= 0 and legitAmount <= 5 then
					setRegenLevel(player, regenType, profile, legitAmount);
					return "Set the "..regenType.." regeneration of "..player.Name.." to "..legitAmount.."."
				end
				return "Unable to set regeneration level, level must be a whole number between 0 - 5."
			end
			return "Unable to set regeneration level, no data profile found for "..player.Name.." in the profile manager."
		end
		return "Unable to set regeneration level, you didn't provide a valid regeneration type."
	end
	return "Unable to set regeneration level, you don't have permission to run this command on "..player.Name.."."
end