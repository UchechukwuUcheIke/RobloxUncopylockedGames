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
local gameData = {}; --{player, actualPlayer}
local processingEvent = false;
local timeSinceLastOutcome;

local function resetTable()
	tableGame:SetAttribute("SlowingDown", false);
	tableGame:SetAttribute("RoundPending", false);
	tableGame:SetAttribute("RoundStarted", false);
	tableGame:SetAttribute("WheelSpinning", false);
	timeSinceLastOutcome = nil;
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
			peg.Light.Material = Enum.Material.SmoothPlastic;
		end
	end
	tableGame:SetAttribute("WheelSpeed", 0);
end

local function getWinningPeg()
	for each, peg in pairs(wheel:GetChildren()) do
		if peg:GetAttribute("Peg") then
			if peg.Light.Material == Enum.Material.Neon then
				return tonumber(peg.Name);
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

local function spinWheel()
	if tableGame:GetAttribute("RoundStarted") then
		--Start the spin
		tableGame:SetAttribute("SlowingDown", false);

		sign.SurfaceGui.TextLabel.Text = "LET'S GO!!!";
		GameFunctions:PlaySound("BigWheel", "Bell", soundBox, false, false, false);
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

		task.wait(GameFunctions:GetWaitTimes("bigWheelSixSpinup"));

		--Slow down the wheel
		if tableGame:GetAttribute("RoundStarted") then
			repeat task.wait(); until tableGame:GetAttribute("WheelSpeed") <= 2 or not tableGame:GetAttribute("RoundStarted")
			
			for each, part in pairs(pointer:GetChildren()) do
				part.CanCollide = true;
			end

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
	spinWheel();

	--If jackpot then do a jackpot spin, otherwise payout any winning bets
	if tableGame:GetAttribute("RoundStarted") then
		local cashWon = getWinningPeg();

		GameFunctions:PlaySound("BigWheel", "Tada", soundBox, false, false, false);
		for each, playerData in pairs(gameData) do
			local profile = ProfileManager.Profiles[playerData[2]];
			if profile then
				profile.Data.TimeOfLastCashWheel = os.time();
			end
			ProfileManager.AdjustCurrency(playerData[2], "Cash", cashWon);
			podiums[playerData[1]].Sign.SurfaceGui.TextLabel.Text = "You won $"..GameDataModule:AddCommasToNumber(cashWon).."!";

			PlayerAction:FireClient(playerData[2], "winnings", {cashWon});
			Jackpot:FireAllClients(playerData[2], cashWon);
		end

		task.wait(tableGame:GetAttribute("TimeBeforeNewRound"));
	end
	
	--End the current round and start the next round if players are still present
	if tableGame:GetAttribute("RoundStarted") then
		resetTable();

		for each, stool in pairs(functional.Stools:GetChildren()) do
			if stool.Seat.Occupant then
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					local profile = ProfileManager.Profiles[player];
					if profile then
						local playerCooldown = profile.Data.OwnsGoldClub and (tableGame:GetAttribute("CooldownGoldClub") * 3600) or (tableGame:GetAttribute("CooldownNormal") * 3600);
						local adjustedPlayerCooldown = profile.Data.OwnsFasterSpins and (playerCooldown / 2) or playerCooldown
						local timePlayerIsEligible = profile.Data.TimeOfLastCashWheel + adjustedPlayerCooldown;
						local timeBeforeNextSpin = timePlayerIsEligible - os.time();
						if timeBeforeNextSpin <= 0 or profile.Data.Cash <= 500 then
							tableGame:SetAttribute("RoundPending", true);
							table.insert(gameData, {getActualPlayerStool(player), player});
						else
							PlayerAction:FireClient(player, "ineligible", {timeBeforeNextSpin});
						end
					end
				end
			end
		end
	end
end

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
	local ineligible = {};
	-- this should stop client tampering with any of the moving components --
	for each, part in pairs(functional:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored then
			if part:FindFirstChild("WeldConstraint") then
				if not part.WeldConstraint.Part0.Anchored and not part.WeldConstraint.Part1.Anchored then
					if not table.find(ineligible, part.WeldConstraint.Part0) and not table.find(ineligible, part.WeldConstraint.Part1) then
						part:SetNetworkOwner(nil);
					end
				else
					table.insert(ineligible, part);
				end
			else
				part:SetNetworkOwner(nil);
			end
		end
	end

	resetTable();
	
	for each, stool in pairs(functional.Stools:GetChildren()) do
		stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()	
			if stool.Seat.Occupant then
				tableGame:SetAttribute("PlayersAtTable", tableGame:GetAttribute("PlayersAtTable") + 1);
				local player = Players:FindFirstChild(stool.Seat.Occupant.Parent.Name);
				if player then
					local profile = ProfileManager.Profiles[player];
					if profile then
						local gui = script.CashWheel:Clone();
						gui.ActualTable.Value = tableGame;
						gui.Parent = player.PlayerGui;
						
						local playerCooldown = profile.Data.OwnsGoldClub and (tableGame:GetAttribute("CooldownGoldClub") * 3600) or (tableGame:GetAttribute("CooldownNormal") * 3600);
						local adjustedPlayerCooldown = profile.Data.OwnsFasterSpins and (playerCooldown / 2) or playerCooldown
						local timePlayerIsEligible = profile.Data.TimeOfLastCashWheel + adjustedPlayerCooldown;
						local timeBeforeNextSpin = timePlayerIsEligible - os.time();
						if timeBeforeNextSpin <= 0 or profile.Data.Cash <= 500 then
							if not tableGame:GetAttribute("RoundStarted") then
								tableGame:SetAttribute("RoundPending", true);
								table.insert(gameData, {getActualPlayerStool(player), player});
							end
							PlayerAction:FireClient(player, "eligible");
						else
							PlayerAction:FireClient(player, "ineligible", {timeBeforeNextSpin});
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

initialize();