local Debris = game:GetService("Debris");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local PolicyService = game:GetService("PolicyService");
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");
local ReplicatedModules = ReplicatedStorage:WaitForChild("Modules");
local Permissions = require(ReplicatedStorage.Modules.Permissions);
local ProfileManager = require(ServerStorage.Modules.ProfileService.PlayerData.ProfileManager);
local CommonFunctions = require(ServerStorage.Modules.CommonFunctions);
local GameDataModule = require(ReplicatedModules:WaitForChild("GameData"));
local GameSounds = ServerStorage:WaitForChild("GameSounds")
local GameFunctions = {};
local playerPolicies = {};
local random = Random.new();

function GameFunctions:GiveDealerNametag(dealer)
	local randomNames = {"Camryn","Cyrus","Alessandra","Dominik","Haven","Hugh","Averi","Ben","Alondra","Aziel","Matthew","Gabriel","Samson","Phillip","Lyric","Dario","Arianna","Crosby","Brylee","Troy","Skyla","Pierce","Gia","Eugene","Adley","George","Samara","Jett","Ellen","Princeton","Miracle","Esteban","Emani","Zaid","Elliot","Lionel","Peyton","Jolie","Jaxx","Briar","Ainsley","Keanu","Keilani","Jace","Lauren","Carmelo","Nevaeh","Shepherd","Mckenna","Jeffery","Denver","Julius","Fallon","Ayaan","Teagan","Isabela","Maurice","Kayla","Orlando","Luis"};
	local overhead = script.Overhead:Clone();
	overhead.Backing.Username.Text = randomNames[random:NextInteger(1, #randomNames)];
	overhead.Backing.Role.Text = "NPC";
	overhead.Parent = dealer.Head;
	overhead.Adornee = dealer.Head;
end

function GameFunctions:PlaySound(gameName, soundName, location, soundLooped, yield, randomTimePosition)
	local sound = GameSounds[gameName]:FindFirstChild(soundName);
	if sound then
		local newSound = sound:Clone();
		newSound.Parent = location;
		if randomTimePosition then
			newSound.TimePosition = random:NextNumber(0, newSound.TimeLength);
		end
		newSound:Play();
		
		if soundLooped then
			newSound.Looped = true;
		else
			if yield then
				newSound.Ended:Wait();
				newSound:Destroy();
			else
				Debris:AddItem(newSound, newSound.TimeLength);
			end
		end		
	else
		error("GameFunctions PlaySound: Sound "..soundName.." was not found in "..gameName.." for playing!");
	end
end

function GameFunctions:StopSound(gameName, soundName, location)
	local sound = location:FindFirstChild(soundName);
	if sound then
		sound:Stop();
		sound:Destroy();
	else
		warn("GameFunctions StopSound: Sound "..soundName.." was not found in "..gameName.." "..location.Name.." for deletion!");
	end
end

function GameFunctions:PaidRandomItemsNotRestricted(player)
	if not playerPolicies[player] then
		local success, result = pcall(function()
			playerPolicies[player] = PolicyService:GetPolicyInfoForPlayerAsync(player);
		end)

		if not success then
			warn("PolicyService error: "..result);
		end
	end
	
	if playerPolicies[player] then
		player:SetAttribute("AllowedExternalLinkReferences", #playerPolicies[player].AllowedExternalLinkReferences);
		player:SetAttribute("IsSubjectToChinaPolicies", playerPolicies[player].IsSubjectToChinaPolicies);
		if playerPolicies[player].IsSubjectToChinaPolicies then
			return false;
		end
	end
	
	return true;
end

function GameFunctions:GetWaitTimes(timeType)
	if timeType == "slot" then
		return random:NextNumber(0.5, 1);
	elseif timeType == "conclude" then
		return 1;
	elseif timeType == "start" then
		return 2;
	elseif timeType == "handleDelay" then
		return 2;
	elseif timeType == "jackpotHandleDelay" then
		return 5;
	elseif timeType == "textDisplay" then
		return 1.5;
	elseif timeType == "lights" then
		return 0.15;
	elseif timeType == "roulettePhase" then
		return random:NextNumber(3, 6);
	elseif timeType == "bigWheelSixSpinup" then
		return random:NextNumber(4, 8);
	elseif timeType == "bigWheelSixSlowdown" then
		return random:NextNumber(8, 12);
	end
end

function GameFunctions:GetPlayerFromActualPlayer(actualPlayer, gameData)
	for each, playerData in pairs(gameData) do
		if playerData[2] == actualPlayer then
			return playerData[1];
		end
	end
end

function GameFunctions:GetPlayerDataFromPlayer(player, gameData)
	for each, playerData in pairs(gameData) do
		if playerData[1] == player then
			return playerData;
		end
	end
end

function GameFunctions:DisplayPayout(slots, payoutAmount, payouts)
	coroutine.wrap(function()
		while slots:GetAttribute("Idle") do
			if payouts[1] == "better luck next time" then
				slots.Functional.Sign.SurfaceGui.TextLabel.Text = "You lost $"..GameDataModule:AddCommasToNumber(slots:GetAttribute("ActiveBet")).."!";
				slots.Functional.Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(255, 100, 100);
			else
				slots.Functional.Sign.SurfaceGui.TextLabel.Text = "You won $"..GameDataModule:AddCommasToNumber(payoutAmount).."!";
				slots.Functional.Sign.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 100);
			end
			task.wait(GameFunctions:GetWaitTimes("textDisplay"));

			local display;
			for each, payout in pairs(payouts) do
				if not display then
					display = payout;
				else
					display = display..", "..payout;
				end
			end
			
			if slots:GetAttribute("Idle") then
				slots.Functional.Sign.SurfaceGui.TextLabel.Text = display;
				task.wait(GameFunctions:GetWaitTimes("textDisplay"));
			end
		end
		
		slots.Functional.Sign.SurfaceGui.TextLabel.Text = "";
	end)()
end

function GameFunctions:DisplayJackpotLights(slots)
	coroutine.wrap(function()
		slots.Functional.Light.ParticleEmitter.Enabled = true;

		local i = 0;
		while slots:GetAttribute("Idle") do
			i += 1;
			if i % 2 == 0 then
				slots.Functional.Light.PointLight.Color = slots:GetAttribute("StrobeColor1");
				slots.Functional.Light.Color = slots:GetAttribute("StrobeColor1");
			else
				slots.Functional.Light.PointLight.Color = slots:GetAttribute("StrobeColor2");
				slots.Functional.Light.Color = slots:GetAttribute("StrobeColor2");
			end

			slots.Functional.Light.Transparency = 0;
			slots.Functional.Light.PointLight.Enabled = true;
			task.wait(GameFunctions:GetWaitTimes("lights"));
			
			if slots:GetAttribute("Idle") then
				slots.Functional.Light.Transparency = 1;
				slots.Functional.Light.PointLight.Enabled = false;
				task.wait(GameFunctions:GetWaitTimes("lights"));
			end
		end
		slots.Functional.Light.ParticleEmitter.Enabled = false;
	end)()
end

function GameFunctions:ConcludeCurrentSpin(player, slots, status, payoutAmount, payoutsList)
	slots:SetAttribute("Cooldown", true);
	slots:SetAttribute("Idle", true);
	
	local adjustedPayout = 0;
	if payoutsList[1] ~= "better luck next time" then
		adjustedPayout = math.floor(payoutAmount * slots:GetAttribute("ActiveBet"));
	end
	
	if player and not player:GetAttribute("GameType") then --if player:GetAttribute("GameType") exists then it's an NPC who concluded the spin, not a player
		ProfileManager.AdjustCurrency(player, "Cash", adjustedPayout);
	end
	
	GameFunctions:DisplayPayout(slots, adjustedPayout, payoutsList);
	
	if status == "jackpot" then
		GameFunctions:DisplayJackpotLights(slots);
		GameFunctions:PlaySound(slots.Name, "Jackpot", slots.Functional.SoundBox, false, false, false);
		if player and player:GetAttribute("GameType") and player:FindFirstChild("PlayGame") then
			player.PlayGame.Response:Fire("Victory");
		end
		if player and player:IsA("Player") then
			ReplicatedStorage.Remotes.Jackpot:FireAllClients(player, adjustedPayout);
		end
		task.wait(GameFunctions:GetWaitTimes("jackpotHandleDelay"));
	elseif status == "payout" then
		GameFunctions:PlaySound(slots.Name, "Win", slots.Functional.SoundBox, false, false, false);
		task.wait(GameFunctions:GetWaitTimes("handleDelay"));
	end
	
	slots:SetAttribute("Cooldown", false);
	slots:SetAttribute("Spinning", false);
	if player then
		if player:GetAttribute("GameType") and player:FindFirstChild("PlayGame") then
			player.PlayGame.Response:Fire("SpinSlots");
		else
			player:SetAttribute("DoingSpin", false);
			if player:IsA("Player") then
				slots.Remotes.PlayerAction:FireClient(player, "spinConcluded");
			end
		end	
	end
end

function GameFunctions:CountValuesPresent(reels)
	local values = {};
	table.insert(values, reels[1]);
	
	if #reels == 3 then
		if not table.find(values, reels[2]) then
			table.insert(values, reels[2]);
		end
		if not table.find(values, reels[3]) then
			table.insert(values, reels[3]);
		end
	elseif #reels == 5 then
		if not table.find(values, reels[2]) then
			table.insert(values, reels[2]);
		end
		if not table.find(values, reels[3]) then
			table.insert(values, reels[3]);
		end
		if not table.find(values, reels[4]) then
			table.insert(values, reels[4]);
		end
		if not table.find(values, reels[5]) then
			table.insert(values, reels[5]);
		end
	end
	
	return values;
end

function GameFunctions:CountSpecificValuePresent(reels, value)
	local counter = 0;
	
	for each, reel in pairs(reels) do
		if value == "dominus" then
			if reel == "bluedominus" or reel == "whitedominus" or reel == "golddominus" then
				counter += 1;
			end
		elseif value == "anybar" then
			if reel == "singlebar" or reel == "doublebar" or reel == "triplebar" then
				counter += 1;
			end
		elseif value == "fireegg" then
			if reel == "fieryegg" or reel == "bombasticegg" then
				counter += 1;
			end
		elseif value == "iceegg" then
			if reel == "boringegg" or reel == "cloudegg" then
				counter += 1;
			end
		else
			if reel == value then
				counter += 1;
			end
		end
	end

	return counter;
end

function GameFunctions:CheckIfTrioPresent(reels, trio)
	local foundOne;
	local foundTwo;
	local foundThree;
	
	for each, reel in pairs(reels) do
		if reel == trio[1] then
			foundOne = true;
		end
		if reel == trio[2] then
			foundTwo = true;
		end
		if reel == trio[3] then
			foundThree = true;
		end
	end
	
	return foundOne and foundTwo and foundThree;
end

function GameFunctions:CheckIfPairPresent(reels, pair)
	local foundOne;
	local foundTwo;

	for each, reel in pairs(reels) do
		if reel == pair[1] then
			foundOne = true;
		end
		if reel == pair[2] then
			foundTwo = true;
		end
	end

	return foundOne and foundTwo;
end

function GameFunctions:StartSpinningSlots(slots)
	slots:SetAttribute("Idle", false);
	slots:SetAttribute("Spinning", true);
	
	slots.Functional.Sign.SurfaceGui.TextLabel.Text = "";
	slots.Functional.Light.Transparency = 1;
	slots.Functional.Light.PointLight.Enabled = false;
	
	GameFunctions:PlaySound(slots.Name, tostring(random:NextInteger(1, 3)), slots.Functional.SoundBox, false, false, false);
	slots.Functional.Handle.Motor.HingeConstraint.AngularVelocity *= -1;
	task.wait(0.4);
	slots.Functional.Handle.Motor.HingeConstraint.AngularVelocity *= -1;
	for each, wheel in pairs(slots.Functional.Wheels:GetChildren()) do
		GameFunctions:PlaySound(slots.Name, "Spin", slots.Functional.SoundBox, true, false, true);
		wheel.Motor.HingeConstraint.LimitsEnabled = false;
	end
end

function GameFunctions:AdjustSlotsBet(slots)
	slots:SetAttribute("AdjustingBet", true);
	GameFunctions:PlaySound(slots.Name, tostring(random:NextInteger(1, 3)), slots.Functional.SoundBox, false, false, false);
	slots.Functional.BetHandle.Motor.HingeConstraint.AngularVelocity *= -1;
	
	task.wait(0.4);
	
	if slots:GetAttribute("ActiveBet") == slots:GetAttribute("MaxCash") then
		slots:SetAttribute("ActiveBet", slots:GetAttribute("MinCash"));
	else
		slots:SetAttribute("ActiveBet", slots:GetAttribute("ActiveBet") + slots:GetAttribute("AdjustingAmount"));
		if slots:GetAttribute("ActiveBet") > slots:GetAttribute("MaxCash") then
			slots:SetAttribute("ActiveBet", slots:GetAttribute("MaxCash"));
		end
	end
	slots.Functional.BetSign.SurfaceGui.TextLabel.Text = "$"..GameDataModule:AddCommasToNumber(slots:GetAttribute("ActiveBet"));
	slots.Functional.BetHandle.Motor.HingeConstraint.AngularVelocity *= -1;
	
	task.wait(0.4);
	
	slots:SetAttribute("AdjustingBet", false);
end

function GameFunctions:StopSpinningSlot(slots, reel, value)
	GameFunctions:PlaySound(slots.Name, "Stop", slots.Functional.SoundBox, false, false, false);
	GameFunctions:StopSound(slots.Name, "Spin", slots.Functional.SoundBox);
	reel.Motor.HingeConstraint.LimitsEnabled = true;
	reel.Motor.HingeConstraint.LowerAngle = value;
end

function GameFunctions:ToggleReelSuspense(slots, reel, toggle, epicness)
	if toggle then
		-- change reel texture to epic
		GameFunctions:PlaySound(slots.Name, "Suspense", slots.Functional.SoundBox, false, false, false);
		reel.Parent.Motor.HingeConstraint.AngularVelocity = 18;
	else
		-- change reel texture back to normal
		reel.Parent.Motor.HingeConstraint.AngularVelocity = 12;
	end
end

local function updateSlotSign(slots, text)
	if slots.Functional.Sign.SurfaceGui.TextLabel.Text ~= text then
		slots.Functional.Sign.SurfaceGui.TextLabel.Text = text;
		task.wait(GameFunctions:GetWaitTimes("textDisplay"));
		if slots.Functional.Sign.SurfaceGui.TextLabel.Text == text then
			slots.Functional.Sign.SurfaceGui.TextLabel.Text = "";
		end
	end
end

function GameFunctions:CanPullSlotsHandle(slots, player)
	if player:GetAttribute("GameType") and not slots:GetAttribute("Spinning") then
		return true;
	elseif slots.Functional.Stool.Seat.Occupant and slots.Functional.Stool.Seat.Occupant.Parent.Name == player.Name then
		if player and slots and not player:GetAttribute("DoingSpin") then
			if player:GetAttribute("Cash") >= slots:GetAttribute("ActiveBet") then
				if not slots:GetAttribute("Spinning") then
					ProfileManager.AdjustCurrency(player, "Cash", -slots:GetAttribute("ActiveBet"));
					player:SetAttribute("DoingSpin", true);
					return true;
				end
			elseif not slots:GetAttribute("Spinning") then
				updateSlotSign(slots, "Not enough cash!");
			end
		end
	end
end

function GameFunctions:CanPullSlotsBetHandle(slots, player)
	if slots.Functional.Stool.Seat.Occupant and slots.Functional.Stool.Seat.Occupant.Parent.Name == player.Name then
		if not player:GetAttribute("DoingSpin") and not slots:GetAttribute("Spinning") and not slots:GetAttribute("AdjustingBet") then
			return true;
		end
	end
end

function GameFunctions:InitializeSlots(slots, slotValues)
	if slots:GetAttribute("MinCash") == 1 then
		slots.Functional.MinCash.SurfaceGui.TextLabel.Text = "MIN: $"..GameDataModule:AddCommasToNumber(slots:GetAttribute("MinCash"));
	else
		slots.Functional.MinCash.SurfaceGui.TextLabel.Text = "MIN: $"..GameDataModule:AddCommasToNumber(slots:GetAttribute("MinCash"));
	end
	
	if slots:GetAttribute("MaxCash") == 1 then
		slots.Functional.MaxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(slots:GetAttribute("MaxCash"));
	else
		slots.Functional.MaxCash.SurfaceGui.TextLabel.Text = "MAX: $"..GameDataModule:AddCommasToNumber(slots:GetAttribute("MaxCash"));
	end
	
	slots:SetAttribute("ActiveBet", random:NextInteger(slots:GetAttribute("MinCash"), slots:GetAttribute("MaxCash")));
	slots.Functional.BetSign.SurfaceGui.TextLabel.Text = "$"..GameDataModule:AddCommasToNumber(slots:GetAttribute("ActiveBet"));
	
	for each, wheel in pairs(slots.Functional.Wheels:GetChildren()) do
		wheel.Motor.HingeConstraint.LowerAngle = slotValues[random:NextInteger(1, 8)][1];
	end
	
	slots.Functional.Stool.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if slots.Functional.Stool.Seat.Occupant then
			local player = Players:FindFirstChild(slots.Functional.Stool.Seat.Occupant.Parent.Name);
			if player then
				if not slots.Functional.Stool.Seat.Occupant.Parent:GetAttribute("Stool") then
					if player:GetAttribute("Cash") >= slots:GetAttribute("MinCash") then
						local gui = script.Slots:Clone();
						gui.ActualTable.Value = slots;
						gui.Parent = player.PlayerGui;
					end
				end
			end
		end
	end)
end

return GameFunctions;