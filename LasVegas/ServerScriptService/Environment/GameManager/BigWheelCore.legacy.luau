local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");
local Players = game:GetService("Players");
local GameFunctions = require(ServerStorage.Modules.GameFunctions);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local GameDataModule = require(ReplicatedStorage.Modules.GameData);
local Jackpot = ReplicatedStorage.Remotes.Jackpot;
local tableGame = script.Parent;
local tableGameRemotes = tableGame.Remotes;
local PlayNPC = tableGameRemotes.PlayNPC;
local PlayerAction = tableGameRemotes.PlayerAction;
local functional = tableGame.Functional;
local sign = functional.Sign;
local wheel = functional.Wheel;
local soundBox = functional.SoundBox;
local stools = functional.Stools;
local podiums = functional.Podiums;
local pointer = functional.Pointer;

local random = Random.new();
local gameData = {}; --{player, actualPlayer, betAmount, selection}
local processingEvent = false;
local timeSinceLastOutcome;
local roundEnded = false;

local function resetTable()
	tableGame:SetAttribute("SlowingDown", false);
	tableGame:SetAttribute("RoundPending", false);
	tableGame:SetAttribute("RoundStarted", false);
	tableGame:SetAttribute("WheelSpinning", false);
	timeSinceLastOutcome = nil;
	roundEnded = false;
	gameData = {};
	
	sign.SurfaceGui.TextLabel.Text = "";
	sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	for each, podium in pairs(podiums:GetChildren()) do
		podium.Sign.SurfaceGui.TextLabel.Text = "";
		podium.Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
	end
	for each, sound in pairs(soundBox:GetChildren()) do
		sound:Stop();
	end
	for each, part in pairs(pointer:GetChildren()) do
		part.CanCollide = false;
	end
	for each, peg in pairs(wheel:GetChildren()) do
		if peg:GetAttribute("Peg") then
			peg.Light.PointLight.Enabled = false;
			peg.Light.PointLight.Color = peg:GetAttribute("NormalColor");
			peg.Light.Material = Enum.Material.SmoothPlastic;
			peg.Light.Color = peg:GetAttribute("NormalColor");
			peg.Label.Color = peg:GetAttribute("NormalColor");
			peg.Label.SurfaceGui.Number.BorderColor3 = peg:GetAttribute("NormalColor");
			peg.Label.SurfaceGui.Number.Text = peg:GetAttribute("NormalLabel");
		end
	end
	tableGame:SetAttribute("WheelSpeed", 0);
end

local function getWinningPeg(jackpot)
	for each, peg in pairs(wheel:GetChildren()) do
		if peg:GetAttribute("Peg") then
			if peg.Light.Material == Enum.Material.Neon then
				if jackpot then
					return peg:GetAttribute("JackpotMultiplier")
				else
					local selection;

					if peg.Label.SurfaceGui.Number.Text == "2x" then
						selection = "Green"
					elseif peg.Label.SurfaceGui.Number.Text == "4x" then
						selection = "Blue"
					elseif peg.Label.SurfaceGui.Number.Text == "6x" then
						selection = "Red"
					elseif peg.Label.SurfaceGui.Number.Text == "10x" then
						selection = "Yellow"
					else
						selection = "JACKPOT"
					end

					return {selection, peg:GetAttribute("NormalMultiplier")}
				end
			end
		end
	end
end

local function getActualPlayerStool(actualPlayer)
	for each, stool in pairs(functional.Stools:GetChildren()) do
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
			podiums[player].Sign.SurfaceGui.TextLabel.Text = "";
		end
	end
end

local function removeNPCFromTable(npc)
	tableGame:SetAttribute("NPCsAtGame", tableGame:GetAttribute("NPCsAtGame") - 1);

	for index, playerData in pairs(gameData) do
		if playerData[1] == npc.Name then
			table.remove(gameData, index);
			podiums[npc.Name].Sign.SurfaceGui.TextLabel.Text = "";
		end
	end
end

local function togglePlayerSelection(toggle, player, actualPlayer, location, betAmount)
	local indexOfData;
	for index, playerData in pairs(gameData) do
		if playerData[2] == actualPlayer then
			indexOfData = index;
			break;
		end
	end

	if toggle then
		if indexOfData then
			ProfileManager.AdjustCurrency(actualPlayer, "Cash", gameData[indexOfData][3] - betAmount);
			gameData[indexOfData][3] = betAmount;
			gameData[indexOfData][4] = location;
		else
			ProfileManager.AdjustCurrency(actualPlayer, "Cash", -betAmount);
			table.insert(gameData, {player, actualPlayer, betAmount, location});
		end
		podiums[player].Sign.SurfaceGui.TextLabel.Text = "You bet $"..GameDataModule:AddCommasToNumber(betAmount).." on "..location.."!";
		podiums[player].Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
	elseif indexOfData then
		ProfileManager.AdjustCurrency(actualPlayer, "Cash", gameData[indexOfData][3]);
		table.remove(gameData, indexOfData);
		podiums[player].Sign.SurfaceGui.TextLabel.Text = "";
	end
end

local function spinWheel(jackpot)
	if tableGame:GetAttribute("RoundStarted") then
		--Start the spin
		tableGame:SetAttribute("SlowingDown", false);

		if not jackpot then
			sign.SurfaceGui.TextLabel.Text = "LET'S GO!!!";
			GameFunctions:PlaySound("BigWheel", "Bell", soundBox, false, false, false);
		else
			sign.SurfaceGui.TextLabel.Text = "BIG WIN!!!";
		end

		GameFunctions:PlaySound("BigWheel", "Wheel", soundBox, false, false, false);
		for each, peg in pairs(wheel:GetChildren()) do
			if peg:GetAttribute("Peg") then
				peg.Light.Material = Enum.Material.Neon;
				peg.Light.PointLight.Enabled = true;
			end
		end
		for each, part in pairs(pointer:GetChildren()) do
			part.CanCollide = false;
		end
		
		tableGame:SetAttribute("WheelSpeed", random:NextNumber(3, 5));

		--Slow down the wheel
		if tableGame:GetAttribute("RoundStarted") then
			repeat task.wait(); until tableGame:GetAttribute("WheelSpeed") <= 2 or not tableGame:GetAttribute("RoundStarted")

			--Activate the pointer
			if tableGame:GetAttribute("RoundStarted") then
				sign.SurfaceGui.TextLabel.Text = "";
				for each, part in pairs(pointer:GetChildren()) do
					part.CanCollide = true;
				end
				tableGame:SetAttribute("SlowingDown", true);

				timeSinceLastOutcome = os.time();
				repeat task.wait(); until not timeSinceLastOutcome or os.time() - timeSinceLastOutcome >= 5 or not tableGame:GetAttribute("RoundStarted")
			end
		end
	end
end

local function startNewRound()
	--Start a new round
	tableGame:SetAttribute("RoundPending", false);
	tableGame:SetAttribute("RoundStarted", true);
	
	--Start spinning the wheel and get the winning selection
	spinWheel(false);

	--If jackpot then do a jackpot spin, otherwise payout any winning bets
	if tableGame:GetAttribute("RoundStarted") then
		local winData = getWinningPeg(false);

		if winData[1] == "JACKPOT" then
			GameFunctions:PlaySound("BigWheel", "Alarm", soundBox, false, true, false);
			
			if tableGame:GetAttribute("RoundStarted") then
				for each, peg in pairs(wheel:GetChildren()) do
					if peg:GetAttribute("Peg") then
						peg.Light.Color = peg:GetAttribute("JackpotColor");
						peg.Label.Color = peg:GetAttribute("JackpotColor");
						peg.Light.PointLight.Color = peg:GetAttribute("JackpotColor");
						peg.Label.SurfaceGui.Number.BorderColor3 = peg:GetAttribute("JackpotColor");
						peg.Label.SurfaceGui.Number.Text = peg:GetAttribute("JackpotLabel");
						GameFunctions:PlaySound("BigWheel", "Upgrade", soundBox, false, false, false);
						task.wait(0.1);
					end
				end
			end
			
			spinWheel(true);
			
			if tableGame:GetAttribute("RoundStarted") then
				roundEnded = true;
				
				local multiplier = getWinningPeg(true);
				GameFunctions:PlaySound("BigWheel", "Tada", soundBox, false, false, false);
				for each, playerData in pairs(gameData) do
					local payout = playerData[3] * multiplier;
					ProfileManager.AdjustCurrency(playerData[2], "Cash", payout);
					podiums[playerData[1]].Sign.SurfaceGui.TextLabel.Text = "You won $"..GameDataModule:AddCommasToNumber(payout).."!";
					podiums[playerData[1]].Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0);
					
					if playerData[2]:IsA("Player") then
						PlayerAction:FireClient(playerData[2], "winnings", {"You won $"..GameDataModule:AddCommasToNumber(payout).."!"});
					end
					
					if playerData[2]:IsA("Player") then
						Jackpot:FireAllClients(playerData[2], payout);
					end
				end
			end
		else
			roundEnded = true;
			
			GameFunctions:PlaySound("BigWheel", "Tada", soundBox, false, false, false);
			for each, playerData in pairs(gameData) do
				local payout = 0;

				if playerData[4] == winData[1] then
					payout = playerData[3] * winData[2];
				end

				ProfileManager.AdjustCurrency(playerData[2], "Cash", payout);
				
				if payout > 0 then
					podiums[playerData[1]].Sign.SurfaceGui.TextLabel.Text = "You won $"..GameDataModule:AddCommasToNumber(payout).."!";
					podiums[playerData[1]].Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100);
					if playerData[2]:IsA("Player") then
						PlayerAction:FireClient(playerData[2], "winnings", {"You won $"..GameDataModule:AddCommasToNumber(payout).."!"});
					end
				else
					podiums[playerData[1]].Sign.SurfaceGui.TextLabel.Text = "You lost $"..GameDataModule:AddCommasToNumber(playerData[3]).."!";
					podiums[playerData[1]].Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(255, 100, 100);
					if playerData[2]:IsA("Player") then
						PlayerAction:FireClient(playerData[2], "winnings", {"You lost $"..GameDataModule:AddCommasToNumber(playerData[3]).."!"});
					end
				end
			end
		end

		task.wait(tableGame:GetAttribute("TimeBeforeNewRound"));
	end
	
	--End the current round and start the next round if players are still present
	if tableGame:GetAttribute("RoundStarted") then
		resetTable();

		for each, stool in pairs(functional.Stools:GetChildren()) do
			if stool.Seat.Occupant then
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player and player:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash") then
					if not tableGame:GetAttribute("RoundPending") then
						tableGame:SetAttribute("RoundPending", true);
					end
					PlayerAction:FireClient(player, "newRound");
				end
			end
		end
		
		if tableGame:GetAttribute("NPCsAtGame") > 0 then
			if not tableGame:GetAttribute("RoundStarted") then
				tableGame:SetAttribute("RoundPending", true);
			end
			
			for each, npc in pairs(tableGame.NPCs:GetChildren()) do
				if npc:FindFirstChild("PlayGame") then
					npc.PlayGame.Response:Fire("BetBigWheel");
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
			if typeof(data[1]) == "string" and typeof(data[2]) == "number" then
				if (data[2] >= tableGame:GetAttribute("MinCash") and data[2] <= tableGame:GetAttribute("MaxCash")) then
					if actualPlayer:GetAttribute("Cash") >= data[2] then
						if data[1] == "Red" or data[1] == "Blue" or data[1] == "Yellow" or data[1] == "Green" then
							data[2] = math.floor(data[2]);
							togglePlayerSelection(true, player, actualPlayer, data[1], data[2]);
						end
					end
				end
			end
		elseif action == "Cancel" then
			togglePlayerSelection(false, player, actualPlayer, nil, nil);
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
				sign.SurfaceGui.TextLabel.Text = i;
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

tableGame:GetAttributeChangedSignal("WheelSpeed"):Connect(function()
	if not tableGame:GetAttribute("WheelSpinning") then
		tableGame:SetAttribute("WheelSpinning", true);
		
		while tableGame:GetAttribute("WheelSpeed") > 0 and tableGame:GetAttribute("WheelSpinning") do
			local newCFrame = wheel.PrimaryPart.CFrame * CFrame.Angles(math.rad(tableGame:GetAttribute("WheelSpeed")), 0, 0);
			local currentPivot = wheel:GetPivot()
			wheel:PivotTo(newCFrame);
			
			local speed = tableGame:GetAttribute("WheelSpeed") > 2 and random:NextNumber(0.004, 0.007) or random:NextNumber(0.001, 0.003);
			tableGame:SetAttribute("WheelSpeed", tableGame:GetAttribute("WheelSpeed") - speed);
			task.wait(1/60);
		end
		
		tableGame:SetAttribute("WheelSpeed", 0);
		tableGame:SetAttribute("WheelSpinning", false);
	end
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

pointer.Hit.Touched:Connect(function(hit)
	if tableGame:GetAttribute("SlowingDown") and hit:GetAttribute("Peg") then
		if not hit:GetAttribute("Tagged") then
			hit:SetAttribute("Tagged", true);
			hit.Light.Material = Enum.Material.Neon;
			hit.Light.PointLight.Enabled = true;
			sign.SurfaceGui.TextLabel.Text = hit.Label.SurfaceGui.Number.Text;
			sign.SurfaceGui.TextLabel.TextColor3 = hit.Light.Color;
			timeSinceLastOutcome = os.time();
			
			for each, peg in pairs(wheel:GetChildren()) do
				if peg:GetAttribute("Peg") and peg ~= hit then
					peg.Light.Material = Enum.Material.SmoothPlastic;
					peg.Light.PointLight.Enabled = false;
				end
			end
			
			GameFunctions:PlaySound("BigWheel", "Ding", soundBox, false, false, false);
			
			task.wait(0.75);
			repeat task.wait(); until hit.Light.Material == Enum.Material.SmoothPlastic or not tableGame:GetAttribute("SlowingDown")
			hit:SetAttribute("Tagged", false);
		end
	end
end)

local function initialize()
	for each, podium in pairs(podiums:GetChildren()) do
		podium.MinCash.SurfaceGui.TextLabel.Text = "MIN: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MinCash"));
		podium.MaxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(tableGame:GetAttribute("MaxCash"));
		podium.MinCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
		podium.MaxCash.Fire.Enabled = tableGame:GetAttribute("HighRoller");
		podium.Wedge.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
		podium.Base.Material = tableGame:GetAttribute("HighRoller") and Enum.Material.Marble or Enum.Material.Plastic;
	end

	resetTable();
	
	for each, stool in pairs(functional.Stools:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()	
			if stool.Seat.Occupant then
				tableGame:SetAttribute("PlayersAtTable", tableGame:GetAttribute("PlayersAtTable") + 1);
				
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					if not stool.Seat.Occupant.Parent:GetAttribute("Stool") then
						if player:GetAttribute("Cash") >= tableGame:GetAttribute("MinCash")  then
							if not tableGame:GetAttribute("RoundStarted") then
								tableGame:SetAttribute("RoundPending", true);
							end

							local gui = script.BigWheel:Clone();
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
	
	coroutine.wrap(function()
		while true do
			for each, part in pairs(pointer:GetChildren()) do
				part.CanQuery = not part.CanQuery;
			end
			task.wait(0.1);
		end
	end)()
end

PlayNPC.Event:Connect(function(npc, action)
	if action == "arriving" then
		if not tableGame:GetAttribute("RoundStarted") then
			local randomColor = random:NextInteger(1, 4);
			local colorChoice = (randomColor == 1 and "Red") or (randomColor == 2 and "Yellow") or (randomColor == 3 and "Blue") or (randomColor == 4 and "Green");
			local betChoice = random:NextInteger(tableGame:GetAttribute("MinCash"), tableGame:GetAttribute("MaxCash"));
			togglePlayerSelection(true, npc:GetAttribute("Stool"), npc, colorChoice, betChoice);
		end
	elseif action == "leaving" then
		tableGame:SetAttribute("NPCsAtGame", tableGame:GetAttribute("NPCsAtGame") - 1);
	end
end)

initialize();