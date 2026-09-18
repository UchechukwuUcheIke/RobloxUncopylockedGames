local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local ReplicatedRemotes = ReplicatedStorage:WaitForChild("Remotes");
local StorePurchase = ReplicatedRemotes:WaitForChild("StorePurchase");
local ServerModules = ServerStorage:WaitForChild("Modules");
local ProfileService = ServerModules:WaitForChild("ProfileService");
local PlayerData = ProfileService:WaitForChild("PlayerData");
local ProfileManager = require(PlayerData:WaitForChild("ProfileManager"));
local CommonFunctions = require(ServerModules:WaitForChild("CommonFunctions"));
local GameFunctions = require(ServerModules:WaitForChild("GameFunctions"));

local function RegisterUpgradePurchase(upgrade, player, profile)
	profile.Data["Owns"..upgrade] = true;
	player:SetAttribute("Owns"..upgrade, true);
	
	if upgrade == "GoldClub" then
		CommonFunctions:AwardBadge(player, 1743025699831865, false);
	end
end

StorePurchase.OnServerEvent:Connect(function(player, upgrade)
	local profile = ProfileManager.Profiles[player];
	if not profile then return; end
	
	local upgradeCost = ReplicatedStorage:GetAttribute(upgrade.."Price");
	if upgradeCost and profile.Data.Cash >= upgradeCost and not profile.Data["Owns"..upgrade] then
		ProfileManager.AdjustCurrency(player, "Cash", -upgradeCost);
		RegisterUpgradePurchase(upgrade, player, profile);
	end
end)