local Players = game:GetService("Players");
local Lighting = game:GetService("Lighting");
local Teams = game:GetService("Teams");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local DataStoreService = game:GetService("DataStoreService");
local RunService = game:GetService("RunService");

local Remotes = ReplicatedStorage:WaitForChild("Remotes");
local HoloAction = Remotes:WaitForChild("HoloAction");
local Weapons = ServerStorage:WaitForChild("Weapons");
local Maps = ServerStorage:WaitForChild("Maps");
local Minigames = ServerStorage:WaitForChild("Minigames");
local Obbies = ServerStorage:WaitForChild("Obbies");
local MeritDatastore = DataStoreService:GetDataStore("Merits");

local remoteCooldowns = {};
local weaponsLoaded = {};
local mapLoaded = "None";
local minigameLoaded = "None";
local RNG = Random.new();

local function shuffleTable(tbl)
	local random = math.random
	local iterations = #tbl
	local j

	for i = iterations, 2, -1 do
		j = random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

local function passedRemoteCooldown(player)
	if not player or not player.Character then
		return false;
	end

	if remoteCooldowns[player] then
		if os.time() - remoteCooldowns[player] < 1 then
			return false;
		end
		remoteCooldowns[player] = os.time();
	else
		remoteCooldowns[player] = os.time();
	end
	
	return true;
end

local function passedRemoteSecurity(player, arguments, types)
	if player:GetRankInGroup(9164618) < 252 and not RunService:IsStudio() then
		return false;
	end
	
	for each, argument in pairs(arguments) do
		if typeof(argument) ~= types[each] then
			return false;
		end
		if typeof(argument) ~= typeof(argument) then
			return false;
		end
		if argument == nil then
			return false;
		end
		if typeof(argument) == "number" then
			if argument > 10000 or argument < -10000 then
				return false;
			end
		end
	end

	return true;
end

Players.PlayerAdded:Connect(function(player)
	local savedMerits;
	local success, response = pcall(function()
		savedMerits = MeritDatastore:GetAsync(player.UserId);
	end)

	player:SetAttribute("Merits", savedMerits or 0);
	if not success then
		player:SetAttribute("MeritLoadFailed", true);
		--webhook to discord notifying HR of load failure
	end
	
	local character = player.Character or player.CharacterAdded:Wait();
	task.wait(1);
	if player.Team == Teams.Training then
		for each, weaponName in pairs(weaponsLoaded) do
			local newWeapon = Weapons:FindFirstChild(weaponName);
			local weapon, weapon2 = newWeapon:Clone(), newWeapon:Clone();
			weapon.Parent = player.Backpack;
			weapon2.Parent = player.StarterGear;
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local success, response = pcall(function()
		if not player:GetAttribute("MeritLoadFailed") then
			MeritDatastore:SetAsync(player.UserId, player:GetAttribute("Merits"));
		end
	end)

	if not success then
		--webhook to discord notifying HR of save failure
	end
end)

HoloAction.OnServerEvent:Connect(function(player, action, data)
	local passedCooldown = passedRemoteCooldown(player);
	if passedCooldown then
		if action == "Map" then
			local passedSecurity = passedRemoteSecurity(player, {data[1]}, {"string"});
			if passedSecurity then
				local newMap = Maps:FindFirstChild(data[1]);
				if data[1] == "ZRandom" then
					local totalMaps = Maps:GetChildren();
					newMap = totalMaps[RNG:NextInteger(1, #totalMaps)];
				end
				
				if newMap then
					if mapLoaded == newMap.Name then
						workspace.Map[newMap.Name]:Destroy();
						mapLoaded = "None";
						HoloAction:FireAllClients("Removed map: "..newMap.Name);
					else
						for each, child in pairs(workspace.Map:GetChildren()) do
							child:Destroy();
						end
						newMap:Clone().Parent = workspace.Map;
						mapLoaded = newMap.Name;
						if data[1] == "ZRandom" then
							HoloAction:FireAllClients("Inserted random map: "..newMap.Name);
						else
							HoloAction:FireAllClients("Inserted map: "..newMap.Name);
						end
					end
				end
			end
		elseif action == "Minigame" then
			local passedSecurity = passedRemoteSecurity(player, {data[1]}, {"string"});
			if passedSecurity then
				local newMap = Minigames:FindFirstChild(data[1]);
				if newMap then
					if minigameLoaded == newMap.Name then
						workspace.Minigame[newMap.Name]:Destroy();
						minigameLoaded = "None";
						HoloAction:FireAllClients("Removed minigame: "..newMap.Name);
					else
						for each, child in pairs(workspace.Minigame:GetChildren()) do
							child:Destroy();
						end
						newMap:Clone().Parent = workspace.Minigame;
						minigameLoaded = newMap.Name;
						HoloAction:FireAllClients("Inserted minigame: "..newMap.Name);
					end
				end
			end
		elseif action == "Obby" then
			local passedSecurity = passedRemoteSecurity(player, {data[1]}, {"string"});
			if passedSecurity then
				local newMap = Obbies:FindFirstChild(data[1]);
				if newMap then
					if minigameLoaded == newMap.Name then
						workspace.Minigame[newMap.Name]:Destroy();
						minigameLoaded = "None";
						HoloAction:FireAllClients("Removed minigame: "..newMap.Name);
					else
						for each, child in pairs(workspace.Minigame:GetChildren()) do
							child:Destroy();
						end
						newMap:Clone().Parent = workspace.Minigame;
						minigameLoaded = newMap.Name;
						HoloAction:FireAllClients("Inserted minigame: "..newMap.Name);
					end
				end
			end
		elseif action == "Weapon" then
			local passedSecurity = passedRemoteSecurity(player, {data[1]}, {"string"});
			if passedSecurity then
				local newWeapon = Weapons:FindFirstChild(data[1]);
				if newWeapon then
					local index = table.find(weaponsLoaded, newWeapon.Name);
					if index then
						for each, player in pairs(Players:GetPlayers()) do
							if player.Character:FindFirstChild(newWeapon.Name) then
								player.Character.Humanoid:UnequipTools();
							end
							if player.Backpack:FindFirstChild(newWeapon.Name) then
								player.Backpack[newWeapon.Name]:Destroy();
							end
							if player.StarterGear:FindFirstChild(newWeapon.Name) then
								player.StarterGear[newWeapon.Name]:Destroy();
							end
						end
						table.remove(weaponsLoaded, index);
						HoloAction:FireAllClients("Removed weapon: "..newWeapon.Name);
					else
						for each, player in pairs(Players:GetPlayers()) do
							if player.Team ~= Teams.Guest and player.Team ~= Teams.Initiation then
								local weapon, weapon2 = newWeapon:Clone(), newWeapon:Clone();
								weapon.Parent = player.Backpack;
								weapon2.Parent = player.StarterGear;
							end
						end
						table.insert(weaponsLoaded, newWeapon.Name);
						HoloAction:FireAllClients("Inserted weapon: "..newWeapon.Name);
					end
				end
			end
		elseif action == "Merit" then
			local passedSecurity = passedRemoteSecurity(player, {data[1], data[2]}, {"table", "number"});
			if passedSecurity then
				local playerNamesToMerit = data[1];
				local meritAmount = data[2];
				if #playerNamesToMerit > 0 and meritAmount ~= 0 and meritAmount then
					for each, playerName in pairs(playerNamesToMerit) do
						local player = Players:FindFirstChild(playerName);
						if player then
							player:SetAttribute("Merits", player:GetAttribute("Merits") + meritAmount);
							if meritAmount > 0 then
								if meritAmount == 1 then
									HoloAction:FireAllClients("Awarded "..meritAmount.." merit to "..player.Name..".");
								else
									HoloAction:FireAllClients("Awarded "..meritAmount.." merits to "..player.Name..".");
								end
							else
								if meritAmount == -1 then
									HoloAction:FireAllClients("Revoked "..meritAmount.." merit from "..player.Name..".");
								else
									HoloAction:FireAllClients("Revoked "..meritAmount.." merits from "..player.Name..".");
								end
							end
							
						end
					end
				end
			end
		elseif action == "WOLimit" then
			local passedSecurity = passedRemoteSecurity(player, {data[1]}, {"number"});
			if passedSecurity then
				local value = data[1] or 11;
				local WOLimit = math.clamp(value, 1, 100);
				script:SetAttribute("WOLimit", WOLimit);
				HoloAction:FireAllClients("Changed death limit to: "..WOLimit);
			end
		elseif action == "StandingLines" then
			local passedSecurity = passedRemoteSecurity(player, {data[1], data[2]}, {"string", "Color3"});
			if passedSecurity then
				local lineArea = data[1];
				local newColor = data[2];
				
				if lineArea == "Left" and newColor == Color3.fromRGB(0, 0, 0) then
					newColor = Color3.fromRGB(98, 37, 209);
				elseif lineArea == "Right" and newColor == Color3.fromRGB(0, 0, 0) then
					newColor = Color3.fromRGB(248, 248, 248);
				end
				
				for each, standingLine in pairs(workspace.Holo.Functional.STSLines:GetChildren()) do
					if standingLine.Name == lineArea then
						standingLine.Top.Color = newColor;
					end
				end
			end
		elseif action == "Fog" then
			local passedSecurity = passedRemoteSecurity(player, {data[1]}, {"number"});
			if passedSecurity then
				local value = data[1] or 10000;
				local newFog = math.clamp(value, 50, 10000);
				Lighting.FogEnd = newFog;
				HoloAction:FireAllClients("Changed map fog to: "..newFog);
			end
		elseif action == "Time" then
			local passedSecurity = passedRemoteSecurity(player, {data[1]}, {"number"});
			if passedSecurity then
				local value = data[1] or 12;
				local newTime = math.clamp(value, 0, 24);
				Lighting.ClockTime = newTime;
				HoloAction:FireAllClients("Changed map time to: "..newTime..":00");
			end
		elseif action == "ObbyToggle" then
			script:SetAttribute("ObbyToggle", not script:GetAttribute("ObbyToggle"));
			
			for each, character in pairs(workspace:GetChildren()) do
				local foundPlayer = Players:FindFirstChild(character.Name)
				if foundPlayer then
					local onPhoenixTeam = foundPlayer.Team == Teams.Training or foundPlayer.Team == Teams.Initiation;
					character.Head.RankGui.Obby.Visible = (script:GetAttribute("ObbyToggle") and onPhoenixTeam) or false;
					character.Head.RankGui.Obby.Text = 0;
					foundPlayer:SetAttribute("ObbyCount", 0);
				end
			end
			
			HoloAction:FireAllClients("Changed obby counter visibility to: "..tostring(script:GetAttribute("ObbyToggle")));
		elseif action == "Teams" then
			script:SetAttribute("RandomTeams", not script:GetAttribute("RandomTeams"));
			
			if script:GetAttribute("RandomTeams") then
				local playerTable = Players:GetPlayers();
				shuffleTable(playerTable);
				
				for each, player in pairs(playerTable) do
					if player.Team == Teams["Training"] then
						local redPlayers = Teams.Red:GetPlayers();
						local bluePlayers = Teams.Blue:GetPlayers();
						if #redPlayers > #bluePlayers then
							player.Team = Teams.Blue;
						elseif #bluePlayers > #redPlayers then
							player.Team = Teams.Red;
						else
							player.Team = (RNG:NextInteger(1, 2) == 1 and Teams.Red) or Teams.Blue;
						end
					end
				end
				
				HoloAction:FireAllClients("Red and Blue teams have been randomized.");
			else
				for each, player in pairs(Players:GetPlayers()) do
					if player.Team == Teams.Red or player.Team == Teams.Blue then
						player.Team = Teams["Training"];
					end
				end
				
				HoloAction:FireAllClients("Red and Blue teams have been reset.");
			end
		elseif action == "Respawn" then
			for each, player in pairs(Players:GetPlayers()) do
				if player.Team == Teams.Red or player.Team == Teams.Blue then
					player.Team = Teams["Training"];
					player:LoadCharacter();
				end
			end
			script:SetAttribute("RandomTeams", false);

			HoloAction:FireAllClients("Red and Blue teams have been respawned.");
		end
	end
end)