local ServerScriptService = game:GetService("ServerScriptService");
local ServerStorage = game:GetService("ServerStorage");

local ServerModules = ServerStorage:WaitForChild("Modules");
local GameFunctions = require(ServerModules:WaitForChild("GameFunctions"));
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
	{0, "fieryegg"},
	{45, "bombasticegg"}, 
	{90, "equinoxegg"}, 
	{135, "paradoxegg"}, 
	{180, "goldegg"}, 
	{-135, "crimsonegg"}, 
	{-90, "cloudegg"}, 
	{-45, "boringegg"}
};
local PayoutValues = {
	["3 gold egg"] = 10, --0.20%
	["3 of a kind"] = 7, --1.37%
	["3 ice egg"] = 5, --1.56%
	["3 fire egg"] = 5, --1.56%
	["1 pair w/ gold egg"] = 5, --4.10%
	["2 gold egg"] = 4, --4.30%
	["1 gold egg"] = 0.5, --33.00%
	["2 of a kind"] = 0.5 --34.38%
};

local function UpdateStatus(newStatus)
	if Status ~= "jackpot" then
		Status = newStatus;
	end
end

local function CheckPayout(leftValue, middleValue, rightValue)
	local payoutAmount = 0;
	local payouts = {};
	local valuesShown = GameFunctions:CountValuesPresent({leftValue, middleValue, rightValue});
	
	if leftValue == middleValue and middleValue == rightValue then
		if leftValue == "goldegg" then
			payoutAmount += PayoutValues["3 gold egg"];
			table.insert(payouts, "3 gold egg");
		else
			payoutAmount += PayoutValues["3 of a kind"];
			table.insert(payouts, "3 of a kind");
		end
		UpdateStatus("jackpot");
	end
	
	if leftValue == middleValue or middleValue == rightValue or leftValue == rightValue then
		payoutAmount += PayoutValues["2 of a kind"];
		table.insert(payouts, "2 of a kind");
		UpdateStatus("payout");
	end
	
	local goldeggAmount = GameFunctions:CountSpecificValuePresent({leftValue, middleValue, rightValue}, "goldegg");
	if goldeggAmount >= 2 then
		payoutAmount += PayoutValues["2 gold egg"];
		table.insert(payouts, "2 gold egg");
		UpdateStatus("payout");
	end
	if goldeggAmount >= 1 then
		payoutAmount += PayoutValues["1 gold egg"];
		table.insert(payouts, "1 gold egg");
		UpdateStatus("payout");
	end
	
	if GameFunctions:CountSpecificValuePresent({leftValue, middleValue, rightValue}, "fireegg") == 3 then
		payoutAmount += PayoutValues["3 fire egg"];
		table.insert(payouts, "3 fire egg");
		UpdateStatus("payout");
	end
	
	if GameFunctions:CountSpecificValuePresent({leftValue, middleValue, rightValue}, "iceegg") == 3 then
		payoutAmount += PayoutValues["3 ice egg"];
		table.insert(payouts, "3 ice egg");
		UpdateStatus("payout");
	end
	
	if #valuesShown == 2 then
		local value1Amount = GameFunctions:CountSpecificValuePresent({leftValue, middleValue, rightValue}, valuesShown[1]);
		local value2Amount = GameFunctions:CountSpecificValuePresent({leftValue, middleValue, rightValue}, valuesShown[2]);
		
		if goldeggAmount == 1 then
			if valuesShown[1] == "goldegg" then
				if value2Amount == 2 then
					payoutAmount += PayoutValues["1 pair w/ gold egg"];
					table.insert(payouts, "1 pair w/ gold egg");
					UpdateStatus("payout");
				end
			elseif value1Amount == 2 then
				payoutAmount += PayoutValues["1 pair w/ gold egg"];
				table.insert(payouts, "1 pair w/ gold egg");
				UpdateStatus("payout");
			end
		end
	end
	
	if payoutAmount == 0 then
		table.insert(payouts, "better luck next time");
	end
	
	return payoutAmount, payouts;
end

local function SpinSlots(player, outcome, profile)
	local leftValue;
	local middleValue;
	local rightValue;
	Status = "";
	
	if profile and profile.Data.OwnsDoubleSpins then
		local leftValue1 = SlotValues[RNG:NextInteger(1, 8)];
		local middleValue1 = SlotValues[RNG:NextInteger(1, 8)];
		local rightValue1 = SlotValues[RNG:NextInteger(1, 8)];
		local leftValue2 = SlotValues[RNG:NextInteger(1, 8)];
		local middleValue2 = SlotValues[RNG:NextInteger(1, 8)];
		local rightValue2 = SlotValues[RNG:NextInteger(1, 8)];

		local payoutAmount1, payoutsList1 = CheckPayout(leftValue1[2], middleValue1[2], rightValue1[2]);
		local payoutAmount2, payoutsList2 = CheckPayout(leftValue2[2], middleValue2[2], rightValue2[2]);
		Status = "";

		if payoutAmount1 >= payoutAmount2 then
			leftValue = leftValue1;
			middleValue = middleValue1;
			rightValue = rightValue1;
		else
			leftValue = leftValue2;
			middleValue = middleValue2;
			rightValue = rightValue2;
		end
	else
		leftValue = SlotValues[RNG:NextInteger(1, 8)];
		middleValue = SlotValues[RNG:NextInteger(1, 8)];
		rightValue = SlotValues[RNG:NextInteger(1, 8)];
	end
	
	GameFunctions:StartSpinningSlots(Slots);

	task.wait(GameFunctions:GetWaitTimes("start"));

	GameFunctions:StopSpinningSlot(Slots, Wheels.WheelL, leftValue[1]);

	task.wait(GameFunctions:GetWaitTimes("slot"));

	GameFunctions:StopSpinningSlot(Slots, Wheels.WheelM, middleValue[1]);

	if leftValue[1] == middleValue[1] then
		GameFunctions:ToggleReelSuspense(Slots, Wheels.WheelR.Wheel, true);
		task.wait(Slots:GetAttribute("SuspenseTime"));
		GameFunctions:ToggleReelSuspense(Slots, Wheels.WheelR.Wheel, false);
	else
		task.wait(GameFunctions:GetWaitTimes("slot"));
	end

	GameFunctions:StopSpinningSlot(Slots, Wheels.WheelR, rightValue[1]);

	task.wait(GameFunctions:GetWaitTimes("conclude"));
	
	local payoutAmount, payoutsList = CheckPayout(leftValue[2], middleValue[2], rightValue[2]);
	GameFunctions:ConcludeCurrentSpin(player, Slots, Status, payoutAmount, payoutsList);
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