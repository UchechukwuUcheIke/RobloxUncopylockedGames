local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local Debris = game:GetService("Debris");

local ServerModules = ServerStorage:WaitForChild("Modules");
local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local CommonFunctions = require(ServerModules:WaitForChild("CommonFunctions"));
local GameFunctions = require(ServerModules:WaitForChild("GameFunctions"));
local ProfileService = ServerModules:WaitForChild("ProfileService");
local PlayerData = ProfileService:WaitForChild("PlayerData");
local ProfileManager = require(PlayerData:WaitForChild("ProfileManager"));
local GameDataModule = require(ReplicatedModules:WaitForChild("GameData"));
local ReplicatedRemotes = ReplicatedStorage:WaitForChild("Remotes");
local Jackpot = ReplicatedRemotes:WaitForChild("Jackpot");

local Plinko = script.Parent;
local Functional = Plinko:WaitForChild("Functional");
local NPCs = Plinko:WaitForChild("NPCs");
local Remotes = Plinko:WaitForChild("Remotes");
local PlinkoGui = script:WaitForChild("Plinko");

local PlayerAction = Remotes:WaitForChild("PlayerAction");
local PlayNPC = Remotes:WaitForChild("PlayNPC");
local Balls = Functional:WaitForChild("Balls");
local Podiums = Functional:WaitForChild("Podiums");
local Spawns = Functional:WaitForChild("Spawns");
local Stools = Functional:WaitForChild("Stools");
local Zones = Functional:WaitForChild("Zones");
local Sign = Functional:WaitForChild("Sign");
local SoundBox = Functional:WaitForChild("SoundBox");
local SpawnA = Spawns:WaitForChild("SpawnA");
local SpawnB = Spawns:WaitForChild("SpawnB");

local GameData = {}; --{stoolName, actualPlayer, bet}
local RNG = Random.new();
local ProcessingEvent = false;
local ZoneChart = {
	{"0.00", Color3.fromRGB(255, 0, 0)},
	{"0.00", Color3.fromRGB(255, 0, 0)},
	{"0.00", Color3.fromRGB(255, 0, 0)},
	{"0.10", Color3.fromRGB(255, 0, 0)},
	{"0.10", Color3.fromRGB(255, 0, 0)},
	{"0.10", Color3.fromRGB(255, 0, 0)},
	{"0.50", Color3.fromRGB(255, 0, 0)},
	{"0.50", Color3.fromRGB(255, 0, 0)},
	{"0.50", Color3.fromRGB(255, 0, 0)},
	{"1.00", Color3.fromRGB(255, 255, 255)},
	{"3.00", Color3.fromRGB(0, 255, 0)},
	{"5.00", Color3.fromRGB(255, 255, 0)}
};

local function GetRandomDropPosition()
	local leftRange = SpawnA.Position;
	local rightRange = SpawnB.Position;
	local cframeToRange = CFrame.new(rightRange, leftRange);
	local distanceBetweenRanges = (leftRange - rightRange).Magnitude;
	local randomDistance = RNG:NextNumber(0, distanceBetweenRanges);
	local finalCFrame = cframeToRange + (cframeToRange.LookVector * randomDistance)
	return finalCFrame.Position;
end

local function ShuffleZones()
	local shuffledZones = {};
	for i, v in ipairs(ZoneChart) do
		local pos = math.random(1, #shuffledZones + 1);
		table.insert(shuffledZones, pos, v);
	end
	for index, zone in pairs(Zones:GetChildren()) do
		zone:SetAttribute("Multiplier", tonumber(shuffledZones[index][1]));
		zone.SurfaceGui.Multiplier.Text = "x"..shuffledZones[index][1];
		zone.SurfaceGui.Multiplier.TextColor3 = shuffledZones[index][2];
	end
end

local function DropPlinko(playerData)
	local clone = script.Ball:Clone();
	clone.Position = GetRandomDropPosition();
	clone.Anchored = false;
	clone.CanCollide = true;
	clone.Transparency = 0;
	clone.Parent = Balls;
	clone:SetNetworkOwner(nil);
	clone:SetAttribute("Stool", playerData[1]);
	Debris:AddItem(clone, 15);
	GameFunctions:PlaySound("Plinko", "Drop", SoundBox, false, false, false);
end

local function PlinkoInPlayingArea(plinkoPosition)
	local check1 = plinkoPosition.X <= SpawnB.Position.X;
	local check2 = plinkoPosition.Y == SpawnB.Position.Y;
	local check3 = plinkoPosition.Z <= SpawnB.Position.Z;
	local check4 = plinkoPosition.X >= SpawnA.Position.X;
	local check5 = plinkoPosition.Y == SpawnA.Position.Y;
	local check6 = plinkoPosition.X >= SpawnA.Position.Z;
	return check1 and check2 and check3 and check4 and check5 and check6;
end

local function GetPlayerStoolName(actualPlayer)
	local character = actualPlayer:IsA("Player") and actualPlayer.Character or actualPlayer;
	local humanoid = character:FindFirstChild("Humanoid");
	if humanoid then
		for each, stool in pairs(Stools:GetChildren()) do
			if stool.Seat.Occupant and stool.Seat.Occupant == humanoid then
				return stool.Name;
			end
		end
	end
end

local function GetPlayerPlinko(stoolName)
	for each, ball in pairs(Balls:GetChildren()) do
		if ball:GetAttribute("Stool") == stoolName then
			return ball;
		end
	end
end

local function GetPlayerDataFromGameData(player)
	for each, playerData in pairs(GameData) do
		if playerData[1] == player then
			return playerData;
		end
	end
end

local function ResetTable()
	Plinko:SetAttribute("RoundPending", false);
	Plinko:SetAttribute("RoundStarted", false);
	GameData = {};

	Sign.SurfaceGui.TextLabel.Text = "";
	Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
	for each, podium in pairs(Podiums:GetChildren()) do
		podium.Sign.SurfaceGui.TextLabel.Text = "";
		podium.Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
	end
	for each, sound in pairs(SoundBox:GetChildren()) do
		sound:Stop();
	end
	for each, ball in pairs(Balls:GetChildren()) do
		ball:Destroy();
	end
end

local function SpawnPlinko(plinkoPosition, betAmount, actualPlayer)
	local playerStool = GetPlayerStoolName(actualPlayer);
	local playerBall = GetPlayerPlinko(playerStool);
	local playerData = playerStool and GetPlayerDataFromGameData(playerStool);
	local ballPosition = plinkoPosition or GetRandomDropPosition();
	
	if not playerBall then
		local ball = script.Ball:Clone();
		ball.Overhead.Backing.Username.Text = actualPlayer:IsA("Player") and actualPlayer.DisplayName or actualPlayer.Name;
		ball.Overhead.Backing.Bet.Text = "$"..GameDataModule:AddCommasToNumber(betAmount);
		ball.Overhead.Enabled = true;
		ball.CanCollide = true;
		ball.Transparency = 0;
		ball.Position = ballPosition;
		ball:SetAttribute("Stool", playerStool);
		ball:SetAttribute("Bet", betAmount);
		ball.Parent = Balls;
		
		ProfileManager.AdjustCurrency(actualPlayer, "Cash", -betAmount);
		table.insert(GameData, {playerStool, actualPlayer, betAmount});
	elseif playerData then
		playerBall.Overhead.Backing.Bet.Text = "$"..GameDataModule:AddCommasToNumber(betAmount);
		playerBall.Position = ballPosition;
		playerBall:SetAttribute("Bet", betAmount);
		
		ProfileManager.AdjustCurrency(actualPlayer, "Cash", playerData[3] - betAmount);
		playerData[3] = betAmount;
	end
	
	if not Plinko:GetAttribute("RoundStarted") then
		Plinko:SetAttribute("RoundPending", true);
	end
end

local function DeletePlinko(actualPlayer)
	local playerStool = GetPlayerStoolName(actualPlayer);
	local playerBall = GetPlayerPlinko(playerStool);
	local playerData = playerStool and GetPlayerDataFromGameData(playerStool);
	
	if playerBall then
		playerBall:Destroy();
	end
	if playerData then
		ProfileManager.AdjustCurrency(actualPlayer, "Cash", playerData[3]);
	end
	for index, playerData in pairs(GameData) do
		if playerData[2] == actualPlayer then
			table.remove(GameData, index);
		end
	end
	
	if #Balls:GetChildren() == 0 then
		ResetTable();
	end
end

local function GetClosestZoneToPlinko(plinkoPosition)
	local closestZone;
	local closestDistance;
	for each, zone in pairs(Zones:GetChildren()) do
		local distance = (zone.Position - plinkoPosition).Magnitude;
		if not closestDistance then
			closestDistance = distance;
			closestZone = zone;
		elseif distance < closestDistance then
			closestDistance = distance;
			closestZone = zone;
		end
	end
	return closestZone;
end

local function RemovePlayerFromTable(player)
	Plinko:SetAttribute("PlayersAtTable", Plinko:GetAttribute("PlayersAtTable") - 1);

	for index, playerData in pairs(GameData) do
		if playerData[1] == player then
			DeletePlinko(playerData[2]);
			table.remove(GameData, index);
			Podiums[player].Sign.SurfaceGui.TextLabel.Text = "";
		end
	end
end

local function StartNewRound()
	--Start a new round
	Plinko:SetAttribute("RoundPending", false);
	Plinko:SetAttribute("RoundStarted", true);
	Sign.SurfaceGui.TextLabel.Text = "";
	
	--Drop all of the player's plinkos and wait for them to land
	if Plinko:GetAttribute("RoundStarted") then
		for each, stool in pairs(Stools:GetChildren()) do
			if stool.Seat.Occupant and stool.Seat.Occupant.Parent then
				if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
					local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
					if player then
						PlayerAction:FireClient(player, "dropping");
					end
				end
			end
		end
		for each, ball in pairs(Balls:GetChildren()) do
			ball.Anchored = false;
			if ball:IsDescendantOf(workspace) then
				ball:SetNetworkOwner(nil);
			end
			GameFunctions:PlaySound("Plinko", "Drop", SoundBox, false, false, false);
			task.wait(0.2);
		end
		task.wait(Plinko:GetAttribute("TimeToDrop"));
	end
	
	--Get the slots all the plinkos landed in and display/pay the winnings
	if Plinko:GetAttribute("RoundStarted") then
		GameFunctions:PlaySound("Plinko", "Tada", SoundBox, false, false, false);
		
		for each, playerData in pairs(GameData) do
			local playerBall;
			for each, ball in pairs(Balls:GetChildren()) do
				if ball:GetAttribute("Stool") == playerData[1] then
					playerBall = ball;
					playerBall.Anchored = true;
					break;
				end
			end
			
			if playerBall then
				local closestZone = GetClosestZoneToPlinko(playerBall.Position);
				local zoneMultiplier = closestZone:GetAttribute("Multiplier");
				local winnings = math.floor(playerData[3] * zoneMultiplier);
				Podiums[playerData[1]].Sign.SurfaceGui.TextLabel.Text = "You won $"..GameDataModule:AddCommasToNumber(winnings).."!";
				if playerData[2]:IsA("Player") then
					ProfileManager.AdjustCurrency(playerData[2], "Cash", winnings);
					PlayerAction:FireClient(playerData[2], "roundEnded", {winnings});
					if zoneMultiplier == 5 then
						playerData[4] = winnings;
					end
				end
			end
		end
		for each, playerData in pairs(GameData) do
			if playerData[4] then
				Jackpot:FireAllClients(playerData[2], playerData[4]);
			end
		end
		
		ShuffleZones();
		
		task.wait(Plinko:GetAttribute("TimeBeforeNewRound"));
	end
	
	--End the current round and start the next round if players are still present
	if Plinko:GetAttribute("RoundStarted") then
		ResetTable();

		for each, stool in pairs(Stools:GetChildren()) do
			if stool.Seat.Occupant and stool.Seat.Occupant.Parent then
				if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
					local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
					if player and player:GetAttribute("Cash") >= Plinko:GetAttribute("MinCash") then
						PlayerAction:FireClient(player, "roundStarting");
					end
				end
			end
		end
		
		for each, npc in pairs(NPCs:GetChildren()) do
			if npc:FindFirstChild("PlayGame") then
				npc.PlayGame.Response:Fire("BetPlinko");
			end
		end
	end
end

PlayerAction.OnServerEvent:Connect(function(actualPlayer, action, data)
	local player = GetPlayerStoolName(actualPlayer);
	if player and not ProcessingEvent and not Plinko:GetAttribute("RoundStarted") then
		ProcessingEvent = true;
		
		if action == "Bet" then
			if typeof(data[1]) == "Vector3" and typeof(data[2]) == "number" then
				local fixedBet = math.floor(data[2]);
				if (fixedBet >= Plinko:GetAttribute("MinCash") and fixedBet <= Plinko:GetAttribute("MaxCash")) then
					if actualPlayer:GetAttribute("Cash") >= fixedBet then
						--if PlinkoInPlayingArea(data[1]) then --stops exploiters from placing plinkos outside of playing area (hopefully)
							SpawnPlinko(data[1], fixedBet, actualPlayer);
						--end
					end
				end
			end
		elseif action == "Cancel" then
			DeletePlinko(actualPlayer);
		end
		
		ProcessingEvent = false;
	end
end)

Plinko:GetAttributeChangedSignal("RoundPending"):Connect(function()
	if Plinko:GetAttribute("RoundPending") then
		local success = true;

		for i = Plinko:GetAttribute("TimeBetweenDrops"), 0, -1 do
			if not Plinko:GetAttribute("RoundPending") then
				success = false;
				break;
			end

			if i ~= 0 then
				Sign.SurfaceGui.TextLabel.Text = i;
				for i = 0, 1, 0.05 do
					if not Plinko:GetAttribute("RoundPending") then
						break;
					end
					task.wait(0.05);
				end
			end
		end

		if success then
			StartNewRound();
		end
	end
end)

local function Initialize()
	for each, podium in pairs(Podiums:GetChildren()) do
		podium.MinCash.SurfaceGui.TextLabel.Text = "MIN: $"..GameDataModule:AddCommasToNumber(Plinko:GetAttribute("MinCash"));
		podium.MaxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(Plinko:GetAttribute("MaxCash"));
		podium.MinCash.Fire.Enabled = Plinko:GetAttribute("HighRoller");
		podium.MaxCash.Fire.Enabled = Plinko:GetAttribute("HighRoller");
		podium.Wedge.Material = Plinko:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
		podium.Base.Material = Plinko:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	end

	ResetTable();
	ShuffleZones();

	for each, stool in pairs(Stools:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()	
			if stool.Seat.Occupant then
				Plinko:SetAttribute("PlayersAtTable", Plinko:GetAttribute("PlayersAtTable") + 1);

				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
						if player:GetAttribute("Cash") >= Plinko:GetAttribute("MinCash") then
							local gui = PlinkoGui:Clone();
							gui.ActualTable.Value = Plinko;
							gui.Parent = player.PlayerGui;
						end
					end
				end
			else
				RemovePlayerFromTable(stool.Name);
			end
			
			if Plinko:GetAttribute("PlayersAtTable") == 0 and Plinko:GetAttribute("NPCsAtGame") == 0 then
				ResetTable();
			end
		end)
	end
end

PlayNPC.Event:Connect(function(npc, action)
	if action == "leaving" then
		Plinko:SetAttribute("NPCsAtGame", Plinko:GetAttribute("NPCsAtGame") - 1);
		DeletePlinko(npc);
	elseif action == "bet" then
		if not Plinko:GetAttribute("RoundStarted") then
			SpawnPlinko(nil, RNG:NextInteger(Plinko:GetAttribute("MinCash"), Plinko:GetAttribute("MaxCash")), npc);
		end
	end
end)

Initialize();