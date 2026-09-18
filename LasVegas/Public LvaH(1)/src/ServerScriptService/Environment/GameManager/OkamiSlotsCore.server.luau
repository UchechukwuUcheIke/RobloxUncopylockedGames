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
	{0, "ael"}, 
	{45, "pluto"}, 
	{90, "gamer"}, 
	{135, "vulso"}, 
	{180, "sal"}, 
	{-135, "faulty"}, 
	{-90, "cloaked"}, 
	{-45, "chaotic"}
};
local PayoutValues = {
	["the trio"] = 8, --1.17%
	["3 of a kind"] = 6, --1.56% 
	["sal w/ ael"] = 1.5, --8.20%
	["gamer w/ chaotic"] = 1.5, --8.20%
	["faulty w/ pluto"] = 1.25, --8.20%
	["cloaked w/ vulso"] = 1.25, --8.20%
	["2 of a kind"] = 0.5, --32.81%
	["1 gamer"] = 0.5 --33.01%
};

local function UpdateStatus(newStatus)
	if Status ~= "jackpot" then
		Status = newStatus;
	end
end

local function CheckPayout(leftValue, middleValue, rightValue)
	local payoutAmount = 0;
	local payouts = {};
	
	if leftValue == "gamer" or middleValue == "gamer" or rightValue == "gamer" then
		payoutAmount += PayoutValues["1 gamer"];
		table.insert(payouts, "1 gamer");
		UpdateStatus("payout");
	end
	
	if leftValue == middleValue or middleValue == rightValue or leftValue == rightValue then --if 2 match
		payoutAmount += PayoutValues["2 of a kind"];
		table.insert(payouts, "2 of a kind");
		UpdateStatus("payout");
	end
	
	if leftValue == middleValue and middleValue == rightValue then --if all 3 match
		payoutAmount += PayoutValues["3 of a kind"];
		table.insert(payouts, "3 of a kind");
		UpdateStatus("jackpot");
	end
	
	
	if GameFunctions:CheckIfPairPresent({leftValue, middleValue, rightValue}, {"gamer", "chaotic"}) then
		payoutAmount += PayoutValues["gamer w/ chaotic"];
		table.insert(payouts, "gamer w/ chaotic");
		UpdateStatus("payout");
	elseif GameFunctions:CheckIfPairPresent({leftValue, middleValue, rightValue}, {"sal", "ael"}) then
		payoutAmount += PayoutValues["sal w/ ael"];
		table.insert(payouts, "sal w/ ael");
		UpdateStatus("payout");
	elseif GameFunctions:CheckIfPairPresent({leftValue, middleValue, rightValue}, {"faulty", "pluto"}) then
		payoutAmount += PayoutValues["faulty w/ pluto"];
		table.insert(payouts, "faulty w/ pluto");
		UpdateStatus("payout");
	elseif GameFunctions:CheckIfPairPresent({leftValue, middleValue, rightValue}, {"cloaked", "vulso"}) then
		payoutAmount += PayoutValues["cloaked w/ vulso"];
		table.insert(payouts, "cloaked w/ vulso");
		UpdateStatus("payout");
	end
	
	if GameFunctions:CheckIfTrioPresent({leftValue, middleValue, rightValue}, {"gamer", "ael", "sal"}) then
		payoutAmount += PayoutValues["the trio"];
		table.insert(payouts, "the trio");
		UpdateStatus("jackpot");
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