local character = script.Parent;
local cooldowns = {};

if character.Name == "GamerOkami" then
	local Players = game:GetService("Players");
	local ServerStorage = game:GetService("ServerStorage");
	local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
	local cooldown = false;

	local hitbox = script.Hitbox:Clone();
	hitbox.CFrame = character.HumanoidRootPart.CFrame;
	hitbox.WeldConstraint.Part1 = character.HumanoidRootPart;
	hitbox.Parent = character;

	hitbox.Touched:Connect(function(hit)
		local character = hit.Parent;
		if character then
			local player = Players:GetPlayerFromCharacter(character);
			if player and not cooldowns[player] then
				cooldowns[player] = true;
				if CommonFunctions:CheckBadgeOwnership(player.UserId, 984452366040) == false then
					CommonFunctions:AwardBadge(player, 984452366040, false);
				end
				task.wait(1);
				cooldowns[player] = false;
			end
		end
	end)
else
	task.wait(1);
	script:Destroy();
end