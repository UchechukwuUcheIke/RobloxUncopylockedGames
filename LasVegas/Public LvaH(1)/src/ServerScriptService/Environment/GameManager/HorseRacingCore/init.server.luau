local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");
local Players = game:GetService("Players");
local GameFunctions = require(ServerStorage.Modules.GameFunctions);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local GameDataModule = require(ReplicatedStorage.Modules.GameData);
local tableGame = script.Parent;
local tableGameRemotes = tableGame.Remotes;
local SetOutcome = tableGameRemotes.SetOutcome;
local PlayerAction = tableGameRemotes.PlayerAction;
local functional = tableGame.Functional;
local backboard = functional.Backboard;
local seats = functional.Seats;
local countdownLabel = backboard.SurfaceGui.Countdown;
local horses = backboard.SurfaceGui.Horses;
local positions = backboard.SurfaceGui.Positions;

local random = Random.new();
local gameData = {}; --{player, actualPlayer, betAmount, firstSelection, secondSelection, thirdSelection}
local processingEvent = false;

local function resetTable()
	tableGame:SetAttribute("RoundStarted", false);
	tableGame:SetAttribute("RoundPending", false);
	gameData = {};
	countdownLabel.Text = "";
	
	for each, horse in pairs(horses:GetChildren()) do
		horse.Position = positions["Start"..horse.Name].Position;
		positions["Place"..horse.Name].Text = "";
		horse:SetAttribute("Speed", 0);
		horse:SetAttribute("BoostClock", 0);
		horse:SetAttribute("Place", 0);
	end
end

local function horsesAreStillRacing()
	for each, horse in pairs(horses:GetChildren()) do
		if horse:GetAttribute("Place") == 0 then
			return true;
		end
	end
end

local function getActualPlayerStool(actualPlayer)
	for each, stool in pairs(seats:GetChildren()) do
		if stool.Seat.Occupant then
			local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
			if player == actualPlayer then
				return stool.Name;
			end
		end	
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

local function togglePlayerSelection(toggle, player, actualPlayer, betAmount, firstSelection, secondSelection, thirdSelection)
	local indexOfData;
	for index, playerData in pairs(gameData) do
		if playerData[2] == actualPlayer then
			indexOfData = index;
			break;
		end
	end
	
	if toggle then
		if indexOfData then
			ProfileManager.AdjustCurrency(actualPlayer, "Credits", gameData[indexOfData][3] - betAmount);
			gameData[indexOfData][3] = betAmount;
			gameData[indexOfData][4] = firstSelection;
			gameData[indexOfData][5] = secondSelection;
			gameData[indexOfData][6] = thirdSelection;
		else
			ProfileManager.AdjustCurrency(actualPlayer, "Credits", -betAmount);
			table.insert(gameData, {player, actualPlayer, betAmount, firstSelection, secondSelection, thirdSelection});
		end
	else
		
	end
end

local function startNewRound()
	--Start a new round
	tableGame:SetAttribute("RoundStarted", true);
	tableGame:SetAttribute("RoundPending", false);
	countdownLabel.Text = "";
	
	--Dictate the speeds of the horses and what order they will finsih in
	if tableGame:GetAttribute("RoundStarted") then
		local speeds = {};
		for i = 1, 8 do
			table.insert(speeds, random:NextNumber(0.0005, 0.0008));
		end
		
		for each, horse in pairs(horses:GetChildren()) do
			local index = random:NextInteger(1, #speeds)
			local speed = speeds[index];
			horse:SetAttribute("Speed", speed);
			table.remove(speeds, index);
		end
	end
	
	--Move the horses to the finish line at their determined speeds
	if tableGame:GetAttribute("RoundStarted") then
		local place = 0;
		
		while horsesAreStillRacing() do
			for each, horse in pairs(horses:GetChildren()) do
				if not horse:GetAttribute("Finished") then
					local speed = horse:GetAttribute("Speed");
					
					if horse:GetAttribute("BoostClock") > 0 then
						speed += 0.0005;
						horse:SetAttribute("BoostClock", horse:GetAttribute("BoostClock") - 1);
					elseif random:NextInteger(1, 500) == 1 then
						speed += 0.0005;
						horse:SetAttribute("BoostClock", random:NextInteger(80, 120));
					end
					
					if horse:GetAttribute("Place") == 0 then
						horse.Position = UDim2.new(horse.Position.X.Scale + (speed + random:NextNumber(-0.0003, 0)), 0, horse.Position.Y.Scale, 0);
						if horse.Position.X.Scale >= positions["End"..horse.Name].Position.X.Scale then
							place += 1;
							horse:SetAttribute("Place", place);
							horse.Position = positions["End"..horse.Name].Position;
							if place == 1 then
								positions["Place"..horse.Name].Text = "1st";
							elseif place == 2 then
								positions["Place"..horse.Name].Text = "2nd";
							elseif place == 3 then
								positions["Place"..horse.Name].Text = "3rd";
							end
						end
					end
				end
			end
			
			if not tableGame:GetAttribute("RoundStarted") then
				break;
			end
			
			task.wait();
		end
	end
	
	--Declare the winner and payout any winning bets
	if tableGame:GetAttribute("RoundStarted") then
		local firstPlace;
		local secondPlace;
		local thirdPlace;
		
		for each, horse in pairs(horses:GetChildren()) do
			if horse:GetAttribute("Place") == 1 then
				firstPlace = tonumber(horse.Name);
			elseif horse:GetAttribute("Place") == 2 then
				secondPlace = tonumber(horse.Name);
			elseif horse:GetAttribute("Place") == 3 then
				thirdPlace = tonumber(horse.Name);
			end
		end
		
		for each, playerData in pairs(gameData) do
			local payout = playerData[3];
			local correctSelections = 0;

			if playerData[4] == firstPlace then
				correctSelections += 1;
			end
			if playerData[5] == secondPlace then
				correctSelections += 1;
			end
			if playerData[6] == thirdPlace then
				correctSelections += 1;
			end
			
			if correctSelections == 1 then
				payout *= 8;
			elseif correctSelections == 2 then
				payout *= 25;
			elseif correctSelections == 3 then
				payout *= 100;
			end

			ProfileManager.AdjustCurrency(playerData[2], "Cash", payout);
			PlayerAction:FireClient(playerData[2], "winnings", {payout});
		end
		
		task.wait(tableGame:GetAttribute("TimeBetweenRaces"));
	end
	
	--End the current round and start the next round if players are still present
	if tableGame:GetAttribute("RoundStarted") then
		resetTable();

		for each, stool in pairs(seats:GetChildren()) do
			if stool.Seat.Occupant then
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player and player:GetAttribute("Credits") >= tableGame:GetAttribute("MinCredits") then
					if not tableGame:GetAttribute("RoundPending") then
						tableGame:SetAttribute("RoundPending", true);
						break;
					end
				end
			end
		end
	end
end

PlayerAction.OnServerEvent:Connect(function(actualPlayer, action, data)
	local player = getActualPlayerStool(actualPlayer);
	if player and not processingEvent and not tableGame:GetAttribute("RoundStarted") then
		processingEvent = true;

		if action == "Bet" then
			if typeof(data[1]) == "number" and typeof(data[2]) == "number" and typeof(data[3]) == "number" and typeof(data[4]) == "number" then
				if (data[1] >= tableGame:GetAttribute("MinCredits") and data[1] <= tableGame:GetAttribute("MaxCredits")) then
					if actualPlayer:GetAttribute("Credits") >= data[1] then
						local betAmount = math.floor(data[1]);
						local firstSelection = math.floor(data[2]);
						local secondSelection = math.floor(data[3]);
						local thirdSelection = math.floor(data[4]);
						togglePlayerSelection(true, player, actualPlayer, betAmount, firstSelection, secondSelection, thirdSelection);
					end
				end
			end
		end

		processingEvent = false;
	end
end)

tableGame:GetAttributeChangedSignal("RoundPending"):Connect(function()
	if tableGame:GetAttribute("RoundPending") then
		local success = true;

		for i = tableGame:GetAttribute("TimeBeforeRaceStarts"), 0, -1 do
			if not tableGame:GetAttribute("RoundPending") then
				success = false;
				break;
			end

			if i ~= 0 then
				countdownLabel.Text = i;
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

local function initialize()
	if tableGame:GetAttribute("MinCredits") == 1 then
		backboard.SurfaceGui.MinCredits.Text = "MIN: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MinCredits"));
	else
		backboard.SurfaceGui.MinCredits.Text = "MIN: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MinCredits"));
	end
	
	if tableGame:GetAttribute("MaxCredits") == 1 then
		backboard.SurfaceGui.MaxCredits.Text = "MAX: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MaxCredits"));
	else
		backboard.SurfaceGui.MaxCredits.Text = "MAX: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MaxCredits"));
	end
	
	resetTable();
	
	for each, stool in pairs(seats:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()	
			if stool.Seat.Occupant then
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player and player:GetAttribute("Credits") >= tableGame:GetAttribute("MinCredits") then
					tableGame:SetAttribute("PlayersAtTable", tableGame:GetAttribute("PlayersAtTable") + 1);

					if not tableGame:GetAttribute("RoundStarted") then
						tableGame:SetAttribute("RoundPending", true);
					end

					local gui = script.HorseRacing:Clone();
					gui.ActualTable.Value = tableGame;
					gui.Parent = player.PlayerGui;
				end
			else
				removePlayerFromTable(stool.Name);
			end

			if tableGame:GetAttribute("PlayersAtTable") == 0 then
				resetTable();
			end
		end)
	end
end
initialize();