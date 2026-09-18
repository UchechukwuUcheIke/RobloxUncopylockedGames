local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
local GameFunctions = require(ServerStorage.Modules.GameFunctions);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local GameDataModule = require(ReplicatedStorage.Modules.GameData);
local Jackpot = ReplicatedStorage.Remotes.Jackpot;
local tableGame = script.Parent;
local tableGameRemotes = tableGame.Remotes;
local functional = tableGame.Functional;
local markers = tableGame.Markers;
local PlayNPC = tableGameRemotes.PlayNPC;
local PlayerAction = tableGameRemotes.PlayerAction;
local selections = functional.Selections;
local stools = functional.Stools;
local ballModel = functional.Ball;
local wheelModel = functional.Wheel;
local minCash = functional.MinCash;
local maxCash = functional.MaxCash;
local number = functional.Number;
local soundBox = functional.SoundBox;
local countdown = functional.Countdown;
local ballStartPosition = ballModel.Ball.Position;

local random = Random.new();
local gameData = {}; --{player, actualPlayer, betAmount, selection}
local processingEvent = false;
local outcomeNumber;
local winningNumber;
local winningSelection;

local function resetTable()
	tableGame:SetAttribute("RoundPending", false);
	tableGame:SetAttribute("RoundStarted", false);
	tableGame:SetAttribute("BallSpinning", false);
	tableGame:SetAttribute("BallSpeed", -5);
	gameData = {};
	outcomeNumber = nil;
	winningNumber = nil;
	winningSelection = nil;
	
	number.SurfaceGui.TextLabel.Text = "";
	countdown.SurfaceGui.TextLabel.Text = "";
	for _, sound in pairs(soundBox:GetChildren()) do
		sound:Stop();
	end
	wheelModel.Spinner.WheelBase.AngularVelocity.AngularVelocity = Vector3.new(0, 0, 0);
	
	for each, marker in pairs(markers:GetChildren()) do
		marker:Destroy();
	end
end

local function getActualPlayerStool(actualPlayer)
	if actualPlayer:IsA("Player") then
		for each, stool in pairs(functional.Stools:GetChildren()) do
			if stool.Seat.Occupant then
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player == actualPlayer then
					return stool.Name;
				end
			end	
		end
	else
		return actualPlayer.Name;
	end
end

local function removePlayerFromTable(player)
	tableGame:SetAttribute("PlayersAtTable", tableGame:GetAttribute("PlayersAtTable") - 1);
	
	for index, playerData in pairs(gameData) do
		if playerData[1] == player then
			table.remove(gameData, index);
		end
	end
end

local function findPlayerMarker(actualPlayer, location)
	for each, marker in pairs(markers:GetChildren()) do
		if marker:GetAttribute("Location") == location and marker.BillboardGui.Player.Text == actualPlayer.Name then
			return marker;
		end
	end
end

local function getPlayerMarkerCount(actualPlayer)
	local markerCount = 0;
	for each, marker in pairs(markers:GetChildren()) do
		if marker.BillboardGui.Player.Text == actualPlayer.Name then
			markerCount += 1;
		end
	end
	return markerCount;
end

local function togglePlayerMarker(toggle, actualPlayer, location, betAmount)
	if toggle then
		local currentMarker = findPlayerMarker(actualPlayer, location);
		if not currentMarker then
			local marker = script.Marker:Clone();
			local selection = selections[location];
			local positionX = (selection:GetAttribute("SpecialBet") and selection.Position.X) or random:NextNumber(selection.Position.X + 0.5, selection.Position.X - 0.5);
			local positionZ = (selection:GetAttribute("SpecialBet") and selection.Position.Z) or random:NextNumber(selection.Position.Z + 0.5, selection.Position.Z - 0.5);
			
			marker.BillboardGui.Player.Text = actualPlayer.Name;
			marker.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(betAmount);
			marker.Position = Vector3.new(positionX, selection.Position.Y, positionZ);
			marker.Transparency = 0;
			marker.BillboardGui.Enabled = true;
			marker:SetAttribute("Location", location);
			marker:SetAttribute("Bet", betAmount);
			marker:SetAttribute("OriginalPosition", marker.Position);
			marker.Parent = markers;
			
			ProfileManager.AdjustCurrency(actualPlayer, "Cash", -betAmount);
			table.insert(gameData, {getActualPlayerStool(actualPlayer).Name, actualPlayer, betAmount, location});
		else
			ProfileManager.AdjustCurrency(actualPlayer, "Cash", currentMarker:GetAttribute("Bet") - betAmount);
			currentMarker:SetAttribute("Bet", betAmount);
			currentMarker.BillboardGui.Bet.Text = "$"..GameDataModule:AddCommasToNumber(betAmount);
			for index, playerData in pairs(gameData) do
				if playerData[2] == actualPlayer and playerData[4] == location then
					playerData[3] = currentMarker:GetAttribute("Bet");
					break;
				end
			end
		end	
	else
		local currentMarker = findPlayerMarker(actualPlayer, location);
		if currentMarker then
			ProfileManager.AdjustCurrency(actualPlayer, "Cash", currentMarker:GetAttribute("Bet"));
			currentMarker:Destroy();
			for index, playerData in pairs(gameData) do
				if playerData[2] == actualPlayer and playerData[4] == location then
					table.remove(gameData, index);
					break;
				end
			end
		end
	end
end

local function warpBallToClosestHolder()
	local closestHolder, closestDistance = nil, nil;

	for each, slot in pairs(wheelModel.Spinner.Holders:GetChildren()) do
		if not closestHolder then
			closestHolder = slot
			closestDistance = (ballModel.Ball.Position - slot.Position).Magnitude
		elseif (ballModel.Ball.Position - slot.Position).Magnitude < closestDistance then
			closestHolder = slot
			closestDistance = (ballModel.Ball.Position - slot.Position).Magnitude
		end
	end
	
	ballModel.Ball.Position = closestHolder.Position;
	return closestHolder;
end

local function startNewRound()
	--Start a new round
	tableGame:SetAttribute("RoundPending", false);
	tableGame:SetAttribute("RoundStarted", true);
	tableGame:SetAttribute("BallSpinning", true);
	countdown.SurfaceGui.TextLabel.Text = "";
	number.SurfaceGui.TextLabel.Text = "";
	
	--Spin the roulette wheel
	GameFunctions:PlaySound("Roulette", "Spin", soundBox, true, false, false);
	if tableGame:GetAttribute("PlayersAtTable") > 0 then
		wheelModel.Spinner.WheelBase.AngularVelocity.AngularVelocity = Vector3.new(0, 3, 0);
		task.wait(GameFunctions:GetWaitTimes("roulettePhase"));
	end
	if tableGame:GetAttribute("PlayersAtTable") > 0 then
		wheelModel.Spinner.WheelBase.AngularVelocity.AngularVelocity = Vector3.new(0, 2, 0);
		tableGame:SetAttribute("BallSpeed", -3);
		task.wait(GameFunctions:GetWaitTimes("roulettePhase"));
	end
	if tableGame:GetAttribute("PlayersAtTable") > 0 then
		wheelModel.Spinner.WheelBase.AngularVelocity.AngularVelocity = Vector3.new(0, 1, 0);
		tableGame:SetAttribute("BallSpeed", -1);
		task.wait(GameFunctions:GetWaitTimes("roulettePhase"));
	end
	
	--Stop the roulette wheel and get the winning selection
	GameFunctions:StopSound("Roulette", "Spin", soundBox);
	if tableGame:GetAttribute("PlayersAtTable") > 0 then
		GameFunctions:PlaySound("Roulette", "Stop", soundBox, false, false, false);
		wheelModel.Spinner.WheelBase.AngularVelocity.AngularVelocity = Vector3.new(0, 0, 0);
		tableGame:SetAttribute("BallSpinning", false);
		task.wait(0.5);
		winningNumber = warpBallToClosestHolder();
		winningSelection = GameDataModule:GetRouletteResult(winningNumber.Name);
		task.wait(1);
	end
	
	--Display the winning selection and payout any winning bets
	local playerWinnings = {};
	local jackpots = {};
	
	if tableGame:GetAttribute("PlayersAtTable") > 0 then
		if winningNumber.Color == Color3.fromRGB(27, 42, 53) then
			number.SurfaceGui.TextLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255);
		else
			number.SurfaceGui.TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0);
		end
		number.SurfaceGui.TextLabel.TextColor3 = winningNumber.Color;
		number.SurfaceGui.TextLabel.Text = winningNumber.Name;
		
		for each, playerData in pairs(gameData) do
			local payout = 0;
			
			if playerWinnings[playerData[2]] == nil then
				playerWinnings[playerData[2]] = 0;
			end
			
			for each, wonSelection in pairs(winningSelection) do
				if playerData[4] == wonSelection then
					local currentMarker = findPlayerMarker(playerData[2], wonSelection);
					local multiplier = selections[wonSelection]:GetAttribute("PayoutMultiplier");
					
					payout = playerData[3] * multiplier;
					currentMarker.BillboardGui.Bet.Text = "";
					currentMarker.BillboardGui.Winnings.Text = "+$"..GameDataModule:AddCommasToNumber(payout);
					currentMarker.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(100, 255, 100);
					
					if multiplier >= 10 and playerData[2]:IsA("Player") then
						jackpots[playerData[2]] = true;
					end
					
					break;
				end
			end
			
			playerWinnings[playerData[2]] = playerWinnings[playerData[2]] + payout;
			ProfileManager.AdjustCurrency(playerData[2], "Cash", payout);
		end
		
		for player, winnings in pairs(playerWinnings) do
			if player:IsA("Player") then
				if jackpots[player] then
					Jackpot:FireAllClients(player, winnings);
				end
			end
		end
		
		for each, marker in pairs(markers:GetChildren()) do
			if marker.BillboardGui.Winnings.Text == "" then
				marker.BillboardGui.Bet.Text = "";
				marker.BillboardGui.Winnings.Text = "-$"..GameDataModule:AddCommasToNumber(marker:GetAttribute("Bet"));
				marker.BillboardGui.Winnings.TextColor3 = Color3.fromRGB(255, 100, 100);
			end
		end
		
		local playersFired = {};
		for player, playerData in pairs(gameData) do
			if playerData[2]:IsA("Player") and not playersFired[playerData[2]] then
				playersFired[playerData[2]] = true;
				PlayerAction:FireClient(playerData[2], "roundEnded", {playerWinnings[playerData[2]]});
			end
		end
		
		task.wait(tableGame:GetAttribute("TimeBeforeNewRound"));
	end
	
	--End the current round and start the next round if players are still present
	if tableGame:GetAttribute("PlayersAtTable") > 0 then
		resetTable();

		for each, stool in pairs(functional.Stools:GetChildren()) do
			if stool.Seat.Occupant then
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player and player:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash") then
					if not tableGame:GetAttribute("RoundPending") then
						tableGame:SetAttribute("RoundPending", true);
					end
					PlayerAction:FireClient(player, "roundStarting", {});
				end
			end
		end

		if tableGame:GetAttribute("NPCsAtGame") > 0 then
			if not tableGame:GetAttribute("RoundStarted") then
				tableGame:SetAttribute("RoundPending", true);
			end

			for each, npc in pairs(tableGame.NPCs:GetChildren()) do
				if npc:FindFirstChild("PlayGame") then
					npc.PlayGame.Response:Fire("BetRoulette");
				end
			end
		end
	end
end

PlayerAction.OnServerEvent:Connect(function(actualPlayer, action, data)
	if getActualPlayerStool(actualPlayer) and not processingEvent and not tableGame:GetAttribute("RoundStarted") then
		processingEvent = true;
		
		if action == "Bet" then
			if typeof(data[1]) == "string" and typeof(data[2]) == "number"then
				if (data[2] >= tableGame:GetAttribute("MinCash") and data[2] <= tableGame:GetAttribute("MaxCash")) and selections:FindFirstChild(data[1]) then
					if actualPlayer:GetAttribute("Cash") >= data[2] then
						if getPlayerMarkerCount(actualPlayer) < tableGame:GetAttribute("BetLimit") then
							data[2] = math.floor(data[2]);
							togglePlayerMarker(true, actualPlayer, data[1], data[2]);
						end
					end
				end
			end
		elseif action == "Cancel" then
			if typeof(data[1]) == "string" then
				if selections:FindFirstChild(data[1]) then
					togglePlayerMarker(false, actualPlayer, data[1]);
				end
			end
		end
		
		processingEvent = false;
	end
end)

tableGame:GetAttributeChangedSignal("RoundPending"):Connect(function()
	if tableGame:GetAttribute("RoundPending") then
		local success = true;
		
		for i = tableGame:GetAttribute("TimeBetweenSpins"), 0, -1 do
			if not tableGame:GetAttribute("RoundPending") then
				success = false;
				break;
			end
			
			if i ~= 0 then
				countdown.SurfaceGui.TextLabel.Text = i;
				for i = 0, 1, 0.05 do
					if not tableGame:GetAttribute("RoundPending") then
						break;
					end
					task.wait(0.05);
				end
			end
		end

		if success then
			startNewRound();
		end
	end
end)

tableGame:GetAttributeChangedSignal("BallSpinning"):Connect(function()
	coroutine.wrap(function()
		local currentPivot = ballModel:GetPivot();
		
		if tableGame:GetAttribute("BallSpinning") then
			ballModel.Ball.Position = ballStartPosition;
			ballModel:PivotTo(ballModel.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(random:NextNumber(-180, 180)), 0));
			while tableGame:GetAttribute("BallSpinning") do
				ballModel:PivotTo(ballModel.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(tableGame:GetAttribute("BallSpeed")), 0));
				task.wait(1/60);
			end
		end
	end)()
end)

tableGame:GetAttributeChangedSignal("NPCsAtGame"):Connect(function()
	if tableGame:GetAttribute("NPCsAtGame") ~= 0 then
		if not tableGame:GetAttribute("RoundStarted") then
			tableGame:SetAttribute("RoundPending", true);
		end
	elseif tableGame:GetAttribute("PlayersAtTable") == 0 then
		resetTable();
	end
end)

local function initialize()
	minCash.SurfaceGui.TextLabel.Text = "MIN: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MinCash"));
	maxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MaxCash"));
	tableGame.Functional.MinCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
	tableGame.Functional.MaxCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
	tableGame.Decoration.Table.Base.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	tableGame.Decoration.Table.Ring.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	tableGame.Decoration.Table.Table.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Salt or Enum.Material.Plastic;
	wheelModel.Spinner.WheelBase:SetNetworkOwner(nil);
	
	resetTable();
	
	for each, selection in pairs(selections:GetChildren()) do
		if selection:GetAttribute("SpecialBet") then
			selection.Transparency = 1;
			selection.SurfaceGui.Enabled = false;
		end
	end
	
	for each, barrier in pairs(tableGame.Functional:GetChildren()) do
		if barrier.Name == "Barrier" then
			barrier:SetAttribute("OriginalPosition", barrier.Position);
		end
	end
	
	for each, stool in pairs(functional.Stools:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()	
			if stool.Seat.Occupant then
				tableGame:SetAttribute("PlayersAtTable", tableGame:GetAttribute("PlayersAtTable") + 1);
				
				if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
					local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
					if player then
						if player:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash") then
							if not tableGame:GetAttribute("RoundStarted") then
								tableGame:SetAttribute("RoundPending", true);
							end

							local gui = script.Roulette:Clone();
							gui.ActualTable.Value = tableGame;
							gui.Parent = player.PlayerGui;
						end
					end
				end
			else
				removePlayerFromTable(stool.Name);
			end

			if tableGame:GetAttribute("PlayersAtTable") == 0 and tableGame:GetAttribute("NPCsAtGame") == 0 then
				resetTable();
			end
		end)
	end
end

PlayNPC.Event:Connect(function(npc, action)
	if action == "leaving" then
		tableGame:SetAttribute("NPCsAtGame", tableGame:GetAttribute("NPCsAtGame") - 1);
	elseif action == "bet" then
		if not tableGame:GetAttribute("RoundStarted") then
			for i = 1, random:NextInteger(1, 3) do
				local allLocations = selections:GetChildren();
				local randomLocation = allLocations[random:NextInteger(1, #allLocations)].Name;
				local randomBet = random:NextInteger(tableGame:GetAttribute("MinCash"), tableGame:GetAttribute("MaxCash"));
				togglePlayerMarker(true, npc, randomLocation, randomBet);
				task.wait(random:NextNumber(1, 3));
			end
		end
	end
end)

initialize();