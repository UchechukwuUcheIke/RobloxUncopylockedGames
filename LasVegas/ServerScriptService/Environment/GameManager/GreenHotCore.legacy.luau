local ServerScriptService = game:GetService("ServerScriptService");
local ServerStorage = game:GetService("ServerStorage");

local ServerModules = ServerStorage:WaitForChild("Modules");
local GameFunctions = require(ServerModules:WaitForChild("GameFunctions"));
local CommonFunctions = require(ServerModules:WaitForChild("CommonFunctions"));
local ProfileService = ServerModules:WaitForChild("ProfileService");
local PlayerData = ProfileService:WaitForChild("PlayerData");
local ProfileManager = require(PlayerData:WaitForChild("ProfileManager"));

local Slots = script.Parent;
local Remotes = Slots:WaitForChild("Remotes");
local Functional = Slots:WaitForChild("Functional");
local PlayNPC = Remotes:WaitForChild("PlayNPC");
local PlayerAction =  Remotes:WaitForChild("PlayerAction");
local Handle = Functional:WaitForChild("Handle");
local BetHandle = Functional:WaitForChild("BetHandle");
local Wheels = Functional:WaitForChild("Wheels");
local Stool = Functional:WaitForChild("Stool");
local StoolSeat = Stool:WaitForChild("Seat");

local RNG = Random.new();
local Status = "";
local ProcessingEvent = false;
local SlotValues = {
	{0, "bell"},
	{45, "singlebar"},
	{90, "melon"},
	{135, "triplebar"},
	{180, "star"}, 
	{-135, "seven"}, 
	{-90, "doublebar"},
	{-45, "diamond"}
};
local PayoutValues = {
	["5 seven"] = 1000, --0.0031%
	["seven star combo"] = 1000, --0.0031%
	["other star combo"] = 100, --0.02%
	["5 of a kind"] = 75, --0.02%
	["5 of any bar"] = 30, --0.74%
	["4 of a kind"] = 10, --0.88%
	["full house"] = 6, --1.71%
	["2 pair w/ star"] = 3, --1.92%
	["3 of a kind"] = 2, --12.83%
	["2 pair"] = 1, --15.40%
};

local function UpdateStatus(newStatus)
	if Status ~= "jackpot" then
		Status = newStatus;
	end
end

local function CheckPayout(leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue)
	local payoutAmount = 0;
	local payouts = {};
	local valuesShown = GameFunctions:CountValuesPresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue});

	if GameFunctions:CountSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, "anybar") == 5 then
		payoutAmount += PayoutValues["5 of any bar"];
		table.insert(payouts, "5 of any bar");
		UpdateStatus("jackpot");
	end
	
	if leftValue == "seven" and leftMiddleValue == "star" and middleValue == "seven" and rightMiddleValue == "star" and rightValue == "seven" then
		payoutAmount += PayoutValues["seven star combo"];
		table.insert(payouts, "seven star combo");
		UpdateStatus("jackpot");
	elseif leftValue == middleValue and middleValue == rightValue and leftMiddleValue == "star" and rightMiddleValue == "star" and leftValue ~= "star" then
		payoutAmount += PayoutValues["other star combo"];
		table.insert(payouts, "other star combo");
		UpdateStatus("jackpot");
	end
	
	if #valuesShown == 2 then
		local value1Amount = GameFunctions:CountSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[1]);
		local value2Amount = GameFunctions:CountSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[2]);
		if (value1Amount == 2 and value2Amount == 3) or (value1Amount == 3 and value2Amount == 2) then
			payoutAmount += PayoutValues["full house"];
			table.insert(payouts, "full house");
			UpdateStatus("payout");
		end
	end
	
	if #valuesShown == 3 then
		local starAmount = GameFunctions:CountSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, "star");
		local value1Amount = GameFunctions:CountSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[1]);
		local value2Amount = GameFunctions:CountSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[2]);
		local value3Amount = GameFunctions:CountSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[3]);
		
		if starAmount == 1 then
			if valuesShown[1] == "star" then
				if value1Amount == 1 then
					if value2Amount == 2 and value3Amount == 2 then
						payoutAmount += PayoutValues["2 pair w/ star"];
						table.insert(payouts, "2 pair w/ star");
						UpdateStatus("payout");
					end
				end
			elseif valuesShown[2] == "star" then
				if value2Amount == 1 then
					if value1Amount == 2 and value3Amount == 2 then
						payoutAmount += PayoutValues["2 pair w/ star"];
						table.insert(payouts, "2 pair w/ star");
						UpdateStatus("payout");
					end
				end
			elseif value3Amount == 1 then
				if value1Amount == 2 and value2Amount == 2 then
					payoutAmount += PayoutValues["2 pair w/ star"];
					table.insert(payouts, "2 pair w/ star");
					UpdateStatus("payout");
				end
			end
		end
	end
	
	local twoPairs = 0;
	for each, value in pairs(valuesShown) do
		local count = GameFunctions:CountSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, value);
		
		if count == 5 then
			if value == "seven" then
				payoutAmount += PayoutValues["5 seven"];
				table.insert(payouts, "5 seven");
			end
			payoutAmount += PayoutValues["5 of a kind"];
			table.insert(payouts, "5 of a kind");
			UpdateStatus("jackpot");
		end
		
		if count >= 4 then
			payoutAmount += PayoutValues["4 of a kind"];
			table.insert(payouts, "4 of a kind");
			UpdateStatus("jackpot");
		end
		
		if count >= 3 then
			payoutAmount += PayoutValues["3 of a kind"];
			table.insert(payouts, "3 of a kind");
			UpdateStatus("payout");
		end
		
		if count >= 2 then
			if twoPairs == 1 then
				payoutAmount += PayoutValues["2 pair"];
				table.insert(payouts, "2 pair");
				UpdateStatus("payout");
			end
			twoPairs += 1;
		end
	end
	
	if payoutAmount == 0 then
		table.insert(payouts, "better luck next time");
	end
	
	return payoutAmount, payouts;
end

local function SpinSlots(player, profile)
	local leftValue;
	local leftMiddleValue;
	local middleValue;
	local rightMiddleValue;
	local rightValue;
	Status = "";
	
	if profile and profile.Data.OwnsDoubleSpins then
		local leftValue1 = SlotValues[RNG:NextInteger(1, 8)];
		local leftMiddleValue1 = SlotValues[RNG:NextInteger(1, 8)];
		local middleValue1 = SlotValues[RNG:NextInteger(1, 8)];
		local rightMiddleValue1 = SlotValues[RNG:NextInteger(1, 8)];
		local rightValue1 = SlotValues[RNG:NextInteger(1, 8)];
		local leftValue2 = SlotValues[RNG:NextInteger(1, 8)];
		local leftMiddleValue2 = SlotValues[RNG:NextInteger(1, 8)];
		local middleValue2 = SlotValues[RNG:NextInteger(1, 8)];
		local rightMiddleValue2 = SlotValues[RNG:NextInteger(1, 8)];
		local rightValue2 = SlotValues[RNG:NextInteger(1, 8)];

		local payoutAmount1, payoutsList1 = CheckPayout(leftValue1[2], leftMiddleValue1[2], middleValue1[2], rightMiddleValue1[2], rightValue1[2]);
		local payoutAmount2, payoutsList2 = CheckPayout(leftValue2[2], leftMiddleValue2[2], middleValue2[2], rightMiddleValue2[2], rightValue2[2]);
		Status = "";

		if payoutAmount1 >= payoutAmount2 then
			leftValue = leftValue1;
			leftMiddleValue = leftMiddleValue1;
			middleValue = middleValue1;
			rightMiddleValue = rightMiddleValue1;
			rightValue = rightValue1;
		else
			leftValue = leftValue2;
			leftMiddleValue = leftMiddleValue2;
			middleValue = middleValue2;
			rightMiddleValue = rightMiddleValue2;
			rightValue = rightValue2;
		end
	else
		leftValue = SlotValues[RNG:NextInteger(1, 8)];
		leftMiddleValue = SlotValues[RNG:NextInteger(1, 8)];
		middleValue = SlotValues[RNG:NextInteger(1, 8)];
		rightMiddleValue = SlotValues[RNG:NextInteger(1, 8)];
		rightValue = SlotValues[RNG:NextInteger(1, 8)];
	end

	GameFunctions:StartSpinningSlots(Slots);

	task.wait(GameFunctions:GetWaitTimes("start"));

	GameFunctions:StopSpinningSlot(Slots, Wheels.WheelL, leftValue[1]);
	
	task.wait(GameFunctions:GetWaitTimes("slot"));
	
	GameFunctions:StopSpinningSlot(Slots, Wheels.WheelLM, leftMiddleValue[1]);
	
	task.wait(GameFunctions:GetWaitTimes("slot"));

	GameFunctions:StopSpinningSlot(Slots, Wheels.WheelM, middleValue[1]);
	
	if leftValue[1] == leftMiddleValue[1] and leftMiddleValue[1] == middleValue[1] then
		GameFunctions:ToggleReelSuspense(Slots, Wheels.WheelRM.Wheel, true);
		task.wait(Slots:GetAttribute("SuspenseTime"));
		GameFunctions:ToggleReelSuspense(Slots, Wheels.WheelRM.Wheel, false);
	else
		task.wait(GameFunctions:GetWaitTimes("slot"));
	end
	
	GameFunctions:StopSpinningSlot(Slots, Wheels.WheelRM, rightMiddleValue[1]);
	
	if leftValue[1] == leftMiddleValue[1] and leftMiddleValue[1] == middleValue[1] and middleValue[1] == rightMiddleValue[1] then
		GameFunctions:ToggleReelSuspense(Slots, Wheels.WheelR.Wheel, true, 1);
		task.wait(Slots:GetAttribute("SuspenseTime"));
		GameFunctions:ToggleReelSuspense(Slots, Wheels.WheelR.Wheel, false);
	elseif (leftValue[1] == leftMiddleValue[1] and leftMiddleValue[1] == middleValue[1]) or 
		(leftValue[1] == leftMiddleValue[1] and leftMiddleValue[1] == rightMiddleValue[1]) or 
		(leftValue[1] == middleValue[1] and middleValue[1] == rightMiddleValue[1]) or
		(leftMiddleValue[1] == middleValue[1] and middleValue[1] == rightMiddleValue[1]) or
		(leftValue[1] == middleValue[1] and leftMiddleValue[2] == "star" and rightMiddleValue[2] == "star") 
	then
		GameFunctions:ToggleReelSuspense(Slots, Wheels.WheelR.Wheel, true);
		task.wait(Slots:GetAttribute("SuspenseTime"));
		GameFunctions:ToggleReelSuspense(Slots, Wheels.WheelR.Wheel, false);
	else
		task.wait(GameFunctions:GetWaitTimes("slot"));
	end
	
	GameFunctions:StopSpinningSlot(Slots, Wheels.WheelR, rightValue[1]);

	task.wait(GameFunctions:GetWaitTimes("conclude"));
	
	local payoutAmount, payoutsList = CheckPayout(leftValue[2], leftMiddleValue[2], middleValue[2], rightMiddleValue[2], rightValue[2]);
	GameFunctions:ConcludeCurrentSpin(player, Slots, Status, payoutAmount, payoutsList);
	if player:IsA("Player") then
		for each, payout in pairs(payoutsList) do
			if payout == "5 seven" then
				CommonFunctions:AwardBadge(player, 3424446044386313, false);
			end
		end
	end
end

local function PullSlotsHandle(player)
	local canPullHandle = GameFunctions:CanPullSlotsHandle(Slots, player);
	if canPullHandle then
		local profile = ProfileManager.Profiles[player];
		if profile then
			SpinSlots(player, profile);
		end
	end
end

local function PullBetsHandle(player)
	local canPullHandle = GameFunctions:CanPullSlotsBetHandle(Slots, player);
	if canPullHandle then
		GameFunctions:AdjustSlotsBet(Slots);
	end
end

Handle.Click.ClickDetector.MouseClick:Connect(function(player)
	PullSlotsHandle(player);
end)

BetHandle.Click.ClickDetector.MouseClick:Connect(function(player)
	PullBetsHandle(player);
end)

PlayerAction.OnServerEvent:Connect(function(actualPlayer, action)
	if not ProcessingEvent then
		ProcessingEvent = true;

		if action == "Spin" then
			PullSlotsHandle(actualPlayer);
		elseif action == "Cycle" then
			PullBetsHandle(actualPlayer);
		end

		ProcessingEvent = false;
	end
end)

PlayNPC.Event:Connect(function(npc, action)
	if action == "spin" then
		local canPullHandle = GameFunctions:CanPullSlotsHandle(Slots, npc);
		if canPullHandle then
			SpinSlots(npc);
		end
	elseif action == "leaving" then
		Slots:SetAttribute("NPCsAtGame", 0);
	end
end)

GameFunctions:InitializeSlots(Slots, SlotValues);