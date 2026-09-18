local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");

local ServerModules = ServerStorage:WaitForChild("Modules");
local ProfileService = ServerModules:WaitForChild("ProfileService");
local PlayerData = ProfileService:WaitForChild("PlayerData");
local ProfileManager = require(PlayerData:WaitForChild("ProfileManager"));

local area = script.Parent;
local teleport = area.Teleport;

area.Touched:Connect(function(hit)
	if hit and hit.Parent then
		local character = hit.Parent;
		local player = Players:GetPlayerFromCharacter(character);
		if player then
			local profile = ProfileManager.Profiles[player];
			if profile and profile.Data.Tokens <= 0 then
				if character.Humanoid.Health > 0 then
					if character.Humanoid.Sit then
						character.Humanoid.Jump = true;
					end
					character:SetPrimaryPartCFrame(teleport.CFrame);
				end
			end
		end
	end
end)