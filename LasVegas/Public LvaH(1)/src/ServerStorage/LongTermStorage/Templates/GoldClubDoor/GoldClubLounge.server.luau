local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local door = script.Parent;
local teleport = door.Teleport;
local area = door.Area;

local overlapParams = OverlapParams.new();
overlapParams.FilterType = Enum.RaycastFilterType.Exclude;
overlapParams.FilterDescendantsInstances = {workspace.Games, workspace.Map};

while true do
	local characterPartsInArea = workspace:GetPartsInPart(area, overlapParams);
	local characterPartsAlreadyChecked = {};
	
	if characterPartsInArea then
		for each, part in pairs(characterPartsInArea) do
			if not table.find(characterPartsAlreadyChecked, part) then
				local character = part.Parent;
				if character:IsA("Model") then
					for each, characterPart in pairs(character:GetChildren()) do
						table.insert(characterPartsAlreadyChecked, characterPart);
					end

					local player = Players:GetPlayerFromCharacter(character);
					if player then
						local profile = ProfileManager.Profiles[player];
						if profile and not profile.Data.OwnsGoldClub then
							if character.Humanoid.Health > 0 then
								if character.Humanoid.Sit then
									character.Humanoid.Jump = true;
								end
								character:SetPrimaryPartCFrame(teleport.CFrame);
							end
						end
					end
				end
			end
		end
	end

	wait(3);
end