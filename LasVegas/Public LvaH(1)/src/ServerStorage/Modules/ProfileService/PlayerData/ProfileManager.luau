local DataTemplate = require(script.Parent.Template);
local ProfileService = require(script.Parent.Parent);

local ProfileManager = {}
ProfileManager.Profiles = {};

function ProfileManager.AdjustCurrency(player, currency, amount)
	if amount ~= 0 and player:IsA("Player") then
		local profile = ProfileManager.Profiles[player];
		if profile then
			local fixedAmount = math.floor(amount);
			local fixedCurrency = math.floor(profile.Data[currency]);
			local newCurrency = fixedCurrency + fixedAmount;
			profile.Data[currency] = newCurrency;
			player:SetAttribute(currency, profile.Data[currency]);
			return true;
		end
	end
end

function ProfileManager.AdjustSetting(player: Player, setting: string, value: number)
	local profile = ProfileManager.Profiles[player];
	if not profile then return; end
	profile.Data.Settings[setting] = value;
end

function ProfileManager:GetProfileStore()
	return ProfileService.GetProfileStore("Beta6", DataTemplate);
end

return ProfileManager;