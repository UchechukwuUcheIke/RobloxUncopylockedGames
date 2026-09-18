local Teams = game:GetService("Teams");
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local function AcquireKiller(hum)
	local tag = hum:FindFirstChild("creator")
	return tag and tag.Value
end

local function createStats(player)
	local leaderstats = Instance.new("IntValue");
	leaderstats.Name = "leaderstats";
	leaderstats.Parent = player;

	local kills = Instance.new("IntValue");
	kills.Name = "KOs";
	kills.Parent = leaderstats;

	local deaths = Instance.new("IntValue");
	deaths.Name = "WOs";
	deaths.Parent = leaderstats;

	local damage = Instance.new("IntValue");
	damage.Name = "DMG";
	damage.Parent = leaderstats;
end

Players.PlayerAdded:Connect(function(player)
	createStats(player);
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid");
		humanoid.Died:Connect(function()
			if player:FindFirstChild("leaderstats") then
				player.leaderstats.WOs.Value += 1;
				local phoenixRank = player:GetRankInGroup(9164618);

				if player.leaderstats.WOs.Value >= script.Parent.Parent.Game.HoloCore:GetAttribute("WOLimit") then
					if phoenixRank >= 1 then
						player.Team = Teams["Training"];
					else
						player.Team = Teams["Guest"];
					end
				end
				
				local killer = AcquireKiller(humanoid);
				if killer and killer:FindFirstChild("leaderstats") then
					killer.leaderstats.KOs.Value += 1;
				end
			end
		end)
	end)
end)